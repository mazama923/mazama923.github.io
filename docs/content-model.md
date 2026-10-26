# Modèle de contenu

## Emplacements

| État | Emplacement |
| --- | --- |
| Brouillon d’article | `drafts/post/<slug>/index.md` |
| Brouillon de page | `drafts/page/<slug>/index.md` |
| Article publié | `blog/posts/<slug>/index.md` |
| Page publiée | `blog/pages/<slug>/index.md` |

Blogatto découvre récursivement les fichiers `index.md` sous `blog/`. Les ressources publiques sont placées dans `static/` ; les diagrammes suivent la convention décrite dans [`diagrammes.md`](diagrammes.md).

## Frontmatter requis

Chaque document de contenu commence à la première ligne par un frontmatter YAML :

```yaml
---
title: "Titre lisible par une personne"
date: 2026-10-25 12:00:00
description: "Résumé court et factuel en français."
type: post
tags: devops,observabilite
slug: titre-lisible-par-une-personne
---
```

`title`, `date` et `description` sont requis par Blogatto. `type`, `tags` et `slug` sont des conventions du dépôt exposées comme métadonnées supplémentaires par Blogatto.

## Langue et placeholders

- Les titres, descriptions, corps de texte, exemples narratifs et placeholders destinés à être lus sont en français naturel.
- Les commandes, chemins, clés de configuration, identifiants et noms d’API restent inchangés lorsqu’ils sont techniques.
- Les modèles emploient les placeholders techniques `__TITLE__`, `__DATE__`, `__DESCRIPTION__`, `__TAGS__` et `__SLUG__`. Ne les traduisez pas : `scripts/new-content.sh` les remplace lors de la création d’un brouillon.
- Les valeurs insérées dans `__TITLE__` et `__DESCRIPTION__` sont en français. La valeur de `__SLUG__` reste en kebab-case minuscule ; les tags restent en CSV minuscule sans espaces.

## Contraintes

- `type` vaut exactement `post` ou `page`.
- `date` utilise `YYYY-MM-DD HH:MM:SS`, éventuellement suivi d’un fuseau horaire.
- `tags` est un CSV non vide en minuscules, sans espaces.
- `slug` est en kebab-case minuscule et correspond au répertoire de contenu.
- Utilisez `index.md` comme nom de fichier du contenu de langue par défaut.
- N’insérez aucun secret, hôte interne, adresse interne ou capture non expurgée dans le contenu ; consultez [`securite-ia.md`](securite-ia.md).

## Validation et publication

Exécutez `just verifier-contenu` après toute modification de contenu. Cette commande vérifie chaque `blog/**/index.md` publié ; le script de publication valide également le brouillon déplacé.

Le flux est strict : brouillon dans `drafts/`, validation, revue humaine, puis publication explicite avec `just publier <post|page> <slug>`. Les agents IA s’arrêtent après la validation jusqu’à une approbation humaine explicite.
