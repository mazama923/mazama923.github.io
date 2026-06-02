---
title: "Remplacer les DNS de son FAI par un serveur local (Unbound + Dnsmasq)"
layout: default
date: 2026-05-20
parent: 📖 Presque une doc
categories: [docs, réseau]
tags: [dns, unbound, dnsmasq, privacy, ipv6, quad9]
last_modified_date: May 20 2026
---

# 🏠 Pourquoi et comment j’ai remplacé les DNS de mon FAI par un serveur local

Dans cet article, nous allons explorer comment configurer un serveur DNS local en utilisant Dnsmasq et Unbound. Cela permet de contourner les DNS de votre FAI, améliorant ainsi la confidentialité et la performance de votre réseau local.

## Introduction : Pourquoi contourner les DNS de son FAI ?

Les DNS (Domain Name System) sont essentiels pour naviguer sur Internet, mais ceux fournis par votre FAI peuvent poser des problèmes de confidentialité et de performance. En utilisant un serveur DNS local, vous pouvez améliorer la sécurité et la rapidité de votre connexion Internet.

Comme beaucoup d’entre vous, j’ai un abonnement internet chez Bouygues Telecom, et comme beaucoup, je n’apprécie pas que mon fournisseur d’accès m’impose ses propres serveurs DNS. Ces serveurs peuvent :

- **Limiter la confidentialité** : Mon FAI peut logger toutes mes requêtes DNS et les croiser avec mon adresse IP.
- **Censurer certains sites** : Certains FAI bloquent l’accès à des domaines (piratage, contenus illégaux, etc.) sans transparence.
- **Ralentir la navigation** : Les DNS des FAI sont souvent moins performants que des alternatives comme Quad9, Cloudflare ou Google DNS.
- **Forcer l’IPv6** : La Bbox annonce ses propres DNS IPv6 via les *Router Advertisements* (RA), ce qui contourne mes paramètres locaux.

Pour reprendre le contrôle, j’ai décidé de désactiver le DHCP de ma Bbox et de le remplacer par un serveur local sur un **ZimaBoard** (un mini-PC sous Fedora 43). Ce serveur gère :

- **Le DHCPv4 et DHCPv6** : Pour attribuer des adresses IP à tous mes appareils.
- **Un cache DNS local** : Avec **Unbound**, pour accélérer les requêtes et bloquer les publicités.
- **Le chiffrement DNS** : Via **DNS-over-TLS (DoT)** vers Quad9, pour éviter l’espionnage.
- **La résolution locale** : Pour mon réseau Tailscale (`.ts.net`) et mes services internes.

## Pourquoi Unbound + Dnsmasq ? Comparaison avec les alternatives

Unbound est un résolveur DNS récursif qui peut être configuré pour utiliser DNS-over-TLS (DoT) pour une meilleure confidentialité. Dnsmasq, quant à lui, est un serveur DNS et DHCP léger qui peut être utilisé pour gérer les requêtes DNS locales et attribution d'adresses IP dans votre réseau local. Cette combinaison offre une solution robuste et flexible pour gérer vos besoins DNS locaux.

J’ai testé plusieurs solutions avant de choisir cette stack :

| Solution          | Avantages                                                                 | Inconvénients                                                                                     |
|-------------------|---------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------|
| **Pi-hole**       | Interface web intuitive, gestion fine des blocages, stats détaillées.     | Lourd pour un petit serveur, dépendances nombreuses, pas optimisé pour IPv6.                     |
| **AdGuard Home**  | Similaire à Pi-hole, mais plus léger et avec plus de fonctionnalités.     | Toujours plus complexe qu’un simple fichier de config, pas de cache DNS natif.                  |
| **Technitium**    | Très complet, supporte DoH/DoT, interface moderne.                        | Surdimensionné pour mon besoin, nécessite une base de données.                                  |
| **Unbound + Dnsmasq** | **Léger et minimaliste** : Deux fichiers de config, pas d'interface web. | **Configuration manuelle** : Pas de dashboard pour visualiser les stats.                        |
|                   | **Optimisé pour IPv6** : Gère nativement le DHCPv6 et les annonces RA.    | **Pas de blocage granulaire** : Liste de blocage globale (pas de whitelist par appareil).       |
|                   | **Cache DNS natif** : Unbound est un résolveur complet, pas juste un proxy. | **Pas de gestion centralisée** : Chaque modification nécessite un redémarrage.                  |
|                   | **Chiffrement DNS** : Supporte nativement DoT (DNS-over-TLS).             |                                                                                                   |
|                   | **Indépendant** : Pas de dépendance à une base de données ou un service externe. |                                                                                                   |

**Mon choix s'est porté sur Unbound + Dnsmasq pour sa simplicité et son efficacité.** Je voulais une solution qui tienne dans quelques fichiers de configuration, sans dépendre d'une base de données ou d'une interface web. De plus, cette stack gère parfaitement l'IPv6, ce qui est crucial pour moi : je ne veux pas désactiver l'IPv6 sur mes appareils (comme mon Mac), car cela peut casser certains services modernes ou réduire les performances.

## Architecture globale

L'architecture globale de notre solution DNS locale comprend les composants suivants :

1. **Dnsmasq** : Gère les requêtes DNS locales et l'attribution d'adresses IP via DHCP.
2. **Unbound** : Résout les requêtes DNS externes en utilisant DNS-over-TLS pour une meilleure confidentialité.
3. **Tailscale** : Pour les connexions sécurisées à distance.





Voici l'architecture de mon infrastructure réseau locale :

```
┌───────────────────────────────────────────────────────────────────────────────┐
│                                                                               │
│   INTERNET                                                                    │
│     │                                                                         │
│     ▼                                                                         │
│  ┌─────────────┐                     ┌───────────────────────────────────┐    │
│  │             │                     │                               │    │
│  │   Bbox      │                     │          ZimaBoard             │    │
│  │ 192.168.1.254│────────────────────▶│ 192.168.1.1 (Fedora 43)        │    │
│  │ DHCP: OFF   │                     │                               │    │
│  │ IPv6: OFF   │                     │  ┌─────────────┐  ┌───────────┐  │    │
│  └─────────────┘                     │  │ Dnsmasq     │  │ Unbound   │  │    │
│                                      │  │ - DHCPv4    │  │ - Cache   │  │    │
│                                      │  │ - DHCPv6    │  │ - DoT     │  │    │
│                                      │  │ - RA/SLAAC  │  │ - Adblock │  │    │
│                                      │  └─────────────┘  └───────────┘  │    │
│                                      └───────────┬───────────────┘    │
│                                                  │                    │
│                                                  ▼                    │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │                                                                 │  │
│  │                     APPAREILS LOCAUX                            │  │
│  │  (Smartphone, PC, Raspberry Pi, etc.)                          │  │
│  │                                                                 │  │
│  │  - IP: 192.168.1.50-200 (IPv4)                                 │  │
│  │  - IP: [Préfixe IPv6]/64 (IPv6)                                │  │
│  │  - DNS: 192.168.1.1 (IPv4)                                     │  │
│  │  - DNS: fe80::1996:7a65:9450:d0be (IPv6)                       │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                  │                    │
│                                                  ▼                    │
│  ┌─────────────┐                     ┌───────────────────────────────┐    │
│  │             │                     │                               │    │
│  │  Quad9      │◀────────────────────│          ZimaBoard             │    │
│  │ 9.9.9.9     │   DNS-over-TLS      │                               │    │
│  │ 149.112.112.112│◀────────────────────│                               │    │
│  └─────────────┘                     └───────────┬───────────────┘    │
│                                                  │                    │
│                                                  ▼                    │
│                                      ┌─────────────────────┐          │
│                                      │                     │          │
│                                      │    Tailscale       │          │
│                                      │ 100.x.x.x (MagicDNS)│          │
│                                      │                     │          │
│                                      └─────────────────────┘          │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
```

### Détail des flux :

1. **Flux Internet** :
   ```
   Internet → Bbox (passerelle) → ZimaBoard → Appareils locaux
   ```

2. **Flux DHCP** :
   ```
   ZimaBoard (Dnsmasq) → Appareils locaux
   │
   ├─ Attribution IPv4 (192.168.1.50-200)
   ├─ Annonce passerelle (192.168.1.254)
   ├─ Annonce DNS IPv4 (192.168.1.1)
   └─ Annonce DNS IPv6 (fe80::1996:7a65:9450:d0be)
   ```

3. **Flux DNS** :
   ```
   Appareils locaux → ZimaBoard (Unbound) → Quad9 (DoT)
   │
   ├─ Requêtes normales : Résolues via Quad9 (chiffrées)
   ├─ Requêtes .ts.net : Redirigées vers Tailscale
   └─ Domaines malveillants : Bloqués par la liste Adblock
   ```

4. **Flux Tailscale** :
   ```
   Appareils locaux → ZimaBoard (Unbound) → Tailscale (MagicDNS)
   ```

### Rôles des composants :

| Composant       | Rôle                                                                 | IP/Configuration               |
|-----------------|----------------------------------------------------------------------|---------------------------------|
| **Bbox**       | Passerelle vers Internet (DHCP/IPv6 désactivés)                     | 192.168.1.254                  |
| **ZimaBoard**   | Serveur DHCP + DNS local                                            | 192.168.1.1                    |
| - Dnsmasq      | Gestion du DHCPv4/DHCPv6 et annonces RA                             | Port: 0 (DNS désactivé)        |
| - Unbound      | Résolveur DNS + cache + Adblock + DoT                                | Port: 53                       |
| **Quad9**       | Résolveur DNS public avec chiffrement (DoT) et protection malware   | 9.9.9.9, 149.112.112.112      |
| **Tailscale**   | Réseau VPN overlay avec résolution MagicDNS                         | 100.x.x.x                      |
| **Appareils**   | Clients du réseau local                                             | IP: 192.168.1.50-200          |

## Prérequis

Avant de commencer, assurez-vous d'avoir les éléments suivants :
- Un serveur local avec une distribution Linux (par exemple, Fedora).
- Des droits d'administration sur le serveur.
- Une connexion Internet stable.

Avant de commencer, assurez-vous d'avoir :

- Un **mini-PC** (ZimaBoard, Raspberry Pi, ou toute machine sous Linux).
- **Fedora 43** (ou une distribution Linux récente).
- Une **box Bouygues** (ou autre FAI, mais les commandes pour désactiver le DHCP/IPv6 peuvent varier).
- Un **accès SSH** à votre serveur pour copier-coller les commandes.
- **30 minutes** pour suivre ce guide tranquillement.

---

## Étape 0 : Neutralisation de la Bbox

Pour commencer, nous devons neutraliser les DNS de la Bbox pour éviter les conflits avec notre serveur DNS local. Voici les étapes à suivre :

1. Connectez-vous à l'interface d'administration de votre Bbox.
2. Naviguez vers les paramètres DNS.
3. Désactivez les DNS de la Bbox ou configurez-les pour utiliser l'adresse IP de votre serveur local.

La Bbox force l'annonce de ses DNS IPv6 sur le réseau. Pour éviter les fuites, il faut la neutraliser :

1. Depuis l'interface web de la Bbox (`192.168.1.254`), **désactivez le serveur DHCP**.
2. Depuis un terminal, désactivez l'IPv6 sur la Bbox via son API locale (remplacez `TON_MOT_DE_PASSE` par votre mot de passe) :

```bash
curl -k -XPOST https://mabbox.bytel.fr/api/v1/login --data-urlencode "password=TON_MOT_DE_PASSE" -c /tmp/token
curl -b /tmp/token -XPUT https://mabbox.bytel.fr/api/v1/lan/ip6 -d "enable=0"
```

⚠️ **Note importante** :
- Cette commande peut cesser de fonctionner après une mise à jour de la Bbox. Si l'IPv6 est réactivé, il faudra la relancer.
- Bouygues peut parfois réinitialiser ces paramètres lors des mises à jour majeures.
- Pour d'autres FAI, cherchez comment désactiver le DHCP et les annonces IPv6 dans l'interface d'administration.

---

## Étape 1 : Configuration de l'IP statique du serveur

Configurez une adresse IP statique pour votre serveur local. Cela garantit que votre serveur DNS sera toujours accessible à la même adresse IP.

1. Modifiez le fichier de configuration réseau de votre serveur.
2. Définissez une adresse IP statique pour votre serveur.
3. Redémarrez le service réseau pour appliquer les modifications.

On attribue une IP statique (`192.168.1.1`) à l'interface LAN du ZimaBoard (`enp2s0`) et on force Fedora à utiliser la boucle locale (`127.0.0.1`) pour ses requêtes DNS :

```bash
# Configuration de l'IP, masque et passerelle
sudo nmcli con mod "enp2s0" \
  ipv4.method manual \
  ipv4.addresses 192.168.1.1/24 \
  ipv4.gateway 192.168.1.254

# Forcer l'utilisation du DNS local et ignorer les serveurs du FAI
sudo nmcli con mod "enp2s0" \
  ipv4.dns 127.0.0.1 \
  ipv4.ignore-auto-dns yes

# Appliquer la configuration
sudo nmcli con up "enp2s0"
```

💡 **Explications** :
- `ipv4.method manual` : Configure une IP statique.
- `ipv4.addresses 192.168.1.1/24` : Définit l'IP et le masque de sous-réseau.
- `ipv4.gateway 192.168.1.254` : La Bbox reste la passerelle par défaut.
- `ipv4.dns 127.0.0.1` : Force le système à utiliser Unbound comme résolveur DNS.
- `ipv4.ignore-auto-dns yes` : Ignore les DNS annoncés par le FAI.

---



---



```bash
# 1. Installation des paquets
sudo dnf install -y dnsmasq unbound curl

# 2. Ouverture du pare-feu
# Autorise les services DNS, DHCPv4 et DHCPv6
sudo firewall-cmd --add-service={dns,dhcp,dhcpv6} --permanent
sudo firewall-cmd --reload

# 3. Désactiver le stub listener de systemd-resolved
# systemd-resolved écoute par défaut sur 127.0.0.53:53, ce qui bloque Unbound
sudo mkdir -p /etc/systemd/resolved.conf.d/
echo -e "[Resolve]\nDNSStubListener=no\nDNS=127.0.0.1" | sudo tee /etc/systemd/resolved.conf.d/unbound.conf

# 4. Configurer le résolveur DNS système
# On force le système à utiliser Unbound (127.0.0.1) comme résolveur
sudo rm -f /etc/resolv.conf
echo -e "nameserver 127.0.0.1\nsearch lan\nsearch taildd4706.ts.net" | sudo tee /etc/resolv.conf

# 5. Redémarrer systemd-resolved pour appliquer les changements
sudo systemctl restart systemd-resolved
```

🔍 **Explications détaillées** :

1. **Installation des paquets** :
   - `dnsmasq` : Serveur DHCP et DNS léger (ici utilisé uniquement pour le DHCP).
   - `unbound` : Résolveur DNS récursif avec support du cache et de DNS-over-TLS.
   - `curl` : Utilisé pour télécharger la liste de blocage des publicités.

2. **Pare-feu** :
   - `dns` : Autorise les requêtes DNS (port 53 UDP/TCP).
   - `dhcp` : Autorise les requêtes DHCPv4 (ports 67 et 68 UDP).
   - `dhcpv6` : Autorise les requêtes DHCPv6 (ports 546 et 547 UDP).

3. **systemd-resolved** :
   Par défaut, `systemd-resolved` écoute sur `127.0.0.53:53` et agit comme un *stub resolver*. Pour utiliser Unbound à la place :
   - On désactive `DNSStubListener` pour libérer le port 53.
   - On configure `systemd-resolved` pour utiliser `127.0.0.1` comme résolveur.

4. **Fichier `/etc/resolv.conf`** :
   - `nameserver 127.0.0.1` : Utilise Unbound comme résolveur DNS.
   - `search lan` : Ajoute le domaine `.lan` aux requêtes non qualifiées (ex: `ping serveur` → `ping serveur.lan`).
   - `search taildd4706.ts.net` : Permet de résoudre les noms Tailscale sans suffixe.

⚠️ **Problèmes courants** :
- Si `systemctl restart systemd-resolved` échoue, vérifiez que le fichier `/etc/resolved.conf.d/unbound.conf` est correct.
- Si le pare-feu bloque les requêtes, vérifiez les règles avec `sudo firewall-cmd --list-all`.

---

## Étape 3 : Configuration de Dnsmasq (DHCPv4 & IPv6)

Dnsmasq va gérer :
- **L'attribution des adresses IPv4** (plage `192.168.1.50` à `192.168.1.200`).
- **Les annonces Router Advertisements (RA)** pour l'IPv6 (SLAAC).
- **La diffusion de l'IP du serveur DNS local** (`192.168.1.1` pour IPv4 et `fe80::1996:7a65:9450:d0be` pour IPv6).

Voici le fichier de configuration (`/etc/dnsmasq.conf`) :

```bash
sudo tee /etc/dnsmasq.conf > /dev/null << 'EOF'
# Désactiver la fonction DNS de Dnsmasq (la résolution DNS est gérée par Unbound)
port=0
interface=enp2s0
bind-dynamic

# --- DHCP IPv4 ---
# Plage d'adresses IPv4 à attribuer (de 192.168.1.50 à 192.168.1.200)
# Masque de sous-réseau : 255.255.255.0, durée de bail : 24h
dhcp-range=192.168.1.50,192.168.1.200,255.255.255.0,24h

# Option 3 : Passerelle par défaut (Bbox)
dhcp-option=3,192.168.1.254

# Option 6 : Serveur DNS (ZimaBoard)
dhcp-option=6,192.168.1.1

# --- IPv6 (SLAAC / RA) ---
# Activer les annonces Router Advertisements (RA)
enable-ra

# Annonce dynamique du préfixe IPv6 depuis l'interface enp2s0
# ra-names : Génère des noms DNS pour les clients IPv6
# slaac : Utilise SLAAC pour l'auto-configuration IPv6
# 64 : Longueur du préfixe
# 24h : Durée de validité des annonces
dhcp-range=::,constructor:enp2s0,ra-names,slaac,64,24h

# Annonce l'IP Link-Local du ZimaBoard comme DNS IPv6
# option6:dns-server : Définit le serveur DNS IPv6 pour les clients
dhcp-option=option6:dns-server,[fe80::1996:7a65:9450:d0be]

# Journalisation
log-queries    # Journalise les requêtes DNS (désactivé ici car port=0)
log-dhcp       # Journalise les requêtes DHCP
log-facility=/var/log/dnsmasq.log  # Fichier de log
EOF

# Activer et démarrer Dnsmasq
sudo systemctl enable --now dnsmasq
sudo systemctl restart dnsmasq
```

🔍 **Explications détaillées** :

1. **Désactivation du DNS** :
   - `port=0` : Désactive le serveur DNS de Dnsmasq (Unbound s'en charge).
   - `interface=enp2s0` : Écoute uniquement sur l'interface LAN.
   - `bind-dynamic` : Permet de binder dynamiquement les interfaces.

2. **DHCPv4** :
   - `dhcp-range=192.168.1.50,192.168.1.200,255.255.255.0,24h` : Définit la plage d'adresses IPv4 à attribuer.
   - `dhcp-option=3,192.168.1.254` : Annonce la Bbox comme passerelle par défaut.
   - `dhcp-option=6,192.168.1.1` : Annonce le ZimaBoard comme serveur DNS.

3. **IPv6 (SLAAC/RA)** :
   - `enable-ra` : Active les annonces *Router Advertisements* pour l'auto-configuration IPv6 (SLAAC).
   - `dhcp-range=::,constructor:enp2s0,ra-names,slaac,64,24h` :
     - `constructor:enp2s0` : Utilise le préfixe IPv6 de l'interface `enp2s0`.
     - `ra-names` : Génère des noms DNS pour les clients IPv6 (ex: `client-[MAC].lan`).
     - `slaac` : Utilise SLAAC pour attribuer des adresses IPv6.
     - `64` : Longueur du préfixe IPv6.
     - `24h` : Durée de validité des annonces.
   - `dhcp-option=option6:dns-server,[fe80::1996:7a65:9450:d0be]` : Annonce l'IP Link-Local du ZimaBoard comme serveur DNS IPv6.

4. **Journalisation** :
   - `log-dhcp` : Journalise les requêtes DHCP (utile pour le débogage).
   - `log-facility=/var/log/dnsmasq.log` : Redirige les logs vers un fichier dédié.

💡 **Pourquoi utiliser l'IP Link-Local pour IPv6 ?**
L'IP Link-Local (`fe80::...`) est générée automatiquement à partir de l'adresse MAC de l'interface. Elle présente plusieurs avantages :
- **Stabilité** : Elle ne change pas, même si le préfixe IPv6 global est modifié par le FAI.
- **Accessibilité** : Elle est toujours accessible sur le réseau local, sans dépendre d'une configuration manuelle.
- **Simplicité** : Pas besoin de configurer une IP globale statique pour le DNS.

⚠️ **Problèmes courants** :
- Si les clients ne reçoivent pas d'adresse IPv6, vérifiez que le préfixe IPv6 est bien annoncé par la Bbox (même si le DHCPv6 est désactivé).
- Si les logs de Dnsmasq (`/var/log/dnsmasq.log`) ne s'affichent pas, vérifiez les permissions du fichier ou redémarrez le service avec `sudo systemctl restart dnsmasq`.

---

## Étape 4 : Configuration de Unbound (Résolveur DNS, DoT, Tailscale)

Unbound va jouer plusieurs rôles clés :
- **Résolveur DNS récursif** : Il interroge les serveurs DNS racines pour résoudre les noms de domaine.
- **Cache DNS** : Il stocke les réponses pour accélérer les requêtes suivantes.
- **Bloqueur de publicités** : Via une liste de blocage intégrée.
- **Proxy DNS-over-TLS (DoT)** : Il chiffre les requêtes vers Quad9 pour éviter l'espionnage.
- **Résolution locale** : Pour les noms Tailscale (`.ts.net`) et les services internes.

### Génération des certificats pour le contrôle distant

Avant de configurer Unbound, générons les certificats nécessaires pour le contrôle distant (utile pour recharger la configuration sans redémarrer le service) :

```bash
sudo unbound-control-setup
```

### Fichier de configuration principal

Voici le fichier de configuration (`/etc/unbound/unbound.conf`) :

```bash
sudo tee /etc/unbound/unbound.conf > /dev/null << 'EOF'
server:
    # Désactiver le chroot pour simplifier la configuration
    chroot: ""

    # Interfaces d'écoute (IPv4 et IPv6)
    interface: 0.0.0.0
    interface: ::0
    port: 53

    # Niveau de verbosité et journalisation
    verbosity: 1
    use-syslog: yes
    log-queries: yes      # Journalise toutes les requêtes DNS
    log-replies: yes      # Journalise les réponses
    log-local-actions: yes
    log-servfail: yes     # Journalise les erreurs SERVFAIL

    # Contrôle d'accès (ACL) : Qui peut interroger le DNS ?
    access-control: 127.0.0.0/8 allow          # Boucle locale
    access-control: 192.168.1.0/24 allow       # Réseau local IPv4
    access-control: fe80::/10 allow            # Réseau local IPv6 (Link-Local)
    access-control: 10.0.2.0/24 allow          # Passerelle Podman rootless (slirp4netns)
    access-control: 169.254.0.0/16 allow       # Plage utilisée par pasta (Podman)
    access-control: 10.88.0.0/16 allow         # Réseaux bridge de Podman
    access-control: 10.89.0.0/24 allow         # Réseau "caddy-bridge"
    access-control: 100.64.0.0/10 allow         # Réseau Tailscale
    access-control: 2001:861::/32 allow         # Préfixes IPv6 Bouygues Telecom

    # Résolution locale pour la Bbox
    local-data: "mabbox.bytel.fr. IN A 192.168.1.254"

    # Paramètres d'optimisation et de sécurité
    do-ip4: yes
    do-ip6: yes
    do-udp: yes
    do-tcp: yes
    hide-identity: yes    # Ne pas répondre aux requêtes CH TXT id.server
    hide-version: yes     # Ne pas révéler la version d'Unbound
    prefetch: yes         # Précharger les enregistrements avant expiration
    tls-cert-bundle: /etc/pki/tls/certs/ca-bundle.crt  # Certificats CA pour DoT
    
    # Fichier Adblock généré par Systemd
    include: "/etc/unbound/blocklist.conf"

# Règle pour Tailscale MagicDNS
# Redirige toutes les requêtes .ts.net vers le daemon Tailscale local
forward-zone:
    name: "ts.net."
    forward-addr: 100.100.100.100  # Adresse du daemon Tailscale

# Configuration DNS-over-TLS vers Quad9
# Toutes les autres requêtes sont envoyées vers Quad9 via DoT
forward-zone:
    name: "."  # Zone racine (tous les domaines)
    forward-tls-upstream: yes  # Active DNS-over-TLS
    # Serveurs Quad9 (IPv4 et IPv6)
    forward-addr: 9.9.9.9@853#dns.quad9.net
    forward-addr: 149.112.112.112@853#dns.quad9.net
    forward-addr: 2620:fe::fe@853#dns.quad9.net
    forward-addr: 2620:fe::9@853#dns.quad9.net

# Contrôle distant (pour recharger la configuration sans redémarrer)
remote-control:
    control-enable: yes
    control-interface: 127.0.0.1
    control-port: 8953
    server-key-file: "/etc/unbound/unbound_server.key"
    server-cert-file: "/etc/unbound/unbound_server.pem"
    control-key-file: "/etc/unbound/unbound_control.key"
    control-cert-file: "/etc/unbound/unbound_control.pem"
EOF

# Créer un fichier de blocage vide pour le premier démarrage
sudo touch /etc/unbound/blocklist.conf

# Vérifier la configuration
sudo unbound-checkconf

# Activer et démarrer Unbound
sudo systemctl enable --now unbound
sudo systemctl restart unbound
```

🔍 **Explications détaillées** :

1. **Section `server`** :
   - `chroot: ""` : Désactive le *chroot* pour simplifier la configuration (optionnel, mais utile pour le débogage).
   - `interface: 0.0.0.0` et `interface: ::0` : Écoute sur toutes les interfaces (IPv4 et IPv6).
   - `port: 53` : Port DNS standard.
   - `verbosity: 1` : Niveau de journalisation (1 = minimal, 5 = très verbeux).
   - `log-queries: yes` : Journalise toutes les requêtes DNS (utile pour le débogage).

2. **Contrôle d'accès (`access-control`)** :
   Définit quels réseaux peuvent interroger Unbound. J'ai inclus :
   - Le réseau local (`192.168.1.0/24` et `fe80::/10`).
   - Les plages utilisées par Podman (`10.88.0.0/16`, `10.89.0.0/24`, etc.).
   - Le réseau Tailscale (`100.64.0.0/10`).
   - Les préfixes IPv6 de Bouygues Telecom (`2001:861::/32`).

3. **Résolution locale** :
   - `local-data: "mabbox.bytel.fr. IN A 192.168.1.254"` : Redirige `mabbox.bytel.fr` vers l'IP de la Bbox.
   - Le fichier `/etc/unbound/blocklist.conf` (généré automatiquement) bloque les domaines malveillants.

4. **Optimisation et sécurité** :
   - `prefetch: yes` : Précharge les enregistrements DNS avant leur expiration pour accélérer les requêtes.
   - `hide-identity: yes` et `hide-version: yes` : Masque des informations sensibles dans les réponses.
   - `tls-cert-bundle` : Chemin vers les certificats CA pour valider les connexions DoT.

5. **Forwarding zones** :
   - **Tailscale** : Toutes les requêtes pour `.ts.net` sont redirigées vers le daemon Tailscale local (`100.100.100.100`).
   - **Quad9** : Toutes les autres requêtes sont envoyées vers Quad9 via DNS-over-TLS (port 853).
     - `forward-tls-upstream: yes` : Active le chiffrement DoT.
     - `forward-addr: 9.9.9.9@853#dns.quad9.net` : Serveur Quad9 IPv4 avec vérification du nom TLS.

6. **Contrôle distant** :
   Permet de recharger la configuration sans redémarrer Unbound :
   ```bash
   sudo unbound-control reload
   ```

💡 **Pourquoi Quad9 ?**
J'ai choisi Quad9 pour plusieurs raisons :
- **Confidentialité** : Quad9 ne stocke pas les logs des requêtes DNS.
- **Sécurité** : Bloque automatiquement les domaines malveillants (phishing, malware, etc.).
- **Performances** : Serveurs rapides et bien répartis géographiquement.
- **Support DoT** : Chiffrement natif des requêtes DNS.

⚠️ **Problèmes courants** :
- Si Unbound ne démarre pas, vérifiez la configuration avec `sudo unbound-checkconf`.
- Si les requêtes DNS échouent, vérifiez que le port 53 n'est pas bloqué par le pare-feu (`sudo firewall-cmd --list-all`).
- Si les logs (`journalctl -u unbound`) montrent des erreurs DoT, vérifiez que le fichier `ca-bundle.crt` existe bien dans `/etc/pki/tls/certs/`.

---

## Étape 5 : Automatisation de l'Adblock (Systemd)

Pour bloquer les publicités, trackers et domaines malveillants, j'utilise une liste de blocage générée à partir des [hosts de StevenBlack](https://github.com/StevenBlack/hosts). Cette liste est mise à jour automatiquement chaque semaine via un service Systemd.

### Script de mise à jour

Voici le script qui télécharge la liste et la formate pour Unbound (`/usr/local/bin/update-unbound-adblock.sh`) :

```bash
sudo tee /usr/local/bin/update-unbound-adblock.sh > /dev/null << 'EOF'
#!/bin/bash
# Script pour mettre à jour la liste de blocage Unbound
# Source : https://github.com/StevenBlack/hosts

TMP_FILE="/tmp/hosts"
OUTPUT_FILE="/etc/unbound/blocklist.conf"

# Télécharger la liste de blocage
curl -sS https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts -o "$TMP_FILE"

# Formater la liste pour Unbound
# Chaque ligne "0.0.0.0 domaine.com" devient :
# local-zone: "domaine.com" redirect
# local-data: "domaine.com A 0.0.0.0"
echo "server:" > "$OUTPUT_FILE.tmp"
grep "^0\.0\.0\.0" "$TMP_FILE" | awk '{print "local-zone: \""$2"\" redirect"}' >> "$OUTPUT_FILE.tmp"
grep "^0\.0\.0\.0" "$TMP_FILE" | awk '{print "local-data: \""$2" A 0.0.0.0\""}' >> "$OUTPUT_FILE.tmp"

# Remplacer l'ancien fichier et nettoyer
mv "$OUTPUT_FILE.tmp" "$OUTPUT_FILE"
rm -f "$TMP_FILE"

# Recharger Unbound si la configuration est valide
unbound-checkconf && unbound-control reload
EOF

# Rendre le script exécutable
sudo chmod +x /usr/local/bin/update-unbound-adblock.sh
```

🔍 **Explications du script** :
- `curl -sS` : Télécharge la liste des hosts depuis GitHub.
- `grep "^0\.0\.0\.0"` : Filtre les lignes qui commencent par `0.0.0.0` (format des hosts bloqués).
- `awk` : Formate chaque ligne pour Unbound :
  - `local-zone: "domaine.com" redirect` : Redirige le domaine vers une zone locale.
  - `local-data: "domaine.com A 0.0.0.0"` : Associe le domaine à l'IP `0.0.0.0` (blocage).
- `unbound-checkconf && unbound-control reload` : Recharge Unbound si la configuration est valide.

### Service et Timer Systemd

Pour automatiser la mise à jour, créons un service et un timer Systemd :

```bash
# 1. Le Service (exécuté manuellement ou par le timer)
sudo tee /etc/systemd/system/unbound-adblock.service > /dev/null << 'EOF'
[Unit]
Description=Update Unbound Adblock List
After=network-online.target
Requires=network-online.target

[Service]
Type=oneshot
User=root
ExecStart=/usr/local/bin/update-unbound-adblock.sh
EOF

# 2. Le Timer (exécute le service tous les dimanches à 4h00)
sudo tee /etc/systemd/system/unbound-adblock.timer > /dev/null << 'EOF'
[Unit]
Description=Weekly update of Unbound Adblock List

[Timer]
OnCalendar=Sun *-*-* 04:00:00
RandomizedDelaySec=3600  # Évite les pics de charge
Persistent=true

[Install]
WantedBy=timers.target
EOF

# 3. Activation
sudo systemctl daemon-reload
sudo systemctl enable --now unbound-adblock.timer
# Exécuter une première fois pour générer la liste
sudo systemctl start unbound-adblock.service
```

💡 **Pourquoi un timer Systemd ?**
- **Fiabilité** : Systemd gère les dépendances (ex: attente que le réseau soit disponible).
- **Flexibilité** : On peut facilement modifier la fréquence de mise à jour.
- **Journalisation** : Les logs sont accessibles via `journalctl -u unbound-adblock.service`.
- **Robustesse** : Si le script échoue, Systemd peut le relancer automatiquement.

⚠️ **Problèmes courants** :
- Si le script échoue, vérifiez les logs avec `journalctl -u unbound-adblock.service`.
- Si la liste de blocage est vide, vérifiez que le téléchargement fonctionne (`curl -v https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts`).
- Si Unbound ne recharge pas la configuration, vérifiez que `unbound-control` est bien configuré (`sudo unbound-control status`).

---

## Étape 6 : Plan de test et validation

Voici comment vérifier que tout fonctionne correctement :

### 1. Tests DNS locaux

**Test de résolution DNS** :
```bash
# Résoudre un domaine public (doit retourner une IP)
dig @127.0.0.1 fedoraproject.org
```
→ **Résultat attendu** : Une réponse avec `status: NOERROR` et une IP publique (ex: `152.19.134.198`).

**Test de blocage des publicités** :
```bash
dig @127.0.0.1 doubleclick.net
```
→ **Résultat attendu** : `status: NXDOMAIN` (domaine bloqué).

**Test de résolution Tailscale** :
```bash
# Remplacez MACHINE_TAILSCALE par le nom d'une machine de votre réseau Tailscaleping MACHINE_TAILSCALE.ts.net
```
→ **Résultat attendu** : Résolution en `100.x.x.x` et réponse au ping.

### 2. Tests DHCP

**Vérification des baux DHCP** :
- Sur un smartphone ou un PC, oubliez puis reconnectez-vous au réseau Wi-Fi.
- Vérifiez que l'appareil reçoit :
  - Une IP dans la plage `192.168.1.50-200` (IPv4).
  - Une IP IPv6 avec le préfixe de votre FAI.
  - Le DNS `192.168.1.1` (IPv4) et `fe80::1996:7a65:9450:d0be` (IPv6).

**Sur Linux** :
```bash
# Vérifier les paramètres réseau
ip a       # Affiche les adresses IP
resolvectl status  # Affiche les serveurs DNS
```

**Sur Windows** :
```powershell
ipconfig /all
```

**Sur macOS** :
```bash
ifconfig | grep inet
scutil --dns
```

### 3. Test de fuite DNS

Pour vérifier que vos requêtes DNS ne fuient pas vers votre FAI :
1. Allez sur [dnsleaktest.com](https://dnsleaktest.com).
2. Lancez le **test étendu**.
3. **Résultat attendu** : Seul **Quad9** doit apparaître dans la liste.

📸 **Exemple de résultat** :
![Exemple de test DNS Leak](https://www.dnsleaktest.com/images/results-quad9.png)
*(Seul Quad9 doit apparaître, pas votre FAI.)*

### 4. Test de performance

**Mesurer le temps de réponse DNS** :
```bash
dig @127.0.0.1 fedoraproject.org | grep "Query time"
```
→ **Résultat attendu** : Un temps de réponse < 50ms après la première requête (grâce au cache).

**Comparaison avec les DNS du FAI** :
```bash
time dig @8.8.8.8 fedoraproject.org  # Google DNS
time dig @192.168.1.1 fedoraproject.org  # Votre Unbound
```
→ **Résultat attendu** : Votre Unbound doit être plus rapide après la première requête.

---

## Sécurité et maintenance

### CrowdSec pour surveiller les attaques

[CrowdSec](https://www.crowdsec.net/) est un outil qui analyse les logs et bloque les attaques (brute-force, scans, etc.). Voici comment le configurer pour surveiller Unbound et Dnsmasq :

```bash
# Configuration pour Unbound
sudo tee /etc/crowdsec/acquis.d/unbound.yaml > /dev/null << 'EOF'
journalctl_filter:
  - "_SYSTEMD_UNIT=unbound.service"
labels:
  type: unbound
EOF

# Configuration pour Dnsmasq
sudo tee /etc/crowdsec/acquis.d/dnsmasq.yaml > /dev/null << 'EOF'
filenames:
  - /var/log/dnsmasq.log
labels:
  type: dnsmasq
EOF

# Redémarrer CrowdSec
sudo systemctl restart crowdsec
```

🔍 **Que fait CrowdSec ?**
- Analyse les logs d'Unbound et Dnsmasq en temps réel.
- Détecte les comportements suspects (ex: requêtes DNS vers des domaines malveillants).
- Bloque les IP malveillantes au niveau du pare-feu.
- Partage les menaces avec la communauté CrowdSec (optionnel).

### Désactiver les DNS Tailscale

Pour éviter que Tailscale ne redirige les requêtes DNS vers ses propres serveurs :

```bash
sudo tailscale set --accept-dns=false
```

### Mises à jour régulières

Pensez à mettre à jour régulièrement votre système :
```bash
sudo dnf update -y
sudo systemctl restart unbound dnsmasq
```

### Rollback en cas de problème

Si le serveur tombe en panne ou si vous devez le débrancher, voici comment rétablir la connectivité :

1. **Sur le serveur** :
   ```bash
   sudo systemctl disable --now dnsmasq unbound unbound-adblock.timer
   ```

2. **Restaurer systemd-resolved** :
   ```bash
   sudo rm -f /etc/resolv.conf && sudo ln -rs /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf && sudo systemctl restart systemd-resolved
   ```

3. **Sur la Bbox** :
   - Réactivez le serveur DHCP depuis l'interface web (`192.168.1.254`).
   - Redémarrez la box électriquement pour relancer les annonces IPv6.

---

## Conclusion

Avec cette stack **Unbound + Dnsmasq**, j'ai repris le contrôle total sur mes DNS et mon DHCP, tout en gardant une solution légère et facile à maintenir. Voici les avantages que j'en retire :

✅ **Confidentialité** : Plus de logs chez mon FAI, mes requêtes DNS sont chiffrées (DoT).

✅ **Performance** : Le cache DNS local accélère la navigation.

✅ **Blocage des pubs** : Moins de trackers et de publicités intrusives.

✅ **IPv6 natif** : Pas besoin de désactiver l'IPv6 sur mes appareils.

✅ **Résolution locale** : Mes services Tailscale et locaux sont accessibles sans configuration manuelle.

✅ **Simplicité** : Tout tient dans quelques fichiers de configuration.

## Aller plus loin

Pour aller plus loin, vous pouvez consulter les articles suivants :
- [Utilisation des DNS locaux avec Podman en rootless](file:///Users/mazama/git_repo/perso/mazama923.github.io/docs/podman-dns/README.md)

Si vous voulez améliorer cette configuration, voici quelques idées :

1. **Ajouter un dashboard** :
   - Utilisez [Grafana + Prometheus](https://grafana.com/) pour visualiser les stats DNS (requêtes, temps de réponse, etc.).
   - Exemple de métriques à surveiller :
     - Nombre de requêtes bloquées par l'adblock.
     - Temps de réponse moyen.
     - Taux de cache hit/miss.

2. **Tester DNS-over-HTTPS (DoH)** :
   - Configurez Unbound pour utiliser DoH au lieu de DoT.
   - Exemple avec Cloudflare :
     ```
     forward-zone:
         name: "."
         forward-tls-upstream: no
         forward-addr: https://1.1.1.1/dns-query
     ```

3. **Ajouter un VPN** :
   - Chiffrez tout votre trafic avec WireGuard ou OpenVPN.
   - Exemple : [PiVPN](https://www.pivpn.io/) pour une configuration simple.

4. **Gestion centralisée** :
   - Utilisez Ansible pour déployer cette configuration sur plusieurs serveurs.
   - Exemple de playbook : [ansible-role-unbound](https://github.com/ansible-community/ansible-role-unbound).

5. **Blocage granulaire** :
   - Utilisez des listes de blocage différentes par appareil (via des tags DHCP).
   - Exemple : Bloquer les réseaux sociaux uniquement pour les enfants.

### Questions fréquentes

**Q : Puis-je utiliser cette configuration avec un autre FAI que Bouygues ?**
R : Oui ! La plupart des étapes sont génériques. Il faudra adapter :
- La désactivation du DHCP et de l'IPv6 sur votre box.
- Les plages d'IP si votre réseau local n'est pas en `192.168.1.0/24`.

**Q : Comment déboguer si ça ne marche pas ?**
R : Voici les commandes utiles :
```bash
# Vérifier les logs
journalctl -u unbound -f
journalctl -u dnsmasq -f

# Tester la connectivité
ping 192.168.1.1
ping6 fe80::1996:7a65:9450:d0be

# Vérifier les ports ouverts
ss -tulnp | grep -E "53|67|68|546|547"

# Tester la résolution DNS
dig @127.0.0.1 example.com
```

**Q : Puis-je utiliser un Raspberry Pi au lieu d'un ZimaBoard ?**
R : Oui ! Un Raspberry Pi 3/4/5 avec Raspberry Pi OS ou Ubuntu Server fera très bien l'affaire. Les performances seront suffisantes pour un usage domestique.

**Q : Comment ajouter un domaine local ?**
R : Ajoutez une ligne `local-data` dans `/etc/unbound/unbound.conf` :
```
local-data: "mon-serveur.lan. IN A 192.168.1.10"
```
Puis rechargez Unbound :
```bash
sudo unbound-control reload
```

---

**Et voilà, votre réseau est maintenant maître de son destin !**

N'hésite pas à adapter cette configuration à tes besoins. Si tu as des questions ou des suggestions, laisse un commentaire ou ouvre une issue sur [GitHub](https://github.com/mazama923/mazama923.github.io).

**Ka-chow** 🚀
