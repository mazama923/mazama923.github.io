---
title: "Pourquoi j’ai installé Proxmox sur mon home server"
date: 2026-10-30 23:09:48
description: "Retour d’expérience sur le passage de Fedora et Podman à Proxmox VE, avec une contrainte d’installation sur le stockage eMMC d’une ZimaBoard."
type: post
tags: proxmox,virtualisation,lxc,home-server
slug: proxmox-home-server
---

# Pourquoi j’ai installé Proxmox sur mon home server

Sur mon home server, je faisais tourner Fedora 43 avec des conteneurs Podman en rootless. Au début, ça répondait à mon besoin. Mais avec de plus en plus de services, tous mes pods partageaient le même hôte, et certains services tournaient directement dessus. Je voulais mieux séparer tout ce petit monde, notamment pour faciliter la gestion des accès réseau et des sauvegardes.

Cela faisait un moment que je regardais [Proxmox VE](https://www.proxmox.com/en/) et qu’on m’en parlait. J’ai donc décidé de l’installer sur ma ZimaBoard, le serveur que je présentais dans mon [article sur mon home server](https://mazama923.github.io/blog/home-server/).

## Pourquoi quitter un hôte Fedora unique ?

Podman en rootless me permettait déjà de faire tourner des conteneurs sans les lancer directement en tant que root. Le problème n’était pas que cette solution était inutilisable : c’est que mon organisation devenait plus difficile à maintenir à mesure que j’ajoutais des services sur le même système.

Entre les pods et les services installés sur l’hôte, je voulais des frontières plus claires : savoir où tourne chaque service, quels accès lui sont nécessaires et comment le sauvegarder ou le restaurer. Je cherchais aussi une manière plus lisible de gérer les règles réseau que de multiplier les manipulations de `firewalld` sur un seul hôte.

## LXC ou VM selon le niveau d’isolation

Proxmox VE me donne une interface pour gérer des conteneurs LXC et des machines virtuelles sur la même machine. Je peux choisir le type d’environnement en fonction du service, au lieu de tout faire cohabiter directement sur Fedora.

La différence compte : un conteneur LXC partage le noyau de l’hôte Proxmox, alors qu’une VM utilise son propre noyau. Pour un besoin d’isolation plus fort, je peux donc privilégier une VM, au prix de ressources supplémentaires. Un LXC non privilégié reste un choix à considérer pour limiter les privilèges du conteneur, mais il ne fournit pas la même frontière qu’une VM.

Ça ne rend pas les services sûrs par magie : il faut toujours limiter les privilèges, maintenir les systèmes à jour et contrôler leurs accès. Et Proxmox lui-même devient un élément central à protéger.

## Des règles réseau plus lisibles

L’interface Proxmox permet de définir des règles de pare-feu à différents niveaux, notamment pour l’hôte et pour les VM ou conteneurs. Pour moi, c’est plus simple de garder une vue organisée des règles associées aux services que de tout manipuler sur un unique Fedora.

La présence d’une règle dans l’interface ne suffit pas : il faut activer le pare-feu aux niveaux concernés, vérifier où le trafic passe réellement et tester les accès autorisés comme les accès refusés. Les règles donnent une meilleure vue de ce qui est configuré ; pour comprendre les flux effectivement observés, il faut aussi s’appuyer sur les journaux ou sur des outils de supervision adaptés.

## Sauvegardes et modèles

Autre point pratique : je peux lancer une sauvegarde de VM ou de conteneur depuis l’interface, puis utiliser des modèles pour faciliter le déploiement d’environnements similaires. C’est plus confortable que de gérer chaque opération séparément sur l’hôte.

Une sauvegarde accessible en quelques clics n’est pas pour autant une sauvegarde vérifiée. Il faut choisir un stockage adapté, conserver une copie indépendante de la machine et tester la restauration. Les données externes ou montées séparément doivent aussi être prises en compte dans la stratégie de sauvegarde : ne pars pas du principe que tout est inclus.

## Installer Proxmox sur l’eMMC de la ZimaBoard

L’installation sur ma ZimaBoard n’a pas été tout à fait *plug and play*. Son stockage interne est de l’eMMC et l’installateur de Proxmox vérifie le type de disque dans son code Perl. Dans mon cas, c’est ce point qui demandait une adaptation pour utiliser ce stockage.

J’ai trouvé une piste dans l’article d’[iBug sur l’installation de Proxmox VE sur eMMC](https://ibug.io/blog/2022/03/install-proxmox-ve-emmc/) : le contournement consiste à ajouter un cas conditionnel pour l’eMMC dans le code de l’installateur. Cet article date de 2022 ; le code et son emplacement peuvent avoir changé selon la version de Proxmox. Je ne reprends donc pas ici une modification Perl en la présentant comme valable pour toutes les versions : vérifie la procédure et le code de ton installateur avant de l’appliquer.

Avant de te lancer, sauvegarde les données à conserver : installer Proxmox sur un disque peut effacer son contenu. Identifie également le disque ciblé et contrôle sa capacité avant toute opération. Sur un système Linux qui voit le matériel, cette commande permet de lister les périphériques de stockage :

```sh
lsblk -o NAME,SIZE,TYPE,MODEL
```

Compare le résultat avec ton matériel avant de choisir la destination dans l’installateur. Une fois l’installation terminée, vérifie que Proxmox démarre bien sur le disque attendu, que le stockage est disponible dans l’interface et qu’une sauvegarde peut être restaurée. L’eMMC a aussi une capacité et une endurance limitées : tiens-en compte pour les écritures et le placement des données.

## Ce que je retiens

Proxmox répond à mon besoin de mieux répartir mes services, de choisir entre LXC et VM et de gérer plus clairement les règles et les sauvegardes. En contrepartie, il ajoute une plateforme à administrer, et l’installation sur eMMC peut demander une intervention qui dépend de la version utilisée.

Si ton organisation avec un seul hôte te convient, ce changement n’est pas forcément nécessaire. Dans mon cas, la séparation des services et la gestion centralisée rendent le compromis intéressant.

**Ka-chow** 🚀
