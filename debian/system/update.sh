#!/usr/bin/env bash

# bash <(curl -fsSL https://jturazzi.github.io/unix-scripts/debian/system/update.sh)

set -euo pipefail

if [[ "${EUID}" -ne 0 ]] && ! command -v sudo >/dev/null 2>&1; then
    echo "Erreur: sudo est requis pour mettre à jour le système." >&2
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

echo "Mise à jour des dépôts..."
run_privileged apt update

echo "Mise à niveau complète du système..."
run_privileged apt full-upgrade -y

echo "Nettoyage des paquets inutiles..."
run_privileged apt autoremove -y
run_privileged apt autoclean -y

if [[ -f /var/run/reboot-required ]]; then
    echo ""
    echo "Un redémarrage est recommandé."
else
    echo ""
    echo "Système à jour, aucun redémarrage signalé."
fi