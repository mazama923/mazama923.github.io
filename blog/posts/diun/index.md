---
title: "Maintenir ses images Docker à jour"
date: 2026-01-01 00:00:00 Europe/Paris
description: "Surveiller les mises à jour d’images Docker avec Diun sans automatiser leur déploiement."
slug: diun
type: post
tags: docker,image,upgrade
---

## Maintenir ses images Docker à jour

Quand on utilise beaucoup de conteneurs Docker sur un serveur, il est essentiel de garder ses images à jour.
Mais soyons honnêtes : vérifier manuellement toutes les images de temps en temps devient vite fastidieux.

Lors de mes recherches, je voulais un outil capable de **me notifier quand mes images deviennent obsolètes**, sans les mettre à jour automatiquement.
En clair : je voulais garder le contrôle, tout en évitant les mauvaises surprises.

## Le choix de Diun

J’ai finalement choisi [**Diun**](https://crazymax.dev/diun/), un outil léger et redoutablement efficace pour surveiller les mises à jour d’images Docker.

Pourquoi Diun ?
Parce qu’il **n’applique pas les mises à jour automatiquement**. Je garde ainsi la main sur le déploiement et je peux mettre à jour mes conteneurs à mon rythme.
Ça limite aussi les risques liés aux *breaking changes* qui peuvent survenir après une mise à jour trop récente.

Cerise sur le gâteau : Diun peut **envoyer des notifications** via plusieurs canaux (email, Telegram, Slack, Discord, etc.).
Dans mon cas, j’ai choisi **Discord**, puisque j’ai déjà un serveur dédié à mon homelab pour tout ce qui est alerting.
J’ai simplement ajouté un canal pour les notifications Docker, grâce à un **webhook**.

## Configuration

La mise en place est ultra simple.
J’ai opté pour une configuration complète via **variables d’environnement**, ce qui s’intègre bien à mon infrastructure Docker.

Les paramètres principaux que j’utilise sont les suivants :

### Surveiller toutes les images par défaut

Je préfère ne pas avoir à ajouter un label spécifique sur chaque conteneur.  
Diun surveille donc toutes mes images automatiquement grâce à :

```bash
DIUN_PROVIDERS_DOCKER_WATCHBYDEFAULT=true
```

### Planifier les vérifications hebdomadaires

Je ne veux pas être spammé de messages, ni déclencher des mises à jour tous les jours.
J’ai donc choisi une exécution une fois par semaine, le samedi à 18h :

```bash
DIUN_WATCH_SCHEDULE=0 18 * * 6
```

Cette fréquence permet aussi d’éviter de basculer trop tôt vers des versions fraîchement publiées, et de prendre le temps d’attendre les premiers correctifs éventuels.

#### Alternatives

Il existe plusieurs alternatives à Diun, mais si vous avez une infrastructure simple ou un homelab, ce serait dommage de se priver d’un outil aussi pratique, léger et facile à maintenir.

---
Voilà, un petit article rapide, mais qui vous permettra de mieux gérer l’obsolescence de vos images Docker sans prise de tête.

Ka-chow 🚀
