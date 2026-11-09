---
title: "IA locale avec OpenWebUI"
date: 2026-11-09 22:26:00
description: "Retour d’expérience sur l’installation d’OpenWebUI sur un serveur personnel avec authentification OIDC via PocketID et configuration de Caddy."
type: post
tags: open-web-ui,pocket-id,caddy,oidc,passkeys,home-server
slug: open-web-ui
---

Apres de monbreuse utilisation de chat IA avec de multiple services differents, J'ai voulu mieux comprendre comment cela fonctionne et comment fonctionne les interation avec les differents provider.

Meme si dans ce article je montre ma connection avec ollama, je ne fais pas cette installation pour avoir plus de privatie donc je ne me ferme pas le connecter a des provider de model frontiere que je ne pourrais pas faire tourner sur mon grille pain euuh mon home serveur.

## Architecture

J ai fait le choix d'OpenWebUi par rapport a librechat juste car je chercher quelle chose de deja prevue a etre conencter a ollama par rapport a librechat qui est plus prevu pour se connecter a des modeles cloud.

## Installation

### Configuration de Caddy

Plus tot simple je reste sur une config minal pour mon config caddy:

```bash
openwebui.<ton-domaine> {
	tls {
		dns duckdns {env.DUCKDNS_TOKEN} # Si tu utilise duckdns pour ton certificat
	}

	reverse_proxy <ip-de-ton-conteneur>:8080
}
```

### Configuration de PocketID

Pour ma part je vais utiliser PocketID pour l'authentification OIDC, car je l'utilise deja pour d'autre service et je peux donc me connecter avec mon compte existant.
Cette partie et pas obligatoire mais cela simplie grandement la gestion des comptes et de l'authentification pour toute la famille.

Avantage OpenWebUi supporte l'authentification OIDC avec les passkeys donc pas besoin de faire la configuration dans caddy on pourra l'ajouter directement dans OpenWebUI.

Du coup dans votre pocketId cree un nouveau client OIDC pour OpenWebUI et recupere le client_id et le client_secret.
Pour l'url callback ajoute `https://openwebui.<ton-domaine>/oauth/oidc/callback`.
Puis ajouter votre groupe de user dans le client OIDC pour que seul les user de ce groupe puisse se connecter a OpenWebUI.

### Installation d'OpenWebUI

Pour une question de simpliciter j'utilise le [script maintenue par la communauter proxmox pour cree un conteneur LXC avec OpenWebUI.](https://community-scripts.org/scripts/openwebui)

Directement dans host de votre noeud Proxmox:
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/openwebui.sh)"
```

> Bon a savoir: Pour vos future update de OpenWebUI, le script integre directement dans le contneur un fonction upgdate. Donc pour update aller dans la console du conteneur et taper update et suiver les instructions.

Une fois installer on va configurer l'authentification OIDC dans OpenWebUI. Pour cela on va editer le fichier .env du conteneur OpenWebUI:

```bash
WEBUI_URL=https://openwebui.<ton-domaine>
OPENID_REDIRECT_URI=https://openwebui.<ton-domaine>/oauth/oidc/callback
OPENID_PROVIDER_URL=https://pocketid.<ton-domaine>/well-known/openid-configuration

OAUTH_CLIENT_ID=<client_id>
OAUTH_CLIENT_SECRET=<client_secret>
OAUTH_PROVIDER_NAME=PocketID
OAUTH_SCOPES="openid email profile"
ENABLE_OAUTH_SIGNUP=true
```

Puis restarter et connecter vous a l'interface OpenWebUI avec votre compte PocketID.

Pour ma part je me suis connecter a l'interface OpenWebUI avant de configurer l'authentification OIDC, et j ai cree un compte local.
Une fois apres avoir configurer l'authentification OIDC, je donne les droits admin a mon user cree et lier avec PocketID Je test si celui-ci fonctionne bien puis  je me retouve donc avec un compte admin que je ne veux plus. 

Le probleme c'est que mon compte admin local a pour date de creeation la premiere dans la base de donnees donc mon compte pocketid n'a pas les droits pour supprimer le compte admin local.

Pour resoudre ce probleme on va donc modifier la base de donnees sqlite pour changer la date de creeation du compte local pour que celui-ci soit plus recent que le compte pocketid.

```bash
apt update && apt install sqlite3 -y
```

```bash
sqlite3 /root/.open-webui/webui.db
```

```bash
UPDATE user SET role = 'user' WHERE email = '<e-mai_du_compte_a_supprimer>';

UPDATE user SET created_at = created_at + 100000, updated_at = updated_at + 100000 WHERE email = '<e-mai_du_compte_a_supprimer>';

.exit
```

Pour ma part je supprime la connection avec part fomulaire pour etre sur que uniqument pocketid est utiliser pour se connecter a OpenWebUI.

j'ai donc decocher la case **Login Form** dans l'interface OpenWebUI dans:
**Setting > Authentication > Login Form**

## Ollama

Bon super on a une interface et une authentifiaction mais on peu toujours pas chatter.
Pour ma part j'ai choisi d'utiliser Ollama pour faire tourner les modeles localement sur mon MacBook il a bien autre outils pour faire cela mais j'utilise ollama pour sa simpliciter et sont headless.

### installation sur le MacBook

#### Installation de Ollama et configuration

```bash
brew install ollama
```

```bash
brew services stop ollama
```

On va donc configurer l'interface pour que OpenWebUI puisse se connecter a Ollama sur le MacBook.

```bash
mkdir -p ~/.homebrew/services/
vi ~/.homebrew/services/ollama.env
```
et ajouter les variables d'environnement suivantes:

```ollama.env
OLLAMA_HOST=0.0.0.0
OLLAMA_ORIGINS=https://openwebui.<ton-domaine>
```

```bash
brew services start ollama
```

#### Configuration du pare-feu sur MacOS

Ajouter ollama au pare-feu:
```bash
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /opt/homebrew/bin/ollama
```

Autoriser les connexions entrantes:
```bash
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp /opt/homebrew/bin/ollama
```

Vérifier:
```bash
/usr/libexec/ApplicationFirewall/socketfilterfw --getappblocked /opt/homebrew/bin/ollama
```

#### Disponibilité de Ollama sur le réseau local

Mon Macbook dispose d'une IP fixe sur mon réseau local, donc il est accessible depuis mon home serveur. Mais il va ce mettre en veille et je ne veux pas selement utiliser OpenWebUI quand mon MacBook est allumer. Donc je vais utiliser [Amphetamine](https://apps.apple.com/us/app/amphetamine/id937984704) pour garder mon MacBook allumer et accessible sur le réseau local.
Et je vais autoriser l endormisement uniquement de mon ecran pour que mon MacBook reste allumer et accessible sur le réseau local.

### Relier OpenWebUI a Ollama

Aller dans l'interface OpenWebUI dans:

**Settings > AI > Connections >  Manage Ollama API Connections**

Puis ajouter http://<IP_DE_VOTRE_MACBOOK>:11434

### Petit rappel sur la sécurité

N'ouvrer par en directe sur le port 11434 de votre MacBook sur internet.
Ajouter des regle firewall dans proxmox pour faire communiquer votre conteneur caddy avec OpenWebUI
Limiter auu maximum les ports ouvert vers internet.

---
Merci d'avoir pris le temps de lire cet article, j'espere que cela pourra aider certain a mieux comprendre comment fonctionne OpenWebUI et comment l'installer sur un home serveur avec une authentification OIDC via PocketID et configuration de Caddy.

**Ka-chow** 🚀
