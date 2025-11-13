---
title: Mon passage de VSCode a Neovim
layout: default
date: 2025-11-13
parent: 🔭 Exploration
categories: [Exploration]
tags: [ide, neovim, vi, vim, devops]
last_modified_date: Nov 13 2025
---

## Mon expérience avec les IDEs classiques 🤔

J'ai longtemps utilisé VSCode.

Soyons honnêtes : c'est un très bon IDE.

Il est très complet, personnalisable, et possède une énorme bibliothèque d'extensions.

Il répond à la plupart de mes besoins, surtout en tant que DevOps où l'on peut changer de langage et de techno très souvent.

Sa grande force, c'est qu'il a une extension pour chaque besoin sans avoir besoin d'un IDE différent par langage. Et avouons-le, c'est quand même plus sexy que Notepad.

Mais, car il y a un mais, ce n'est pas le plus rapide et il est difficile de partager sa config ou même de la sauvegarder sur Git.

Bien sûr, il a la sync avec le compte Microsoft, mais si je veux séparer mon pro du perso en partageant les mêmes extensions, c'est pas possible.

De plus, sur ma machine pro j'utilise WSL2 et je me retrouve régulièrement avec des mises à jour lors de `code .`, ce qui ralentit grandement mon workflow car je switch souvent entre des repos différents.

## Donc, quels sont mes besoins ? 🧐

- Leger et rapide
- Léger et rapide
- Utilisable sur macOS et Windows
- Maîtrise sur les mises à jour
- LSP et autocomplétion
- Sauvegarde de config sur git
- Sauvegarde de config sur Git
- Permet de rester tout le temps dans le terminal pour accélérer mon workflow

## Mon exploration des IDEs 🧑‍💻

J'ai testé plusieurs IDEs pendant 2 à 3 jours pour me faire un avis.

Une liste non exhaustive :

| IDE | avis |
|:---:|:----:|
| zed | Bien plus rapide que VSCode mais très jeune encore et demande de sortir de mon terminal |
| emacs | Trop lent sur mon Mac et je n'apprécie pas les raccourcis |
| neovim | Attire grandement mon attention |

## Mon choix : Neovim ! 🚀

Plus précisément Neovim avec LazyVim comme config de base, car ce qu'apporte LazyVim simplifie grandement la configuration.

Pour ceux qui souhaitent ne plus prendre de douche, on peut configurer Neovim de zéro, mais cela va demander beaucoup de temps pour peu d'apport.

Je conseille plutôt de passer par des configs préfaites comme [LazyVim](https://www.lazyvim.org/), [AstroNvim](https://astronvim.com/) ou [NvChad](https://nvchad.com/).

Cela permet de se concentrer sur le plus important et que l'outil réponde au maximum à vos besoins.

Une fois plus à l'aise, vous pourrez toujours modifier la config.

Donc, pourquoi Neovim ?

Déjà, il a une grosse communauté derrière lui.
Utilisable sur macOS et Windows, il ne casse pas mon workflow : tout se passe dans mon terminal.

Il a de multiples préconfigs, ce qui fait gagner énormément de temps.
LazyVim par exemple a déjà tout ce qu'il faut pour commencer.
De plus, avec LazyVim, l'implémentation de LSP, AI, lint est beaucoup plus simple : les configs sont déjà faites.
Cela permet de rester dans les standards et de ne pas se casser les dents à chaque mise à jour.

Je vous invite grandement à jeter un œil à [LazyVim](https://www.lazyvim.org/) (je n'ai pas d'actions chez eux). Mais le projet est activement maintenu et fait partie des grands contributeurs de l'écosystème Neovim.

Une autre force de Neovim, c'est qu'il s'ouvre en une fraction de seconde, ce qui est vraiment agréable tout au long de la journée.
Durant une journée, je dois facilement ouvrir une cinquantaine de fois différents repos/projets, ce qui me permet de gagner en productivité.

Mais aussi, retrouver les Vim motions comme sur les serveurs de prod : dans la plupart des sociétés, seuls vi ou vim sont installés, donc connaître les Vim motions est super important pour moi.
Essayer les Vim motions, c'est les adopter : le gain en productivité est énorme.

### Retour d'expérience 📝

Je ne retournerai pas en arriere !
Je ne retournerai pas en arrière !

Le fait d'avoir le contrôle total sur mon IDE est un vrai plus.
De plus, les Vim motions sont bien mieux intégrées qu'une simple extension dans VSCode.
C'est vraiment devenu pour moi un outil indispensable.

Et pour les plus frileux sur la perte des outils IA, vous serez ravis : c'est exactement pareil. En ce moment j'utilise codecompanion pour le brancher avec Copilot, mais étant donné que ces outils bougent énormément, cela peut ne plus être le cas dans 1 jour, 1 mois ou même 1 an.

Voici ma configuration [LazyVim](https://github.com/mazama923/lazyvim) que j'utilise actuellement, vous pouvez la retrouver sur mon GitHub.

---

Merci de m'avoir lu jusqu'au bout !

**Bon DevOps à tous !** 🚀
