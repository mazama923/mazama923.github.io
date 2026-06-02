---
title: "Utilisation des DNS locaux avec Podman en rootless"
layout: default
date: 2026-06-02
parent: 📖 Presque une doc
categories: [docs, réseau]
tags: [dns, podman, containers, rootless]
last_modified_date: June 2 2026
---

# 🏠 Utilisation des DNS locaux avec Podman en rootless

Dans cet article, nous allons explorer comment configurer Podman pour utiliser vos DNS locaux avec des conteneurs rootless.

## Introduction : Pourquoi utiliser des DNS locaux avec Podman ?

Les DNS locaux peuvent améliorer la confidentialité et la performance de votre réseau local. En utilisant Podman avec des conteneurs rootless, vous pouvez bénéficier de ces avantages tout en maintenant un environnement sécurisé et isolé.

## Prérequis

Avant de commencer, assurez-vous d'avoir les éléments suivants :
- Un serveur local avec une distribution Linux (par exemple, Fedora).
- Podman installé et configuré pour l'utilisation rootless.
- Des droits d'administration sur le serveur.
- Une connexion Internet stable.

## Étape 1 : Configuration de l'IP statique du serveur

Configurez une adresse IP statique pour votre serveur local. Cela garantit que votre serveur DNS sera toujours accessible à la même adresse IP.

1. Modifiez le fichier de configuration réseau de votre serveur.
2. Définissez une adresse IP statique pour votre serveur.
3. Redémarrez le service réseau pour appliquer les modifications.

## Étape 2 : Configuration de Podman pour utiliser les DNS locaux

Pour configurer Podman afin qu'il utilise vos DNS locaux, suivez ces étapes :

1. **Modifiez le fichier de configuration de Podman** pour utiliser l'adresse IP de votre serveur DNS local.
2. **Configurez les réseaux Podman** pour utiliser les DNS locaux.
3. **Redémarrez Podman** pour appliquer les modifications.

### Exemple de configuration pour un conteneur

Voici un exemple de fichier de configuration pour un conteneur Podman qui utilise vos DNS locaux :

```ini
# Fichier : ~/.config/containers/systemd/mon-conteneur.container
[Container]
ContainerName=mon-conteneur
Image=mon-image:latest
Network=mon-reseau.network
DNS=169.254.1.1
```

### Exemple de configuration pour un réseau Podman

Voici un exemple de fichier de configuration pour un réseau Podman qui utilise vos DNS locaux :

```ini
# Fichier : ~/.config/containers/systemd/mon-reseau.network
[Network]
NetworkName=mon-reseau
Subnet=10.89.3.0/24
Gateway=10.89.3.1
DNS=169.254.1.1
```

## Étape 3 : Validation de la configuration

Pour valider que Podman utilise correctement vos DNS locaux, effectuez les tests suivants :

1. Lancez un conteneur Podman et vérifiez qu'il peut résoudre les noms de domaine via vos DNS locaux.
2. Vérifiez que les requêtes DNS sont correctement transmises à votre serveur DNS local.

## Conclusion

En suivant ces étapes, vous avez configuré Podman pour utiliser vos DNS locaux avec des conteneurs rootless. Cela améliore la confidentialité et la performance de votre réseau local tout en maintenant un environnement sécurisé et isolé.

**Ka-chow** 🚀