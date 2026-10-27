---
title: "Mettre CrowdSec à jour automatiquement avec systemd"
date: 2026-03-22 00:00:00 Europe/Paris
description: "Automatiser la mise à jour du hub CrowdSec avec un service et un timer systemd."
slug: auto-update-crowdsec
type: post
tags: crowdsec,systemd,security,automation
---

## Auto-update CrowdSec : 3 fichiers, zéro maintenance

**Un CrowdSec à jour = un CrowdSec efficace.** Suite de mon [article Caddy + CrowdSec](/blog/securiser-caddy-avec-crowdsec/), voici comment je l'auto-maintient sans y penser.

Pour Caddy en conteneur rootless, j’ai aussi détaillé [l’activation de sockets avec Podman](/blog/socket-activation-caddy-podman/).

## Le problème

Un outil de sécu à la traîne = **zéro sécu**. Les collections/rules évoluent tous les jours. Faut-il checker manuellement ? **Nope.**

## La solution : systemd timer

**3 fichiers, 2 minutes chrono.** CrowdSec se met à jour tout seul, tous les jours.

### 1. Le service (`/etc/systemd/system/crowdsec-hub-update.service`)
```ini
[Unit]
Description=CrowdSec Hub upgrade
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/cscli hub update
ExecStart=/usr/bin/cscli hub upgrade
ExecStart=/usr/bin/systemctl reload crowdsec
```

### 2. Le timer (`/etc/systemd/system/crowdsec-hub-update.timer`)
```ini
[Unit]
Description=CrowdSec Hub daily upgrade

[Timer]
OnCalendar=daily
RandomizedDelaySec=1h
Persistent=true

[Install]
WantedBy=timers.target
```

### 3. Activation
```bash
sudo systemctl enable --now crowdsec-hub-update.timer
```

**Vérification** :
```bash
systemctl list-timers | grep crowdsec
# → Prochain run : demain 14h37 (random ±1h)
```

## Résultat

**CrowdSec** toujours à jour, **zéro intervention manuelle**. Les nouvelles IP malveillantes, CVE, règles AppSec ? **Détectées dès le jour 1.**

> `journalctl -u crowdsec-hub-update.timer -f` pour suivre les mises à jour en live.

---
**Ka-chow** 🚀
