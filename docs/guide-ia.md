# Guide d’usage IA

Ce guide permet d’utiliser un agent IA, y compris un petit modèle local, sans lui donner une liberté excessive.

## Contexte minimal à fournir

Donnez toujours à l’agent :

1. l’objectif éditorial en une phrase ;
2. le type de contenu : `post` ou `page` ;
3. le slug souhaité ;
4. les tags CSV ;
5. les sources publiques ou les notes déjà expurgées ;
6. la consigne de créer un brouillon uniquement ;
7. la référence à [`voix-ia.md`](voix-ia.md) et, lorsqu’un schéma est nécessaire, à [`diagrammes.md`](diagrammes.md) ;
8. les éléments personnels autorisés : contexte, hésitations, essais abandonnés, défauts acceptés et conclusion souhaitée.

La consigne complète réutilisable est dans [`voix-ia.md`](voix-ia.md). Elle impose une écriture de note de terrain : contexte réel, choix justifié, étapes minimales, vérification et limites explicites. Sa section « Signature personnelle » donne le ton du blog : récit à la première personne lorsqu’il est sourcé, oralité légère, autodérision et humour parcimonieux.

Exemple :

```text
Crée un brouillon de post dans drafts/ à partir de ces notes publiques.
Slug : diagnostic-dns-local
Tags : dns,linux,diagnostic
Le contenu est en français et reprend la voix définie dans la section « Signature personnelle » de docs/voix-ia.md. Les éléments personnels fournis sont les seules expériences que tu peux raconter à la première personne. Ne lis aucun fichier hors de drafts/, templates/ et docs/. Ne publie pas le brouillon. Applique docs/voix-ia.md, docs/editorial-style.md, docs/securite-ia.md et, si nécessaire, docs/diagrammes.md.
```

## Parcours obligatoire

```text
Brouillon IA → vérification automatique → revue humaine → publication explicite
```

```sh
just brouillon-article diagnostic-dns-local \
  "Diagnostiquer un DNS local" \
  "Méthode de diagnostic d’un résolveur DNS local sous Linux." \
  "dns,linux,diagnostic"

just verifier-contenu
just securite
```

L’agent s’arrête après la création ou la mise à jour du brouillon. Un humain relit le fond, les commandes, les sources et l’expurgation. La publication n’intervient qu’après une demande explicite :

```sh
just publier post diagnostic-dns-local
```

## Règles pour les petits modèles

- Une demande = un brouillon ou une modification ciblée.
- Ne demandez pas une refonte générale lorsque seule une page doit être créée.
- Fournissez un slug, un titre, une description et des tags à l’avance si possible.
- Donnez les anecdotes ou échecs que l’agent peut raconter ; sans note autorisée, il doit les signaler comme informations manquantes.
- Demandez à l’agent de lister les hypothèses, plutôt que de les inventer.
- Pour un schéma d’architecture, demandez un fichier Mermaid `.mmd`, un SVG généré localement et une référence Markdown vers ce SVG ; proscrivez l’ASCII art.
- Interdisez toute modification de `src/`, `static/`, `.github/` et de la publication sans instruction explicite.
- Donnez seulement les extraits nécessaires et déjà expurgés.

## Avant d’envoyer des données à un LLM cloud

Appliquez impérativement la checklist de [`securite-ia.md`](securite-ia.md). En cas de doute sur une adresse, un domaine, un journal, une capture ou une configuration, considérez-la comme non partageable jusqu’à revue humaine.
