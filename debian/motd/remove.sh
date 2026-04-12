#!/usr/bin/env bash

# bash <(curl -fsSL https://jturazzi.github.io/unix-scripts/debian/motd/remove.sh)

set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
	exec sudo "$0" "$@"
fi

# Vide le message MOTD statique.
: > /etc/motd

# Supprime tous les fichiers de génération dynamique du MOTD.
if [[ -d /etc/update.motd.d ]]; then
	find /etc/update.motd.d -mindepth 1 -maxdepth 1 -type f -delete
fi

echo "Le fichier /etc/motd a été vidé."
echo "Les fichiers de /etc/update.motd.d ont été supprimés."
