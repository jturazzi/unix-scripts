#!/usr/bin/env bash

# bash <(curl -fsSL https://jturazzi.github.io/unix-scripts/debian/fastfetch/install.sh)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_CONFIG="$SCRIPT_DIR/config.json"
CONFIG_URL="${CONFIG_URL:-https://raw.githubusercontent.com/jturazzi/unix-scripts/main/debian/fastfetch/config.json}"
TARGET_DIR="/etc/fastfetch"
TARGET_CONFIG="$TARGET_DIR/config.json"
BASH_LINE='command -v fastfetch >/dev/null 2>&1 && fastfetch --config /etc/fastfetch/config.json'

if [[ "${EUID}" -ne 0 ]] && ! command -v sudo >/dev/null 2>&1; then
    echo "Erreur: sudo est requis pour installer la configuration systeme." >&2
    exit 1
fi

run_privileged() {
    if [[ "${EUID}" -eq 0 ]]; then
        "$@"
    else
        sudo "$@"
    fi
}

install_fastfetch() {
    if command -v fastfetch >/dev/null 2>&1; then
        echo "Fastfetch est deja installe."
        return 0
    fi

    if command -v apt >/dev/null 2>&1; then
        echo "Installation de fastfetch via apt..."
        run_privileged apt update
        run_privileged apt install -y fastfetch
    else
        echo "Erreur: gestionnaire de paquets non supporte automatiquement." >&2
        echo "Installe fastfetch manuellement puis relance ce script." >&2
        exit 1
    fi
}

ensure_bashrc_line() {
    local user_name="$1"
    local user_home
    local bashrc

    user_home="$(getent passwd "$user_name" | cut -d: -f6)"
    if [[ -z "$user_home" ]]; then
        echo "Impossible de trouver le home de $user_name" >&2
        return 1
    fi

    bashrc="$user_home/.bashrc"
    run_privileged touch "$bashrc"

    if ! run_privileged grep -Fxq "$BASH_LINE" "$bashrc"; then
        {
            echo ""
            echo "# Lance fastfetch au démarrage de bash"
            echo "$BASH_LINE"
        } | run_privileged tee -a "$bashrc" >/dev/null
    fi

    run_privileged chown "$user_name":"$user_name" "$bashrc"
}

install_fastfetch

run_privileged install -d -m 755 "$TARGET_DIR"
if [[ -f "$SOURCE_CONFIG" ]]; then
    echo "Copie de la configuration locale vers $TARGET_CONFIG"
    run_privileged install -m 644 "$SOURCE_CONFIG" "$TARGET_CONFIG"
else
    echo "Téléchargement de la configuration depuis: $CONFIG_URL"
    run_privileged curl -fsSL "$CONFIG_URL" -o "$TARGET_CONFIG"
fi

connected_user="${SUDO_USER:-$(logname 2>/dev/null || true)}"
if [[ -n "$connected_user" && "$connected_user" != "root" ]]; then
    ensure_bashrc_line "$connected_user"
fi

ensure_bashrc_line "root"

echo "Configuration installée dans $TARGET_CONFIG"
echo "Mise à jour .bashrc terminée"