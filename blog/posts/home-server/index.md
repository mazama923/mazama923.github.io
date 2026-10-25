---
title: "Pourquoi un Home Server ?"
date: 2025-12-08 00:00:00 Europe/Paris
description: "Retour d'expérience sur le choix et l'installation d'un home server autour d'une ZimaBoard."
slug: home-server
type: post
tags: lab,home-server
---

## Pourquoi un Home Server ?

Que ce soit pour explorer de nouvelles technos, affiner votre veille technologique ou sortir de l'écosystème des GAFAM, le *Home Server* (ou *Homelab*) est un atout indéniable.

Il permet de réaliser des "crash tests" sans limite, de casser votre environnement sans risque, et même de maintenir une mini-production directement chez vous. C'est la liberté totale d'apprendre par la pratique.

## Mon évolution : du Cloud au Placard

J'ai longtemps utilisé des serveurs VPS ou des offres de VM bas de gamme chez divers hébergeurs. J'ai ensuite commencé à recycler de vieux PC portables, laissés dans un coin pour héberger mes "horreurs" de tests. C'était fonctionnel, mais loin d'être optimal niveau consommation électrique et praticité.

Il y a plus de 3 ans, lors de mon passage chez Free, j'ai commencé à utiliser les VM disponibles directement dans la Freebox Server (qui porte bien son nom). C'était déjà plus sérieux : une VM capable de tourner H24 sans souci. Cependant, les performances restaient très légères (1 vCPU, 1 Go de RAM). L'avantage ? Ça apprend vraiment à optimiser ses conteneurs !

L'arrivée de la Freebox Ultra, avec ses 2 vCPU et 2 Go de RAM, m'a donné un peu plus de puissance sous la pédale, me poussant à migrer certaines offres cloud vers cette VM. Mais mon objectif restait de tout rapatrier à la maison, de mes sauvegardes jusqu'à mon propre "Netflix" local.

Suite à un changement d'opérateur, j'ai dû faire une croix sur cette VM (cela fera peut-être l'objet d'un futur article). Mes besoins ayant évolué, il me fallait impérativement plus de puissance.

À ce moment-là, le Home Server dédié est devenu une évidence.

## Le choix du matériel : La ZimaBoard !

Après une multitude de recherches, j'avais établi mes critères :

- **Faible consommation** (le serveur tourne 24/7).
- **Minimum 2 CPU**.
- **Minimum 8 Go de RAM**.
- **Liberté de l'OS** (pouvoir installer ce que je veux).
- **Fanless** (pas de ventilateur = plus fiable, 0 entretien, silence absolu).

Vous aurez sûrement des critères complètement différents des miens, et c'est normal.

J'ai longtemps hésité avec un Raspberry Pi. Mais une fois tous les accessoires ajoutés (boîtier, alimentation, stockage), on se retrouve souvent avec une carte de prototypage au prix d'un mini-serveur, avec des câbles partout.

C'est là que j'ai découvert la ZimaBoard suite à une vidéo de [GuiPoM - G. testé !](https://www.youtube.com/watch?v=uWR1CMfs5C0). C'est un Home Server qui coche toutes les cases. J'ai donc sauté le pas.

Voici la configuration que j'ai choisie :

| Composant | Spécifications |
| :--- | :--- |
| **Processeur** | Intel N150 (4 Cœurs) |
| **TDP CPU** | 10W |
| **RAM** | 16 Go DDR5 |
| **Stockage interne** | 64 Go eMMC |

### Le choix de l'OS : ZimaOS

J'ai choisi de rester sur leur OS maison, [ZIMAOS](https://www.zimaspace.com/zimaos), qui est une évolution de [CasaOS](https://casaos.zimaspace.com/).

Pour faire simple, il ajoute une gestion des RAID, de nombreuses optimisations et une virtualisation intégrée. C'est une base Debian avec une surcouche graphique très propre. L'avantage principal est qu'il rend le serveur accessible via une application mobile et PC.

Cela permet à toute la maison de profiter des services du serveur. Tout le monde n'est pas ingénieur et ne "mange" pas de la ligne de commande ou des cartes graphiques au petit-déjeuner. De plus, leur interface est agréable : si vous êtes à l'aise avec Docker, cela ressemble beaucoup à un Portainer simplifié.

### Unboxing et Hardware

Le packaging est sympa. Petite astuce bien pensée : le carton qui protège la carte peut se transformer en table de benchmark pour vos tests ou prototypages.

![Package ZimaBoard](images/package_zimaboard2.avif)

La carte est livrée avec l'OS préinstallé, un câble double SATA et des adaptateurs secteur pour tous les continents. Il y a un petit ventilateur inclus, mais personnellement, je n'ai pas vu de différence de température avec ou sans lors de mes tests basiques. Je l'ai laissé car il est totalement inaudible.

Le plus intéressant reste la connectique de la carte elle-même :

![ZimaBoard](images/zimaboard2.avif)

On y retrouve un port Display, 2 ports LAN 2.5 GbE (parfait pour du routing) et 2 ports USB 3.0.

### Stockage et Installation

Comme la carte ne possède que 64 Go de stockage interne (eMMC), je garde cet espace uniquement pour l'OS. Pour le reste, j'ai profité du port PCIe pour ajouter un adaptateur NVMe avec un disque de 500 Go.

Ce NVMe est dédié à mes configurations Docker, aux volumes persistants et au fonctionnement du serveur. J'ai ajouté un disque dur externe USB de 5 To qui sert au "stockage pur" (sauvegardes, médias, etc.).

Voici à quoi ressemble l'installation finale, après avoir joué au LEGO pour tout faire rentrer dans le placard technique :

![Le placard](images/le_placard.avif)

L'organisation n'est pas encore optimale. Je pense par la suite ajouter un autre NVMe ou créer un stockage hybride combiné à des disques SATA. Mais pour le moment, cela répond totalement à mon besoin.

---

Merci d'avoir lu ces quelques lignes et bonne visite ! N'hésite pas à revenir régulièrement pour voir ce que je partage.

**Ka-chow** 🚀
