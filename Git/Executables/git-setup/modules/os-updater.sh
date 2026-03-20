#!/usr/bin/env bash

# bugproof
set -euo pipefail
# OS Info
update_system(){
    source /etc/os-release
    case "$ID" in
        ubuntu|debian)
            apt update
            apt upgrade -y
            apt dist-upgrade -y
            apt full-upgrade -y
            apt autoremove -y
            ;;
        fedora|rhel)
            dnf upgrade -y
            ;;
        arch)
            pacman -Syu --noconfirm
            ;;
        *)
            echo "Distribución no soportada"
            return 1
            ;;
    esac
}
# Orquestación
echo "Actualizando sistema $ID..."
update_system
# Comprobación
if ping -c1 8.8.8.8 >/dev/null 2>&1; then
    echo "Sistema actualizado correctamente."
else
    echo "No hay conexión a internet"
fi
