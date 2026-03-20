#!/usr/bin/env bash

# bugproof
set -euo pipefail

# Generate key
generate_key() {
    if ! command -v ssh-keygen >/dev/null 2>&1; then
        echo "ssh-keygen no está instalado. Instale OpenSSH primero."
        exit 1
    else
        echo "Generando clave ssh..."
        read -p "Ingrese un nombre para su clave: " tuclave
        ssh-keygen -t ed25519 -C "tu_correo@ejemplo.com" -f ~/.ssh/$tuclave
    fi
}

ssh_config() {
    cat >>~/.ssh/config<<EOF
Host *
    AddKeysToAgent yes
    IdentityFile ~/.ssh/$tuclave
    IdentitiesOnly yes
EOF

    case "$SHELL" in
        /usr/bin/bash)
            if ! grep -qxF 'eval "$(ssh-agent -s)" >/dev/null' ~/.bashrc; then
                cat >~/.bashrc<<'EOF'
if [ -z "$SSH_AUTH_SOCK" ] || [ ! -S "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)" >/dev/null
fi
EOF
            fi
            ;;
        /usr/bin/zsh)
            if ! grep -qxF 'eval "$(ssh-agent -s)" >/dev/null' ~/.zshrc; then
                cat >~/.zshrc<<'EOF'
if [ -z "$SSH_AUTH_SOCK" ] || [ ! -S "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)" >/dev/null
fi
EOF
            fi
            ;;
        *)
            echo "Shell no soportado: $SHELL. Solo Bash y Zsh disponibles."
            ;;
    esac
}

github_link() {
    echo "Su clave pública es: "
    cat ~/.ssh/$tuclave.pub
    echo "Copie esta clave y agréguela en GitHub → https://github.com/settings/keys"
    xdg-open "https://github.com/settings/keys" >/dev/null 2>&1 || echo "Abre la URL manualmente en tu navegador"
    echo "Haz clic en New SSH key"
    echo "En Title: ponle un nombre (por ejemplo “Mi PC principal”)"
    echo "En Key: pega el contenido copiado."
    echo "Guarda con Add SSH key."
    echo "Esperando que agregues la clave a GitHub..."
    until ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; do
        echo "No se pudo conectar. Asegúrate de haber agregado la clave y presiona Enter para reintentar..."
        read -r
    done
    echo "Conexión a GitHub exitosa"
    echo "Si necesitas más ayuda visita → https://github.com/DLM4RI/Course-Documentation/tree/main/Git"
}

# Orquestación
generate_key
ssh_config
github_link