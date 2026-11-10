---
title: "IA locale avec Open WebUI"
date: 2026-11-09 22:26:00 Europe/Paris
description: "Retour d’expérience sur Open WebUI avec Ollama, une authentification OIDC via Pocket ID et un reverse proxy Caddy."
type: post
tags: open-web-ui,pocket-id,caddy,oidc,passkeys,home-server
slug: open-web-ui
---

Après avoir utilisé plusieurs services de chat IA, j’ai voulu mieux comprendre les interactions entre une interface et différents fournisseurs de modèles. J’ai donc installé Open WebUI sur mon serveur personnel, avec Ollama sur mon MacBook pour faire tourner des modèles localement.

La confidentialité n’est pas la raison de cette installation je me garde aussi la possibilité de connecter des fournisseurs cloud pour utiliser des modèles que mon grille-pain… pardon, mon home serveur ne pourrait pas faire tourner. Dans ce cas, les données envoyées au fournisseur quittent évidemment mon réseau.

## Architecture

J’ai choisi Open WebUI plutôt que LibreChat parce que l’intégration avec Ollama correspondait à mon besoin. Ce choix ne signifie pas que LibreChat se limite aux modèles cloud.

![Architecture reliant le navigateur à Open WebUI via Caddy, avec Pocket ID pour l’authentification et Ollama sur un MacBook. Les fournisseurs cloud restent optionnels.](/assets/diagrams/post/open-web-ui/architecture.svg)

Caddy reçoit les connexions HTTPS et les transmet à Open WebUI, installé dans un conteneur LXC sur Proxmox. Pocket ID gère l’authentification OIDC et les passkeys. Open WebUI contacte ensuite Ollama sur le MacBook via le réseau local ou un fournisseur cloud configuré séparément.

## Installation

Cette configuration suppose que Proxmox, Caddy et Pocket ID sont déjà en place, et que les services peuvent communiquer entre eux. Remplace les domaines et les valeurs entre chevrons par les tiens. Les exemples ci-dessous utilisent des domaines fictifs.

### Configurer Caddy

Je garde une configuration minimale pour le reverse proxy :

```caddyfile
openwebui.example.invalid {
    tls {
        dns duckdns {env.DUCKDNS_TOKEN}
    }

    reverse_proxy <OPEN_WEBUI_HOST>:8080
}
```

Le bloc `dns duckdns` correspond à mon usage de DuckDNS pour le challenge DNS des certificats ( adapte-le ou retire-le selon ton fournisseur et ta méthode de validation). Le module DNS DuckDNS doit être disponible dans ton installation de Caddy et le token doit être fourni à son environnement, sans être ajouté au fichier de configuration.

### Configurer Pocket ID

J’utilise déjà Pocket ID pour d’autres services. L’intégration OIDC me permet donc de réutiliser les comptes existants, notamment pour ma famille. Elle reste facultative si tu préfères gérer les comptes directement dans Open WebUI.

Crée un client OIDC dans Pocket ID et récupère son identifiant et son secret. Configure cette URL de redirection en remplaçant le domaine fictif :

```text
https://openwebui.example.invalid/oauth/oidc/callback
```

Associe au client le groupe autorisé à se connecter. Pocket ID gère les passkeys lors de l’authentification. Il n’est pas nécessaire d’ajouter une couche d’authentification OIDC dans Caddy pour ce parcours.

### Installer Open WebUI

Pour simplifier l’installation, j’ai utilisé le [script Open WebUI maintenu par la communauté Proxmox](https://community-scripts.org/scripts/openwebui), qui crée un conteneur LXC.
>Cette commande télécharge et exécute du code distant avec les droits de l’utilisateur courant.

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/openwebui.sh)"
```

Le script installe également une commande `update` dans le conteneur. Pour une mise à jour, sauvegarde d’abord le conteneur et les données, puis consulte les instructions proposées par cette commande.

### Activer l’authentification OIDC

Dans mon installation, la configuration d’Open WebUI se trouve dans le fichier `.env` du conteneur. Ajoute ou adapte les variables suivantes, sans publier le secret du client :

```dotenv
WEBUI_URL=https://openwebui.example.invalid
OPENID_REDIRECT_URI=https://openwebui.example.invalid/oauth/oidc/callback
OPENID_PROVIDER_URL=https://pocketid.example.invalid/.well-known/openid-configuration

OAUTH_CLIENT_ID=<CLIENT_ID>
OAUTH_CLIENT_SECRET=<CLIENT_SECRET>
OAUTH_PROVIDER_NAME=PocketID
OAUTH_SCOPES="openid email profile"
ENABLE_OAUTH_SIGNUP=true
```

L’URL de découverte ci-dessus suppose que Pocket ID est servi à la racine du domaine. Redémarre ensuite Open WebUI selon la méthode utilisée par ton installation et teste la connexion avec un compte Pocket ID autorisé. Vérifie aussi qu’un compte hors du groupe autorisé ne peut pas se connecter.

### Gérer le premier compte administrateur

Dans mon cas, j’avais créé un compte administrateur local avant d’activer OIDC. Après avoir donné les droits d’administration à mon compte Pocket ID et vérifié sa connexion, je souhaitais supprimer le compte local. L’interface ne me permettait pas de supprimer ce premier compte administrateur.

J’ai alors modifié son rôle et sa date de création directement dans la base SQLite. C’est une manipulation risquée et dépendante de la version d’Open WebUI : elle peut rendre la base incohérente ou compliquer la récupération du service. Je ne la recommande pas comme procédure générale. Avant toute intervention sur la base, vérifie les options prises en charge par ta version, arrête le service et réalise une sauvegarde restaurable. Conserver un compte local de secours peut aussi être utile si Pocket ID devient indisponible.

Une fois le compte Pocket ID administrateur vérifié, j’ai désactivé le formulaire de connexion local dans **Settings > Authentication > Login Form**. 
>Attention : cela retire aussi cette voie d’accès en cas de panne OIDC.

## Faire tourner les modèles avec Ollama

L’interface et l’authentification sont en place, mais il faut encore un moteur et un modèle pour discuter. J’utilise Ollama sur mon MacBook pour sa simplicité et son fonctionnement sans interface graphique.

### Installer et configurer Ollama sur macOS

Installe Ollama avec Homebrew :

```bash
brew install ollama
```

Pour qu’Open WebUI puisse le joindre, Ollama doit écouter sur une adresse accessible depuis le conteneur, et pas seulement sur l’interface locale du MacBook. Dans ma configuration, les variables à adapter sont les suivantes :

```dotenv
OLLAMA_HOST=0.0.0.0
OLLAMA_ORIGINS=https://openwebui.example.invalid
```

`0.0.0.0` expose le service sur toutes les interfaces réseau du MacBook : préfère une adresse spécifique si possible et filtre les accès réseau. `OLLAMA_ORIGINS` concerne les origines autorisées pour les requêtes des navigateurs. Ce n’est ni une authentification ni un pare-feu, et cela ne protège pas l’API contre les clients réseau.

Le chargement des variables dépend de la manière dont le service Ollama est lancé. La présence d’un fichier `~/.homebrew/services/ollama.env` ne garantit pas que Homebrew le charge : ce point reste à vérifier pour la version et le service utilisés. Vérifie la méthode propre à ton installation, redémarre le service, puis contrôle son adresse d’écoute avant de continuer. Assure-toi également qu’un modèle est disponible dans Ollama.

### Configurer le pare-feu macOS

Sur mon MacBook Apple Silicon, j’ai ajouté Ollama au pare-feu applicatif et autorisé les connexions entrantes :

```bash
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /opt/homebrew/bin/ollama
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp /opt/homebrew/bin/ollama
```

Vérifie ensuite son état :

```bash
/usr/libexec/ApplicationFirewall/socketfilterfw --getappblocked /opt/homebrew/bin/ollama
```

Le chemin `/opt/homebrew/bin/ollama` dépend de l’installation Homebrew.
>Cette autorisation concerne l’application, pas uniquement Open WebUI : utilise aussi les règles réseau disponibles pour limiter les clients qui peuvent joindre le port `11434`.

### Garder Ollama disponible sur le réseau local

Mon MacBook dispose d’une adresse IP fixe sur le réseau local. Pour qu’Ollama reste accessible même lorsque je n’utilise pas le MacBook, j’utilise [Amphetamine](https://apps.apple.com/us/app/amphetamine/id937984704) pour empêcher la mise en veille de la machine tout en laissant l’écran s’éteindre.

Ce choix consomme de l’énergie et suppose que le MacBook reste allumé et connecté au réseau. S’il dort ou s’il est éteint, les modèles locaux ne seront pas disponibles.

### Relier Open WebUI à Ollama

Dans Open WebUI, ouvre **Settings > AI > Connections > Manage Ollama API Connections**, puis ajoute l’URL suivante en remplaçant l’adresse par celle du MacBook :

```text
http://<MACBOOK_IP>:11434
```

## Limites de sécurité

- N’expose pas directement le port Ollama `11434` sur Internet. Limite son accès aux machines autorisées du réseau local : le filtrage des origines navigateur ne remplace pas un contrôle d’accès.
- Limite les flux entre Caddy et Open WebUI ainsi qu’entre Open WebUI et Ollama, notamment avec les règles de pare-feu Proxmox et celles du réseau.
- Protège le secret OIDC et limite les ports exposés. L’accès à un modèle local ne garantit pas la confidentialité si tu sélectionnes ensuite un fournisseur cloud.

Cette installation me donne une interface commune pour mes modèles locaux, avec la possibilité d’ajouter des fournisseurs externes. Le compromis reste la disponibilité du MacBook et de Pocket ID.

**Ka-chow** 🚀
