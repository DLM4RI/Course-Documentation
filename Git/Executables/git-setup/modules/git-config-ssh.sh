#!/usr/bin/env bash

# ==============================================================================
# git-config-ssh.sh
# Configura una clave SSH ed25519 para GitHub y la activa automáticamente
# en cada inicio de sesión (Bash o Zsh).
# ==============================================================================

set -euo pipefail

# ── Colores ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "${CYAN} ${RESET} $*"; }
success() { echo -e "${GREEN} ${RESET} $*"; }
warn()    { echo -e "${YELLOW} ${RESET} $*"; }
error()   { echo -e "${RED} ${RESET} $*" >&2; exit 1; }

# ── Verificar dependencias ─────────────────────────────────────────────────────
check_deps() {
    command -v ssh-keygen >/dev/null 2>&1 || error "ssh-keygen no encontrado. Instala OpenSSH primero."
    command -v ssh-agent  >/dev/null 2>&1 || error "ssh-agent no encontrado. Instala OpenSSH primero."
    command -v ssh        >/dev/null 2>&1 || error "ssh no encontrado. Instala OpenSSH primero."
}

# ── Generar clave SSH ──────────────────────────────────────────────────────────
generate_key() {
    echo -e "\n${BOLD}═══ 1/4  Generando clave SSH ═══${RESET}"

    read -rp "$(echo -e "${CYAN}Nombre para la clave${RESET} (ej: github_trabajo): ")" KEY_NAME
    KEY_NAME="${KEY_NAME:-id_ed25519}"
    KEY_PATH="$HOME/.ssh/$KEY_NAME"

    read -rp "$(echo -e "${CYAN}Tu correo de GitHub${RESET}: ")" GIT_EMAIL

    if [[ -f "$KEY_PATH" ]]; then
        warn "Ya existe una clave en $KEY_PATH"
        read -rp "¿Sobreescribir? [s/N]: " OVERWRITE
        [[ "${OVERWRITE,,}" == "s" ]] || { info "Usando clave existente."; return; }
    fi

    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"

    ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$KEY_PATH" -N ""
    success "Clave generada en $KEY_PATH"
}

# ── Agregar bloque en ~/.ssh/config ───────────────────────────────────────────
ssh_config() {
    echo -e "\n${BOLD}═══ 2/4  Configurando ~/.ssh/config ═══${RESET}"

    CONFIG_FILE="$HOME/.ssh/config"
    touch "$CONFIG_FILE"
    chmod 600 "$CONFIG_FILE"

    # Evitar duplicados: solo insertar si este IdentityFile no está ya
    if grep -qF "IdentityFile $KEY_PATH" "$CONFIG_FILE" 2>/dev/null; then
        warn "El bloque para $KEY_NAME ya existe en $CONFIG_FILE. Se omite."
        return
    fi

    cat >> "$CONFIG_FILE" <<EOF

# --- Agregado por git-config-ssh.sh ---
Host github.com
    HostName github.com
    User git
    AddKeysToAgent yes
    IdentityFile $KEY_PATH
    IdentitiesOnly yes
EOF

    success "~/.ssh/config actualizado."
}

# ── Agregar inicio del agente al shell ────────────────────────────────────────
configure_shell_agent() {
    echo -e "\n${BOLD}═══ 3/4  Configurando inicio automático del agente ═══${RESET}"

    # Bloque que se inyectará — idempotente gracias al comentario centinela
    AGENT_BLOCK=$(cat <<'BLOCK'

# --- ssh-agent: agregado por git-config-ssh.sh ---
if [ -z "${SSH_AUTH_SOCK:-}" ] || [ ! -S "${SSH_AUTH_SOCK:-}" ]; then
    eval "$(ssh-agent -s)" >/dev/null 2>&1
fi
BLOCK
)

    SENTINEL="# --- ssh-agent: agregado por git-config-ssh.sh ---"

    case "$SHELL" in
        */bash)
            RC_FILE="$HOME/.bashrc"
            ;;
        */zsh)
            RC_FILE="$HOME/.zshrc"
            ;;
        *)
            warn "Shell no reconocido ($SHELL). Agrega manualmente el agente a tu RC."
            return
            ;;
    esac

    if grep -qF "$SENTINEL" "$RC_FILE" 2>/dev/null; then
        warn "El agente ya está configurado en $RC_FILE. Se omite."
    else
        echo "$AGENT_BLOCK" >> "$RC_FILE"
        success "Bloque del agente agregado a $RC_FILE."
    fi

    # Activar en la sesión actual también
    if [ -z "${SSH_AUTH_SOCK:-}" ] || [ ! -S "${SSH_AUTH_SOCK:-}" ]; then
        eval "$(ssh-agent -s)" >/dev/null 2>&1
    fi

    # Agregar la clave al agente ahora mismo
    ssh-add "$KEY_PATH" 2>/dev/null && success "Clave cargada en el agente." \
        || warn "No se pudo cargar la clave en el agente (puede que tenga passphrase)."
}

# ── Vincular con GitHub ────────────────────────────────────────────────────────
github_link() {
    echo -e "\n${BOLD}═══ 4/4  Vinculando con GitHub ═══${RESET}"

    echo -e "\n${BOLD}Tu clave pública:${RESET}"
    echo -e "${YELLOW}$(cat "${KEY_PATH}.pub")${RESET}\n"

    echo "Pasos para agregar la clave en GitHub:"
    echo "  1. Abre → https://github.com/settings/keys"
    echo "  2. Clic en 'New SSH key'"
    echo "  3. Título: ponle un nombre descriptivo (ej: Mi PC principal)"
    echo "  4. Key:    pega la clave pública de arriba"
    echo "  5. Clic en 'Add SSH key'"

    # Intentar abrir el navegador, fallar silenciosamente
    xdg-open "https://github.com/settings/keys" >/dev/null 2>&1 \
        || open "https://github.com/settings/keys" >/dev/null 2>&1 \
        || true

    echo ""
    local INTENTOS=0
    while true; do
        read -rp "Presiona Enter cuando hayas agregado la clave en GitHub..."
        INTENTOS=$(( INTENTOS + 1 ))

        SSH_OUTPUT=$(ssh -T git@github.com -o StrictHostKeyChecking=accept-new 2>&1 || true)

        if echo "$SSH_OUTPUT" | grep -q "successfully authenticated"; then
            success "¡Conexión con GitHub exitosa! 🎉"
            break
        else
            warn "Aún no se detecta la clave (intento $INTENTOS)."
            echo "Respuesta de GitHub: $SSH_OUTPUT"
            if (( INTENTOS >= 5 )); then
                warn "Demasiados intentos. Verifica que pegaste la clave correcta."
                echo "Ayuda: https://github.com/DLM4RI/Course-Documentation/tree/main/Git"
                break
            fi
            echo "Vuelve a intentarlo..."
        fi
    done
}

# ── Orquestación ───────────────────────────────────────────────────────────────
main() {
    echo -e "\n${BOLD}${CYAN}╔══════════════════════════════════════╗"
    echo -e "║   Configuración SSH para GitHub      ║"
    echo -e "╚══════════════════════════════════════╝${RESET}\n"

    check_deps
    generate_key
    ssh_config
    configure_shell_agent
    github_link

    echo -e "\n${GREEN}${BOLD}¡Todo listo!${RESET}"
    echo -e "La clave SSH queda activa desde ahora y se iniciará automáticamente"
    echo -e "en cada sesión de ${SHELL##*/}.\n"
    echo -e "Ayuda adicional → ${CYAN}https://github.com/DLM4RI/Course-Documentation/tree/main/Git${RESET}\n"
}

main
