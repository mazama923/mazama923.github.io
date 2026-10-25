# Initial content catalog

This catalog records the legacy Jekyll content converted to Blogatto. The historical source files were retired after validating the generated Blogatto routes.

## Posts

| Legacy source | Proposed slug | Status |
| --- | --- | --- |
| `_posts/2025-11-03-la-creation-de-ce-site.md` | `la-creation-de-ce-site` | Migrated |
| `_posts/2025-11-18-could-not-read-from-remote-repository.md` | `could-not-read-from-remote-repository` | Migrated |
| `_posts/2025-12-08-home-server.md` | `home-server` | Migrated |
| `_posts/2026-02-15-ma-font.md` | `ma-font` | Migrated |

## Documentation pages

| Legacy source | Proposed slug | Status |
| --- | --- | --- |
| `docs/auto_update_crowdsec.md` | `auto-update-crowdsec` | Migrated |
| `docs/diun.md` | `diun` | Migrated |
| `docs/dnsmasq_unbound.md` | `dnsmasq-unbound` | Migrated |
| `docs/gerer_ses_dotfiles.md` | `gerer-ses-dotfiles` | Migrated |
| `docs/podman-dns.md` | `podman-dns` | Migrated |
| `docs/securiser_caddy_avec_crowdsec.md` | `securiser-caddy-avec-crowdsec` | Migrated |
| `docs/socket_activation_caddy_podman.md` | `socket-activation-caddy-podman` | Migrated |

## Exploration and equipment

| Legacy source | Proposed slug | Status |
| --- | --- | --- |
| `exploration/azerty-a-qwerty.md` | `azerty-a-qwerty` | Migrated |
| `exploration/google_a_umami.md` | `google-a-umami` | Migrated |
| `exploration/perplexity.md` | `perplexity` | Migrated |
| `exploration/vscode_to_neovim.md` | `vscode-to-neovim` | Migrated |
| `matos/index.md` | `mon-matos` | Migrated |

## Superseded navigation files

| Legacy source | Replacement | Status |
| --- | --- | --- |
| `index.md` | Blogatto route `/` | Superseded |
| `docs/index.md` | Blogatto route `/blog` and tags | Superseded |
| `exploration/index.md` | Blogatto route `/blog` and tags | Superseded |

Create future content through `just draft-post` or `just draft-page`, review the draft, run `just check`, then publish it with `just publish`.
