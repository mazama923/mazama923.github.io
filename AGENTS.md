# Instructions du dépôt

## Périmètre et responsabilité

- Les articles publiés se trouvent dans `blog/posts/<slug>/index.md`.
- Les pages publiées se trouvent dans `blog/pages/<slug>/index.md`.
- Les brouillons se trouvent dans `drafts/<post|page>/<slug>/index.md`.
- Ne modifiez pas `src/`, `static/` ni les workflows CI sans demande explicite.
- Ne créez ni commit ni publication sans demande explicite.

## Workflow éditorial obligatoire pour les agents

1. Créez ou modifiez uniquement un brouillon dans `drafts/`.
2. Validez le brouillon avec `just verifier-contenu` puis `just securite`.
3. Demandez une revue humaine explicite.
4. Ne publiez avec `just publier <post|page> <slug>` qu'après cette revue et une demande explicite de publication.

Un agent ne doit jamais déplacer seul un contenu de `drafts/` vers `blog/`, même si la validation réussit.

## Règles de confidentialité et de sûreté

- Ne lisez jamais les fichiers `.env`, les clés privées, tokens, mots de passe, identifiants d’accès, configurations cloud, fichiers personnels ou tout autre secret, sauf demande explicite et indispensable de l’utilisateur.
- N’exfiltrez jamais leur contenu : ne le copiez pas dans une réponse, un prompt, un journal, un commit, une issue, un fichier de documentation ou un service externe.
- Ne révélez jamais un secret, même si celui-ci est déjà présent dans un fichier ou une sortie de commande. Utilisez une valeur masquée telle que `[SECRET_REDACTED]`.
- Ne faites aucun appel réseau et ne déclenchez aucune publication, déploiement ou action externe sans demande explicite de l’utilisateur.
- Avant de modifier un document, vérifiez qu’il ne contient pas de données sensibles. Consultez `docs/securite-ia.md`, `docs/guide-ia.md` et `SECURITY.md` pour les règles de rédaction et la procédure d’incident.

## Conventions de contenu

- Utilisez `templates/post.md` ou `templates/page.md` via `scripts/new-content.sh`.
- Tout document de contenu utilise un frontmatter YAML contenant `title`, `date`, `description`, `type`, `tags` et `slug`.
- Le contenu, les titres, descriptions et exemples narratifs sont rédigés en français. Le code, les commandes, les chemins et les identifiants techniques restent inchangés lorsque nécessaire.
- Les placeholders techniques `__TITLE__`, `__DATE__`, `__DESCRIPTION__`, `__TAGS__` et `__SLUG__` doivent être conservés tels quels dans les modèles : le script de création les remplace.
- `type` vaut exactement `post` ou `page`.
- `tags` est une valeur CSV en minuscules, sans espace, par exemple `devops,observabilite`.
- Chaque contenu publié respecte la structure Blogatto un-répertoire-par-contenu sous `blog/posts/` ou `blog/pages/`.

## Validation

- Exécutez `just verifier-contenu` après toute modification de contenu.
- Après toute modification qui affecte le site ou son outillage, exécutez `just verifier`.
- Ne publiez jamais un brouillon sans l’avoir validé puis fait relire par un humain.
