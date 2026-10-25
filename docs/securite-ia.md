# Sécurité des usages IA

Ce document encadre l’utilisation d’agents IA et de LLM pour ce dépôt. La confidentialité prime sur la commodité : en cas de doute, ne partagez pas la donnée et demandez une décision humaine.

## Règles impératives pour les agents

- Suivez le flux brouillon → validation → revue humaine → publication. Un agent ne publie jamais seul.
- Ne modifiez pas `src/`, `static/` ni les workflows CI sans demande explicite.
- Ne lisez ni `.env`, ni clés privées, ni tokens, ni mots de passe, ni credentials, ni configurations cloud, ni fichiers personnels sans demande explicite et nécessité démontrée.
- N’effectuez aucun appel réseau, téléversement, déploiement, publication ou partage avec un service tiers sans demande explicite.
- Ne reproduisez jamais un secret dans une réponse, un commentaire, une issue, un commit, un document, un prompt externe ou une sortie de commande.

## Checklist de rédaction et d’expurgation

Avant de publier, partager ou envoyer un extrait à un LLM, contrôlez chaque point :

- [ ] Aucun token, clé API, clé privée, certificat, mot de passe, cookie de session, credential ou chaîne de connexion n’est présent.
- [ ] Les secrets éventuels sont remplacés par `[TOKEN_REDACTED]`, `[SECRET_REDACTED]` ou une valeur manifestement fictive.
- [ ] Aucun nom de domaine interne, sous-domaine privé, URL d’administration ou nom d’organisation non public n’est présent. Utilisez `example.invalid` ou `service.example.invalid`.
- [ ] Aucune IPv4 interne ou réservée (`10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`, `127.0.0.0/8`) n’est exposée. Utilisez `192.0.2.10`, `198.51.100.10` ou `203.0.113.10`.
- [ ] Aucune IPv6 locale, unique locale ou interne (`::1`, `fc00::/7`, `fe80::/10`) n’est exposée. Utilisez `2001:db8::10`.
- [ ] Aucun hostname interne, nom de machine, identifiant d’utilisateur, chemin personnel, identifiant de compte ou nom de cluster n’est présent. Utilisez `host.example.invalid` et `/home/user/...`.
- [ ] Les captures d’écran ne montrent ni secrets, ni URL internes, ni adresses IP, ni hostnames, ni comptes, ni données personnelles, ni onglets ou notifications adjacents.
- [ ] Les journaux et sorties de commande ont été minimisés au strict nécessaire et expurgés ligne par ligne.
- [ ] Le contenu ne contient que des données publiques ou explicitement autorisées.

Une capture qui ne peut pas être expurgée de façon fiable ne doit pas être utilisée. Préférez un extrait textuel minimal et anonymisé.

## Politique LLM cloud

Par défaut, aucun contenu non public du dépôt, de l’environnement de travail ou des systèmes associés ne doit être envoyé à un LLM cloud.

Un envoi vers un LLM cloud n’est envisageable que si toutes les conditions suivantes sont réunies :

1. l’utilisateur l’a demandé explicitement ;
2. les données sont publiques ou ont été expurgées avec la checklist ci-dessus ;
3. seul l’extrait minimal nécessaire est transmis ;
4. le fournisseur, la rétention, l’entraînement éventuel et la localisation des données sont acceptables pour l’utilisateur ;
5. aucun secret, identifiant interne ou fichier personnel n’est inclus.

Les agents ne doivent pas contourner cette politique en copiant des données dans un prompt, une issue, un outil de diagnostic ou une autre intégration SaaS. Si la portée des données est ambiguë, demandez une revue humaine au lieu de les transmettre.

## Procédure en cas de secret commité

Traitez toute exposition comme réelle jusqu’à preuve du contraire.

1. **Contenir.** Arrêtez la diffusion : ne copiez pas le secret dans les messages, captures, issues ou commentaires. Limitez les accès et évitez toute nouvelle publication.
2. **Révoquer ou faire tourner.** Révoquez immédiatement le token, la clé, le credential ou le certificat auprès de son fournisseur. La suppression du fichier ne suffit pas.
3. **Évaluer.** Identifiez la nature du secret, les dépôts, branches, artefacts, caches, journaux, déploiements et services externes susceptibles de le contenir. Recherchez toute utilisation suspecte via les journaux du fournisseur.
4. **Purger l’historique.** Après rotation du secret, retirez-le du contenu courant et de l’historique Git avec une procédure approuvée. Coordonnez le réécriture de l’historique avec les contributeurs afin d’éviter de le réintroduire.
5. **Vérifier.** Contrôlez les branches, tags, pull requests, artefacts CI, GitHub Pages et caches pertinents. Ajoutez une protection adaptée, par exemple un secret scanner ou une règle de pré-commit, si cela est demandé.
6. **Documenter sans divulguer.** Consignez l’incident avec le type de secret, son périmètre, les dates et les actions réalisées, sans inclure la valeur du secret.

Si le secret a été transmis à un LLM cloud ou à un autre tiers, incluez ce service dans l’évaluation, consultez sa politique de rétention et engagez la procédure de suppression ou de support appropriée.

## Références dans le dépôt

- [`../AGENTS.md`](../AGENTS.md) définit les contraintes opérationnelles des agents.
- [`../SECURITY.md`](../SECURITY.md) décrit la politique de signalement et de traitement des vulnérabilités.
- [`editorial-style.md`](editorial-style.md) impose l’expurgation dans les contenus éditoriaux.
