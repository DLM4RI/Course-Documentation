#!/usr/bin/env bash

# bugproof
set -euo pipefail
# Instalación
gitinstall() {
    if command -v git >/dev/null 2>&1; then
        echo "Git ya está instalado."
        git --version
        return 0
    fi
    # Validación de SO
    echo "Instalando Git..."
    source /etc/os-release
    case "$ID" in
        ubuntu|debian)
            apt update
            apt install -y git
            ;;
        fedora|rhel)
            dnf install -y git
            ;;
        arch)
            pacman -Syu --noconfirm git
            ;;
        *)
            echo "Distribución no soportada"
            return 1
            ;;
    esac
    # Veridicación
    echo "Git instalado correctamente."
    git --version
}

# Configuración
gitconf() {
    echo "Configurando git..."
    read -p "Ingrese su usuario: " gituser
    read -p "Ingrese su email: " gitemail
    git config --global user.name "$gituser"
    git config --global user.email "$gitemail"
    read -p "Ingrese un editor predeterminado [ 1.vim; 2.VScode ]: " gitcode
    # Validador de Workstation
    gitcode=$(echo "$gitcode" | tr '[:upper:]' '[:lower:]')
    case "$gitcode" in
    1|vim)
        git config --global core.editor "vim"
        ;;
    2|VScode)
        git config --global core.editor "code --wait"
        ;;
    *)
        echo "Se usará nano como predeterminado"
        git config --global core.editor "nano"
        ;;
    esac
    # Otras configuraciones
    git config --global core.autocrlf input
    git config --global init.defaultBranch main
    git config --global fetch.prune true
    git config --global pull.rebase true
    git config --global push.default simple
    git config --global color.ui auto
}

# Orquestación
gitinstall
gitconf
echo "Configuración de git completada exitosamente."
git config --list --show-origin
