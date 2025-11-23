---
title: Mon passage de VSCode à Neovim
layout: default
date: 2025-11-13
parent: 🔭 Exploration
categories: [Exploration]
tags: [ide, neovim, vi, vim, devops]
last_modified_date: Nov 16 2025
---

## Pourquoi changer d’IDE ? Un déclic inattendu ⚡

Un matin, j’ouvre VSCode sur mon repo préféré. Dix secondes… vingt secondes… *toujours* pas prêt.  
C’est là que j’ai eu le déclic : est-ce vraiment normal de démarrer sa journée avec autant d’attente ? Moi qui optimise chaque commande, chaque déploiement, il était temps de trouver **un outil qui me ressemblait**.

![Open VSCode](/assets/images/exploration/vscode_to_neovim/open_vscode.gif)

## VSCode : une belle histoire, mais…

VSCode, c’est le couteau suisse moderne : extensions à gogo, config modulable, et une communauté immense.  
Mais à force, j’ai fini par me perdre dans les mises à jour, synchronisations à moitié faites entre pro et perso, et des démarrages de plus en plus lents — surtout sous WSL2.  
Et puis, on va se l’avouer : un DevOps qui ne sauvegarde pas sa config dans Git, c’est comme un chef sans recette.  

## Ce que je recherche vraiment 🔍

- Légèreté et rapidité
- Utilisable partout (macOS, Windows, WSL)
- Maîtrise des mises à jour
- LSP et autocomplétion au top
- Config versionnée sur Git
- Workflow 100 % terminal

## À la recherche du nouvel IDE ✨

J’ai fait le tour : zed, emacs, puis… Neovim.

| IDE | avis |
|:---:|:----:|
| zed | Rapide, mais trop jeune et difficile à intégrer au terminal |
| emacs | Lent sur Mac et raccourcis peu intuitifs |
| neovim | Le coup de foudre : instantané, configurable et ultra-modulaire |


## Pourquoi Neovim (et LazyVim) m’ont convaincu 🕵️‍♂️

Je voulais une config prête à l’emploi, mais évolutive. LazyVim, AstroNvim ou NvChad : ces frameworks font gagner un temps fou et offrent déjà tout ce qu’il faut — LSP, ai, lint, autocomplétion.

> “J’ai ajouté Telescope pour la recherche de fichiers, Treesitter pour la coloration syntaxique, Mason pour la gestion des LSP. Trois plugins et je retrouve 80 % des fonctionnalités de VSCode, mais en un éclair !”

Et surtout, tout est versionné sur Git : je peux partager ma config pro/perso sans galérer.

## Le workflow DevOps rêvé 🎯

Tout dans le terminal. Ouverture instantanée.  
Je jongle entre des dizaines de projets par jour : Neovim démarre à la vitesse de l’éclair, jamais de ralentissement.

Et **les Vim motions** : sur les serveurs, il n’y a que vi/vim. Les maîtriser, c’est un gain de productivité colossal.

![Kachow](/assets/images/exploration/vscode_to_neovim/Mcqueen.gif)

## Et l’IA ? 😎

Pas de panique : Copilot, Codeium ou codecompanion s’intègrent déjà très bien.  
Aujourd’hui, j’utilise codecompanion pour Copilot, et tout fonctionne aussi bien que sur VSCode.

## Ma config pour commencer vite 🚦

Je mets à dispo ma config LazyVim [GitHub](https://github.com/mazama923/lazyvim) — clone, `:Lazy sync` et c’est parti.

![Capture de mon neovim](/assets/images/exploration/vscode_to_neovim/my_neovim.avif)

## Conclusion : adoptez la vitesse et l’efficacité 🔥

Franchement, repasser à VSCode ? Impossible.
Gagner du temps sur chaque commande, contrôler totalement mon environnement… Neovim est devenu indispensable à mon workflow DevOps.

Et si tu veux tenter l’aventure, commence avec une préconfig, bidouille à ton rythme, et découvre ce que ça change au jour le jour.

**Ka-chow** 🚀

