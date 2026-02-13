---
title: Passage de Google à Umami
layout: default
date: 2026-02-13
parent: 🔭 Exploration
categories: [Exploration]
tags: [umami, analytics, google, vie privée]
last_modified_date: fev 13 2026
---

## À quoi je cherche ?

J’écris quelques lignes sur ce blog quand j’ai envie de partager un sujet découvert ou que je trouve intéressant.

Je n’ai rien à vendre, et les statistiques m’importent peu.

Mais je suis toujours content si un article a été lu.

Mais comment puis‑je avoir ces stats sans pour autant donner toutes vos données à Google ?

## Kesako Umami ?

[Umami](https://umami.is) se présente pour moi comme une alternative à Google Search Console et Google Analytics.

Il me permet de suivre le nombre de vues et, surtout, de savoir quelles pages ou quels articles ont pu vous intéresser.

Aussi simple que ça, je ne recherche pas plus d’informations que cela.

Il peut aussi tracer le nombre de clics avec des liens de redirection ou des pixels, mais je n’ai pas encore mis en place cette fonctionnalité.

Pour les curieux, voici à quoi ressemble l’interface :

![image interface de umami](/assets/images/exploration/umami/umami.avif)

## Comment je l’ai mis en place ?

Je le déploie avec Podman, j’ai choisi de ne pas utiliser `podman-compose` car je veux utiliser l’option `AutoUpdate=registry`.

Je ne veux pas m’embêter à mettre à jour ce composant; il n’est pas critique pour moi. S’il tombe, tant pis.

Sans en faire un tuto complet, il y a juste deux fichiers à créer dans `~/.config/containers/systemd`.

### La partie DB (`umami-db.container`)

```bash
[Unit]
Description=Umami PostgreSQL Database

[Container]
Image=docker.io/library/postgres:15-alpine
ContainerName=umami-db
Network=caddy-bridge
Volume=/ssd/busdata/umami/db:/var/lib/postgresql/data:Z
Environment=POSTGRES_DB=umami
Environment=POSTGRES_USER=umami
Environment=POSTGRES_PASSWORD=<Ton mdp de DB>
AutoUpdate=registry

[Service]
Restart=always
Exec=PodmanExec nc -z umami 3000 || exit 1
```

### La partie app (`umami.container`)

```bash
[Unit]
Description=Umami Analytics
After=umami-db.service
Requires=umami-db.service

[Container]
Image=ghcr.io/umami-software/umami:postgresql-latest
ContainerName=umami
Network=caddy-bridge
Environment=DATABASE_URL=postgresql://umami:<Ton mdp de DB>@umami-db:5432/umami
Environment=DATABASE_TYPE=postgresql
Environment=APP_SECRET=<random string>
AutoUpdate=registry

[Service]
Restart=always

[Install]
WantedBy=default.target
```

### Démarrer les services Podman

```bash
systemctl --user daemon-reload
systemctl --user start umami-db.container
systemctl --user start umami.container
```

### Config Caddy pour exposer l’URL

```bash
umami.mazama923.duckdns.org {
    import duckdns_tls

    @public path /script.js /api/send
    handle @public {
        reverse_proxy umami:3000
    }

    handle {
        import lan_only
        reverse_proxy umami:3000
    }

    log
}
```

### Intégrer le script Umami dans le site

```html
<script
  async defer
  data-website-id="<Ton id disponible dans umami>"
  data-domains="<Ton domaine>"
  src="https://<Ton domaine>/script.js">
</script>
```

Cela va dépendre de la config de votre site. Personnellement, j’utilise Jekyll avec le thème Just the Docs, donc ce bloc se trouve dans `_includes/head_custom.html`.

---

Voilà encore une étape de plus pour dépendre moins de Google et mieux respecter votre vie privée.

**Ka-chow** 🚀
