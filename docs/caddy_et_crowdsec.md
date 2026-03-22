---
title: Sécuriser Caddy avec CrowdSec : Mon setup Podman
layout: default
date: 2026-03-22
parent: 📖 Presque une doc
categories: [docs]
tags: [podman, caddy, secu, crowdsec]
last_modified_date: 2026-03-22
---

# Sécuriser Caddy avec CrowdSec : Mon setup Podman

Dans mon homelab Fedora + Podman, j'ai remplacé Fail2ban par CrowdSec pour protéger Caddy. Voici comment je l'ai configuré, étape par étape.

## Caddy + CrowdSec : Pourquoi ce duo ?

**Caddy**, c'est le serveur web moderne écrit en Go, ultra-simple à configurer (adieu les galères Nginx/Apache !). 

**CrowdSec** ? Un IPS open-source communautaire qui détecte les attaques via les logs et partage les IP malveillantes en temps réel. Il bloque proactivement grâce à ses "collections" de règles et son réseau communautaire.

**Pourquoi les associer ?** Fail2ban faisait le job de base (ban IP après X tentatives de login foireuses), mais il est réactif seulement. CrowdSec ajoute l'intelligence collective : il connaît déjà 99% des bots/scans avant qu'ils touchent vos logs.

Résultat : sécurité proactive, zéro config compliquée, et scalable pour mon setup conteneurisé.

> Documentation officielle : [Secure Caddy with CrowdSec](https://www.crowdsec.net/blog/secure-caddy-crowdsec-remediation-waf-guide)

## Installation : CrowdSec sur l'hôte

Mon Caddy tourne en **Podman rootless** (réseau isolé). CrowdSec ? Directement sur l'hôte Fedora pour monitorer pods + services natifs.

### 1. CrowdSec sur Fedora
```bash
curl -s https://install.crowdsec.net | sudo sh
sudo dnf install crowdsec
```

Autres distros : [Doc officielle](https://docs.crowdsec.net/u/getting_started/installation/linux/).

### 2. Caddy custom avec xcaddy
J'utilise un **Dockerfile Podman** pour compiler Caddy avec les plugins CrowdSec :

```dockerfile
FROM caddy:2.11.2-builder-alpine AS builder

RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    xcaddy build \
    --with github.com/caddy-dns/duckdns \
    --with github.com/mholt/caddy-l4 \
    --with github.com/caddyserver/transform-encoder \
    --with github.com/hslatman/caddy-crowdsec-bouncer/http@main \
    --with github.com/hslatman/caddy-crowdsec-bouncer/appsec@main \
    --with github.com/hslatman/caddy-crowdsec-bouncer/layer4@main

FROM caddy:2.11.2-alpine
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
```

Build :
```bash
podman build -t localhost/caddy-custo:latest .
```

## Connexion API : Premier test de ban

### Clé API
```bash
cscli bouncers add caddy-bouncer
# Notez bien la clé générée !
```

**Astuce Podman** : Mes conteneurs ne voient pas `127.0.0.1` de l'hôte. Je configure donc CrowdSec sur `0.0.0.0` :
```yaml
# /etc/crowdsec/config.yaml
api:
  listen_addr: 0.0.0.0:8080  # ⚠️ Sécurisez vos ports !
```

### Caddyfile de base
```caddy
{
  crowdsec {
    api_url http://host.containers.internal:8080
    api_key VOTRE_CLE
    ticker_interval 15s
  }
}

ton_site.com {
  route {
    crowdsec
    respond "✅ CrowdSec OK!" 200
  }
}
```

**Test fatidique** :
```bash
cscli decisions add -i $(hostname -I | awk '{print $1}') -d 2m
curl ton_site.com  # → 403 Forbidden !
```

Logs Caddy : `"initializing streaming bouncer"`. Parfait ✅

## Parser les logs Caddy

### Collection Caddy
```bash
cscli collections install crowdsecurity/caddy
```

### Logs + acquis.yaml
Caddyfile :
```caddy
{
  # ... crowdsec ...
  log {
    output file /var/log/caddy/access.log {
      roll_size 30MiB
      roll_keep 5
    }
  }
}
```

Acquisition :
```yaml
# /etc/crowdsec/acquis.d/caddy.yaml
filename: /var/log/caddy/access.log
labels:
  type: caddy
```
```bash
systemctl restart crowdsec
cscli metrics show acquisition  # Parsing actif !
```

## AppSec : Protection L7 avancée

**AppSec** = WAF-like intégré. Bloque SQLi, XSS, path traversal **avant** que l'app les voie.

### Collections
```bash
cscli collections install crowdsecurity/appsec-virtual-patching crowdsecurity/appsec-generic-rules
```

### Config AppSec
```yaml
# /etc/crowdsec/acquis.d/appsec.yaml
appsec_config: crowdsecurity/appsec-default
labels:
  type: appsec
listen_addr: 0.0.0.0:7422
source: appsec
```
```bash
systemctl restart crowdsec
```

Caddyfile :
```caddy
{
  crowdsec {
    # ...
    appsec_url http://host.containers.internal:7422
  }
}

ton_site.com {
  route {
    crowdsec    # IP ban d'abord
    appsec      # Puis règles L7
    respond "🚀 Tout est sécurisé !" 200
  }
}
```

**Test** : `curl ton_site.com/.env` → **Bloqué instantanément** par `vpatch-env-access` !
```bash
cscli alerts list  # Confirmez l'alerte
```

## Mon Caddyfile de prod (extrait)

```caddy
{
  order crowdsec first
  crowdsec {
    api_url http://host.containers.internal:8080
    api_key {env.CROWDSEC_API_KEY}
    appsec_url http://host.containers.internal:7422
    ticker_interval 15s
  }
  log { /* ... */ }
}

# Snippets réutilisables
(crowdsec_protect) {
  route { crowdsec appsec }
}
(lan_only) {
  @denied not remote_ip private_ranges VOS_RANGES_IPV6
  abort @denied
}

# Exemples
exemple.com {
  import lan_only logging crowdsec_protect
  reverse_proxy ton_pod:8096
}
```

## Verdict

**CrowdSec > Fail2ban** pour un homelab moderne : 
- Communautaire & proactif
- AppSec L7 gratuit
- Podman-friendly
- Logs → Alertes → Bans automatisés

---
*Merci d'avoir lu. Config perso, adaptez à votre stack.*

Ka-chow 🚀
