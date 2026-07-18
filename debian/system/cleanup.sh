#!/usr/bin/env bash

# bash <(curl -fsSL https://jturazzi.github.io/unix-scripts/debian/system/cleanup.sh)

set -euo pipefail

JOURNAL_VACUUM="${JOURNAL_VACUUM:-14d}"

if [[ "${EUID}" -ne 0 ]] && ! command -v sudo >/dev/null 2>&1; then
    echo "Erreur: sudo est requis pour nettoyer le système." >&2
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

echo "Suppression des dépendances devenues inutiles..."
run_privileged apt autoremove --purge -y

echo "Nettoyage du cache apt..."
run_privileged apt clean
run_privileged apt autoclean -y

if command -v journalctl >/dev/null 2>&1; then
    echo "Réduction des journaux systemd à ${JOURNAL_VACUUM}..."
    run_privileged journalctl --vacuum-time="$JOURNAL_VACUUM"
fi

if [[ -d /var/crash ]]; then
    echo "Suppression des anciens rapports de crash..."
    run_privileged find /var/crash -mindepth 1 -maxdepth 1 -type f -delete
fi

echo ""
echo "Nettoyage terminé."
df -h /