---
title: Socket Activation avec Caddy et Podman
layout: default
date: 2026-02-01
parent: 📖 Presque une doc
categories: [docs]
tags: [podman, socket, caddy]
last_modified_date: 2026-02-01
---

## Petit aparté

J'ai récemment changé tout mon setup de mon home serveur. Je vous ferai bientôt un article sur pourquoi j'ai changé d'OS et pourquoi Podman.

Bon, revenons à nos problèmes.

# Socket Activation avec Caddy et Podman : Préserver l'IP source en rootless

## Le problème

Lorsqu'on utilise **Caddy dans un conteneur Podman rootless**, on rencontre un problème majeur : **l'IP source du client n'est pas préservée**.

### Symptômes

```bash
# Dans les logs Caddy, on voit toujours une IP Docker interne
"remote_ip": "10.89.0.6"  # ❌ IP du bridge Podman, pas du client réel
```

**Conséquences** :
- Impossible de filtrer les accès par IP (LAN vs Internet)
- Les logs ne montrent pas les vraies IPs des visiteurs
- Les directives Caddy comme `remote_ip` ne fonctionnent pas correctement

### Pourquoi ce problème ?

En mode **rootless**, Podman utilise **Pasta** (ou Slirp4netns) pour le réseau. Ce système fait du NAT qui ne préserve pas l'IP source.

```
Internet → Box → Pasta NAT (10.89.0.x) → Caddy
                       ↑
               IP source perdue ici
```

## La solution : Socket Activation avec systemd

La **socket activation** permet à systemd d'ouvrir les ports 80/443 **avant** de démarrer le conteneur, puis de passer les sockets directement à Caddy via des file descriptors. Le trafic ne passe plus par Pasta, donc **l'IP source est préservée**. [Documentation Caddy](https://caddyserver.com/docs/caddyfile/matchers)

```
Internet → Box → Systemd Socket → File Descriptor → Caddy
                                        ↑
                            IP source préservée !
```

## Configuration complète

### Prérequis

```bash
# Activer le lingering pour que les services utilisateur persistent
loginctl enable-linger $USER

# Créer les répertoires nécessaires
mkdir -p ~/.config/systemd/user
mkdir -p ~/.config/containers/systemd
```

### 1. Fichier socket : `~/.config/systemd/user/caddy.socket`

```ini
[Socket]
BindIPv6Only=both

# fd/3 - Port 80 TCP
ListenStream=[::]:80

# fd/4 - Port 443 TCP
ListenStream=[::]:443

# fdgram/5 - Port 443 UDP (HTTP/3)
ListenDatagram=[::]:443

[Install]
WantedBy=sockets.target
```

**Explication** :
- `BindIPv6Only=both` : Support IPv4 et IPv6
- Les sockets sont mappés sur des file descriptors (fd/3, fd/4, fdgram/5)
- Systemd écoute sur les ports, pas Podman

### 2. Fichier Quadlet : `~/.config/containers/systemd/caddy.container`

```ini
[Unit]
AssertPathIsDirectory=/votre_path
AssertPathExists=/votre_path/Caddyfile

[Service]
ExecReload=podman exec caddy /usr/bin/caddy reload --config /etc/caddy/Caddyfile --force

[Container]
ContainerName=caddy
Exec=/usr/bin/caddy run --config /etc/caddy/Caddyfile
Image=localhost/caddy-duckdns:latest
Environment=DUCKDNS_API_TOKEN=votre_token_ici
Network=caddy-bridge
NoNewPrivileges=true
Notify=true
ReadOnly=true
Volume=/votre_path/Caddyfile:/etc/caddy/Caddyfile:Z,ro
Volume=/votre_path/data:/data:Z
Volume=/votre_path/config:/config:Z
```

**Points clés** :
- **Pas de `PublishPort`** : Les ports sont gérés par le socket systemd
- `ReadOnly=true` : Sécurité renforcée
- `Notify=true` : Support de la notification systemd

### 3. Caddyfile : `/votre_path/Caddyfile`

Voici un exemple de Caddyfile complet avec DuckDNS et un reverse proxy vers Jellyfin :

```caddyfile
{
    # Bind par défaut pour HTTPS (TCP)
    default_bind fd/4 {
        protocols h1 h2
    }

    # Bind par défaut pour HTTP/3 (UDP)
    default_bind fdgram/5 {
        protocols h3
    }
}

# Bloc HTTP pour redirection
http:// {
    bind fd/3 {
        protocols h1
    }

    redir https://{host}{uri}
    log
}

# Configuration TLS avec DNS challenge DuckDNS
(duckdns_tls) {
    tls {
        dns duckdns {env.DUCKDNS_API_TOKEN}
    }
}

# Filtre pour autoriser uniquement le réseau local
(lan_only) {
    @denied not remote_ip private_ranges 2001:861:514c:dd50::/64
    abort @denied
}

# Site principal
votre-domaine.duckdns.org {
    import duckdns_tls
    import lan_only
    respond "Home Server" 200
    log
}

# Reverse proxy vers Jellyfin
jellyfin.votre-domaine.duckdns.org {
    import duckdns_tls
    import lan_only
    reverse_proxy jellyfin:8096
    log
}
```

**Explication des file descriptors** ([source](https://github.com/eriksjolund/podman-caddy-socket-activation)) :
- `fd/3` : 1er `ListenStream` → Port 80 TCP
- `fd/4` : 2ème `ListenStream` → Port 443 TCP
- `fdgram/5` : 1er `ListenDatagram` → Port 443 UDP (HTTP/3)

## Déploiement

```bash
# Recharger systemd pour prendre en compte les nouveaux fichiers
systemctl --user daemon-reload

# Activer et démarrer le socket
systemctl --user enable caddy.socket
systemctl --user start caddy.socket

# Vérifier que systemd écoute bien sur les ports
sudo ss -tlnp | grep -E ':(80|443)'
```

Résultat attendu :
```
LISTEN  0  4096  [::]:80   [::]:*  users:(("systemd",pid=XXX))
LISTEN  0  4096  [::]:443  [::]:*  users:(("systemd",pid=XXX))
```

## Test et vérification

### Tester l'accès

Ouvrir un navigateur : `https://votre-domaine.duckdns.org`

Le socket démarrera automatiquement Caddy à la première connexion.

### Vérifier que l'IP source est préservée

Modifier temporairement le Caddyfile :

```caddyfile
votre-domaine.duckdns.org {
    import duckdns_tls
    respond "IP: {remote_ip}" 200
    log
}
```

Recharger :
```bash
systemctl --user reload caddy.service
```

Accéder depuis le navigateur : vous devriez voir votre **vraie IP**, pas `10.89.0.x` !

### Consulter les logs

```bash
# Logs en temps réel
journalctl --user -u caddy.service -f

# Logs d'accès HTTP uniquement
journalctl --user -u caddy.service | grep "http.log.access"
```

## Commandes utiles

```bash
# Redémarrer Caddy
systemctl --user restart caddy.service

# Recharger le Caddyfile sans redémarrer
systemctl --user reload caddy.service

# Voir le statut du socket
systemctl --user status caddy.socket

# Arrêter tout
systemctl --user stop caddy.socket
```

## Dépannage

### Le filtre `lan_only` bloque tout

Si vous avez une IPv6 préfixée par votre box comme moi, ajoutez votre réseau local au filtre :

```caddyfile
(lan_only) {
    @denied not remote_ip private_ranges 2001:861:514c:dd50::/64
    abort @denied
}
```

Remplacez `2001:861:514c:dd50::/64` par votre propre préfixe IPv6.

## Avantages de cette solution

✅ **IP source préservée** → Filtrage IP fonctionnel
✅ **Rootless** → Pas besoin de droits root
✅ **Démarrage à la demande** → Économie de ressources
✅ **Sécurité renforcée** → ReadOnly, NoNewPrivileges
✅ **Gestion systemd** → Logs, auto-restart, persistence au boot

## Conclusion

La socket activation est une solution professionnelle pour utiliser Caddy en Podman rootless tout en préservant l'IP source. C'est plus complexe qu'un simple `PublishPort`, mais c'est une configuration robuste, sécurisée et maintenable pour un serveur domestique ou de production.

---

Voilà, j'espère que ce petit article pourra aider, car j'aurais bien aimé l'avoir sous la main. Cela permet de garder le mode rootless, ce qui est important pour la sécurité.

Un grand merci à [eriksjolund](https://github.com/eriksjolund/podman-caddy-socket-activation/tree/main/examples/example4), dont l'exemple 4 correspondait parfaitement à mon problème.

Ka-chow 🚀
