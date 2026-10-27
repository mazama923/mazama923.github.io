---
title: "DNS local et Podman rootless : l’adresse ne suffit pas"
date: 2026-10-26 22:28:12
description: "Avec Podman rootless, un résolveur DNS local doit être joignable depuis le conteneur ; voici comment vérifier le chemin avant de le configurer."
type: post
tags: dns,podman,containers,rootless
slug: podman-dns
---


Un nom de ton réseau se résout sur l’hôte, mais pas dans un conteneur Podman rootless. Le premier réflexe est souvent de recopier l’adresse du DNS dans la configuration. Sauf que connaître l’adresse ne suffit pas : le conteneur doit aussi pouvoir joindre ce résolveur depuis son propre réseau.

## « Local » dépend de l’endroit où tourne le DNS

Un conteneur a son propre espace réseau. Son adresse de loopback désigne le conteneur, pas l’hôte. Si ton résolveur écoute uniquement sur l’interface de loopback de la machine, indiquer cette adresse dans le conteneur ne le rend pas accessible.

Un DNS installé sur une autre machine du LAN pose une question différente : le réseau rootless doit pouvoir acheminer les requêtes vers cette machine, et le pare-feu doit laisser passer DNS en UDP et TCP sur le port 53. Le backend réseau utilisé par Podman — par exemple `pasta` ou `slirp4netns` — et sa version peuvent changer le chemin. Évite donc de recopier une adresse ou une configuration trouvée pour une autre installation sans vérifier ce que voit ton conteneur.

Pour le contexte sur le résolveur du LAN, tu peux aussi lire [la configuration d’un DNS local avec Dnsmasq et Unbound](/blog/dnsmasq-unbound/).

Autre point : attribuer une adresse statique au serveur Podman n’est pas un prérequis DNS en soi. Cela ne devient pertinent que si le résolveur tourne sur cette machine et que d’autres systèmes doivent pouvoir l’atteindre durablement.

## Vérifier depuis le conteneur, pas seulement depuis l’hôte

Commence par tester le même nom sur l’hôte et dans un conteneur déjà démarré. Remplace les valeurs d’exemple par le nom du conteneur et un nom de ta zone locale ; `example.invalid` est volontairement réservé et ne résoudra pas.

```sh
CONTAINER='nom-du-conteneur'
DNS_SERVER='adresse-du-resolveur'
FQDN='hote.example.invalid'

getent hosts "$FQDN"
podman exec "$CONTAINER" cat /etc/resolv.conf
podman exec "$CONTAINER" getent hosts "$FQDN"
podman exec "$CONTAINER" dig @"$DNS_SERVER" "$FQDN"
```

`getent` et `dig` doivent être présents sur l’hôte ou dans l’image du conteneur pour les tests concernés. Si l’image ne contient pas `dig`, utilise un outil de diagnostic déjà disponible dans l’environnement plutôt que d’installer un paquet juste pour ce contrôle.

Lis les résultats dans cet ordre :

- Si le nom ne se résout déjà pas sur l’hôte, commence par vérifier l’enregistrement et le résolveur côté hôte.
- `/etc/resolv.conf` indique le résolveur configuré dans le conteneur ; sa présence ne prouve pas qu’il est joignable.
- Une réponse `NXDOMAIN` signifie que le serveur a répondu, mais qu’il ne connaît pas ce nom. Un délai d’attente oriente plutôt vers le chemin réseau, l’écoute du service ou le filtrage.
- Si `dig` obtient une réponse du serveur indiqué mais que `getent` échoue dans le conteneur, vérifie le résolveur effectivement configuré et la résolution utilisée par l’image.

`getent` n’est pas disponible dans toutes les images. Dans ce cas, teste avec l’outil de résolution fourni par l’image ou par l’application concernée ; le résultat obtenu sur l’hôte ne suffit pas à valider celui du conteneur.

## Choisir où corriger

Si le résolveur tourne sur l’hôte, il doit écouter sur une adresse que le conteneur peut atteindre. N’ouvre pas le service sur toutes les interfaces par facilité : limite l’écoute et les règles de pare-feu aux sources nécessaires. Un alias d’hôte, lorsqu’il est disponible, ne change rien si le service continue d’écouter uniquement sur loopback.

Si le DNS est sur le LAN, vérifie l’adresse réellement accessible depuis le réseau rootless ainsi que les règles du résolveur et du pare-feu. Une adresse de lien local ou une passerelle ne devient pas automatiquement joignable parce qu’elle fonctionne depuis l’hôte.

Pour un conteneur lancé avec Podman, l’option `--dns` permet de lui indiquer explicitement un résolveur. Dans Quadlet, vérifie l’option prise en charge par la version installée et place-la dans la configuration du conteneur ; ne transpose pas mécaniquement une clé de configuration réseau. Dans les deux cas, configure une adresse atteignable depuis le conteneur, pas seulement une adresse valide sur le papier.

## À retenir

Ne commence pas par fixer l’adresse de l’hôte ni par ajouter des DNS à plusieurs endroits. Identifie d’abord où tourne le résolveur, regarde ce que le conteneur a reçu, puis teste la résolution depuis son propre espace réseau. Si le résolveur local n’écoute que sur loopback, il faudra corriger son exposition de manière contrôlée ou utiliser un résolveur déjà accessible — pas simplement recopier son adresse.

**Ka-chow** 🚀
