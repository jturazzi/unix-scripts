#!/usr/bin/env bash

# bash <(curl -fsSL https://jturazzi.github.io/unix-scripts/debian/packages/install.sh)

set -euo pipefail

PACKAGES=(
    # Téléchargement et transfert
    curl
    wget
    rsync

    # Surveillance système
    htop
    ncdu

    # Réseau
    net-tools
    traceroute

    # Outils divers
    git
    tree
    jq
    unzip
    lsof

)

if [[ "${EUID}" -ne 0 ]] && ! command -v sudo >/dev/null 2>&1; then
    echo "Erreur: sudo est requis pour installer des paquets système." >&2
    exit 1
fi

run_privileged() {
    if [[ "${EUID}" -eq 0 ]]; then
        "$@"
    else
        sudo "$@"
    fi
}

if ! command -v apt >/dev/null 2>&1; then
    echo "Erreur: ce script requiert un système basé sur apt (Debian/Ubuntu)." >&2
    exit 1
fi

echo "Mise à jour de la liste des paquets..."
run_privileged apt update

TO_INSTALL=()
for pkg in "${PACKAGES[@]}"; do
    if ! dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "install ok installed"; then
        TO_INSTALL+=("$pkg")
    else
        echo "$pkg est déjà installé, ignoré."
    fi
done

if [[ ${#TO_INSTALL[@]} -eq 0 ]]; then
    echo "Tous les paquets sont déjà installés."
    exit 0
fi

echo "Installation des paquets : ${TO_INSTALL[*]}"
run_privileged apt install -y "${TO_INSTALL[@]}"

echo ""
echo "Installation terminée :"
for pkg in "${PACKAGES[@]}"; do
    version="$(dpkg-query -W -f='${Version}' "$pkg" 2>/dev/null || echo "inconnu")"
    printf "  %-20s %s\n" "$pkg" "$version"
done
