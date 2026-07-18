# unix-scripts

Collection de scripts shell pour préparer et maintenir des serveurs **Debian/Ubuntu** : mise à jour du système, nettoyage, installation de paquets courants, préférences système et configuration de fastfetch.

Chaque script est autonome et exécutable directement depuis GitHub Pages, sans clone préalable du dépôt.

## ⚡ Démarrage rapide

La commande la plus utilisée, pour mettre à jour le système en une ligne :

```bash
bash <(curl -fsSL https://jturazzi.github.io/unix-scripts/debian/system/update.sh)
```

## 📜 Tous les scripts

| Script | Commande |
| --- | --- |
| **Mise à jour système** | `bash <(curl -fsSL https://jturazzi.github.io/unix-scripts/debian/system/update.sh)` |
| **Nettoyage système** | `bash <(curl -fsSL https://jturazzi.github.io/unix-scripts/debian/system/cleanup.sh)` |
| **Installation de paquets courants** | `bash <(curl -fsSL https://jturazzi.github.io/unix-scripts/debian/packages/install.sh)` |
| **Préférences système (fuseau horaire, locale)** | `bash <(curl -fsSL https://jturazzi.github.io/unix-scripts/debian/preferences/install.sh)` |
| **Installation fastfetch** | `bash <(curl -fsSL https://jturazzi.github.io/unix-scripts/debian/fastfetch/install.sh)` |
| **Suppression du MOTD** | `bash <(curl -fsSL https://jturazzi.github.io/unix-scripts/debian/motd/remove.sh)` |

> 💡 Il est recommandé de toujours lire le contenu d'un script avant de l'exécuter avec `curl \| bash`. Chaque lien ci-dessus pointe vers le fichier source correspondant dans ce dépôt.

## ✅ Prérequis

- Système basé sur **apt** (Debian, Ubuntu, ...)
- `curl` installé
- Accès `root` ou `sudo` pour les opérations privilégiées

## 📂 Détail des scripts

### `debian/system/update.sh`
Met à jour la liste des dépôts, effectue une mise à niveau complète (`apt full-upgrade`), puis nettoie les paquets obsolètes (`autoremove`, `autoclean`). Indique si un redémarrage est nécessaire.

```bash
bash <(curl -fsSL https://jturazzi.github.io/unix-scripts/debian/system/update.sh)
```

### `debian/system/cleanup.sh`
Purge les dépendances inutiles, vide le cache apt, réduit les journaux systemd (14 jours par défaut, configurable via `JOURNAL_VACUUM`) et supprime les anciens rapports de crash.

```bash
bash <(curl -fsSL https://jturazzi.github.io/unix-scripts/debian/system/cleanup.sh)
```

### `debian/packages/install.sh`
Installe un ensemble d'outils courants : `curl`, `wget`, `rsync`, `htop`, `ncdu`, `net-tools`, `traceroute`, `git`, `tree`, `jq`, `unzip`, `lsof`. Ignore les paquets déjà présents.

```bash
bash <(curl -fsSL https://jturazzi.github.io/unix-scripts/debian/packages/install.sh)
```

### `debian/preferences/install.sh`
Configure le fuseau horaire (`Europe/Paris`) et la locale (`fr_FR.UTF-8`) du système.

```bash
bash <(curl -fsSL https://jturazzi.github.io/unix-scripts/debian/preferences/install.sh)
```

### `debian/fastfetch/install.sh`
Installe [fastfetch](https://github.com/fastfetch-cli/fastfetch) via apt s'il n'est pas déjà présent, déploie la configuration personnalisée (`config.json`) dans `/etc/fastfetch/` et l'ajoute au `.bashrc` de l'utilisateur connecté ainsi que de `root`, pour un affichage automatique à l'ouverture d'un terminal.

```bash
bash <(curl -fsSL https://jturazzi.github.io/unix-scripts/debian/fastfetch/install.sh)
```

### `debian/motd/remove.sh`
Vide le message du jour (`/etc/motd`) et supprime les scripts de génération dynamique du MOTD (`/etc/update-motd.d/`).

```bash
bash <(curl -fsSL https://jturazzi.github.io/unix-scripts/debian/motd/remove.sh)
```

## 🔒 Sécurité

Ces scripts sont conçus pour être exécutés via `curl | bash`, ce qui implique une confiance dans la source. Points de vigilance :

- Les scripts nécessitant des privilèges détectent `sudo` automatiquement et échouent proprement s'il est absent.
- Toutes les opérations destructrices (suppression de paquets, purge de journaux, vidage du MOTD) sont documentées ci-dessus — vérifiez qu'elles correspondent à l'usage attendu avant exécution sur un système de production.
- Le dépôt est publié via GitHub Pages ; les commandes pointent toujours vers la branche `main`.

## 📄 Licence

[MIT](LICENSE).
