# Catalogue initial de contenu

Ce catalogue recense le contenu Jekyll historique converti vers Blogatto. Les fichiers sources historiques ont été retirés après validation des routes Blogatto générées.

## Articles

| Source historique | Slug proposé | État |
| --- | --- | --- |
| `_posts/2025-11-03-la-creation-de-ce-site.md` | `la-creation-de-ce-site` | Migré |
| `_posts/2025-11-18-could-not-read-from-remote-repository.md` | `could-not-read-from-remote-repository` | Migré |
| `_posts/2025-12-08-home-server.md` | `home-server` | Migré |
| `_posts/2026-02-15-ma-font.md` | `ma-font` | Migré |

## Pages de documentation

| Source historique | Slug proposé | État |
| --- | --- | --- |
| `docs/auto_update_crowdsec.md` | `auto-update-crowdsec` | Migré |
| `docs/diun.md` | `diun` | Migré |
| `docs/dnsmasq_unbound.md` | `dnsmasq-unbound` | Migré |
| `docs/gerer_ses_dotfiles.md` | `gerer-ses-dotfiles` | Migré |
| `docs/podman-dns.md` | `podman-dns` | Migré |
| `docs/securiser_caddy_avec_crowdsec.md` | `securiser-caddy-avec-crowdsec` | Migré |
| `docs/socket_activation_caddy_podman.md` | `socket-activation-caddy-podman` | Migré |

## Exploration et matériel

| Source historique | Slug proposé | État |
| --- | --- | --- |
| `exploration/azerty-a-qwerty.md` | `azerty-a-qwerty` | Migré |
| `exploration/google_a_umami.md` | `google-a-umami` | Migré |
| `exploration/perplexity.md` | `perplexity` | Migré |
| `exploration/vscode_to_neovim.md` | `vscode-to-neovim` | Migré |
| `matos/index.md` | `mon-matos` | Migré |

## Fichiers de navigation remplacés

| Source historique | Remplacement | État |
| --- | --- | --- |
| `index.md` | Route Blogatto `/` | Remplacé |
| `docs/index.md` | Routes Blogatto `/blog` et tags | Remplacé |
| `exploration/index.md` | Routes Blogatto `/blog` et tags | Remplacé |

Créez le contenu futur avec `just brouillon-article` ou `just brouillon-page`, faites relire le brouillon par un humain, exécutez `just verifier-contenu`, puis publiez-le explicitement avec `just publier`.
