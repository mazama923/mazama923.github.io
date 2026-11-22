---
title: "Désactiver la mise en veille d’un Mac avec pmset"
date: 2026-11-22 00:39:00 Europe/Paris
description: "Empêcher la mise en veille d’un Mac sous macOS avec pmset pour garder Ollama disponible, puis rétablir les réglages de veille."
slug: disablesleep-macos
type: post
tags: macos,macbook,ollama,pmset
---

Dans mon article sur [Ollama et Open WebUI](https://mazama923.github.io/blog/open-web-ui/), je parlais d’[Amphetamine](https://apps.apple.com/us/app/amphetamine/id937984704) pour empêcher mon MacBook de se mettre en veille. Mais l’application s’arrêtait parfois et ne répondait plus lorsque j’essayais de la rouvrir, même après un redémarrage.

Comme je souhaite garder Ollama disponible en permanence, j’ai choisi une solution plus radicale : désactiver la mise en veille du Mac avec `pmset`, l’outil de gestion de l’alimentation intégré à macOS.

## Désactiver la mise en veille avec pmset

Ouvre un terminal et exécute cette commande avec un compte disposant des droits administrateur :

```bash
sudo pmset -a disablesleep 1
```

L’option `-a` applique le réglage à toutes les sources d’alimentation, donc aussi bien sur batterie que sur secteur. Il concerne le Mac entier, pas uniquement Ollama.

Pour vérifier le réglage actif :

```bash
pmset -g | grep SleepDisabled
```

La valeur `1` indique que la mise en veille est désactivée. L’écran peut tout de même s’éteindre : sa mise en veille est un réglage distinct.

## Les limites à connaître

Sur batterie, laisser le Mac allumé consomme davantage d’énergie et peut la vider rapidement. Sur secteur, assure-toi que la ventilation reste dégagée, surtout si Ollama sollicite longtemps la machine.

Ce réglage ne garantit pas une disponibilité 24 h/24 : une batterie vide, un arrêt, un redémarrage ou une mise en veille imposée par le système peuvent interrompre Ollama. Vérifie également le comportement de ton MacBook avant de fermer son écran : ne suppose pas qu’il restera accessible ou suffisamment ventilé une fois fermé.

## Réactiver la mise en veille du Mac

Pour autoriser de nouveau la mise en veille :

```bash
sudo pmset -a disablesleep 0
```

Vérifie à nouveau avec `pmset -g | grep SleepDisabled` : la valeur doit être `0`. Cette commande ne remet pas les délais de veille à leurs valeurs par défaut ; le Mac utilise les réglages de veille déjà configurés.

**Ka-chow** 🚀
