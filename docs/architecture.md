# Architecture

## Exécution

Le site cible Erlang et utilise Blogatto 7.0.1 comme framework de site statique. Lustre fournit les vues HTML ; `gleam_time` est disponible pour gérer les dates et heures dans la configuration du site.

Le point d’entrée de construction est `src/mazama_blog.gleam` ; `src/mazama_blog/dev.gleam` sert au serveur de développement. La configuration d’exécution doit configurer Blogatto avec :

- `blog/` comme chemin source des contenus ;
- `static/` comme chemin source des ressources ;
- `dist/` comme répertoire de sortie ;
- un `route_builder` public afin qu’un article soit généré dans `dist/blog/<slug>/index.html` et qu’une page de contenu soit générée dans `dist/<slug>/index.html`.

`just apercu` démarre le point d’entrée existant du serveur de développement.

## Limite de mise à niveau de Blogatto

L’intégration utilise uniquement les modules publics documentés de Blogatto : `blogatto`, `blogatto/config`, `blogatto/config/post`, `blogatto/config/feed/rss`, `blogatto/config/robots`, `blogatto/config/sitemap`, `blogatto/dev` et `blogatto/post`.

N’importez pas `blogatto/internal/**` et ne dépendez pas des détails générés dans `dist/`. Pour mettre une dépendance à niveau, utilisez une branche dédiée, mettez à jour la contrainte de version, exécutez `gleam deps update`, puis `just verifier-contenu`, `gleam format --check`, `gleam test` et `just construire`. Vérifiez le routage généré et la disposition des ressources dans `dist/` avant de fusionner.

## Chaîne de contenu

```text
templates -> drafts/<type>/<slug> -> validation -> revue humaine -> blog/<type>s/<slug> -> Blogatto -> dist
```

`scripts/new-content.sh` crée les brouillons depuis les modèles canoniques. `scripts/check-content.sh` valide les fichiers `index.md` publiés. `scripts/publish-draft.sh` valide un brouillon avant de le déplacer atomiquement dans `blog/`.

La publication intervient seulement après validation et revue humaine explicite. Les agents IA ne doivent pas exécuter cette étape sans demande explicite.

## Livraison

Le workflow Pages installe Erlang et Gleam, vérifie le formatage et les tests, valide le contenu, construit `dist/`, téléverse ce répertoire puis le déploie avec GitHub Pages. Les pull requests exécutent les mêmes étapes de validation sans déploiement.

## Limites

L’implémentation d’exécution Blogatto dans `src/` et les ressources dans `static/` ne doivent pas être modifiées pour des travaux de contenu ou d’outillage sans demande explicite.

La documentation et les contenus doivent suivre les règles de confidentialité de [`docs/securite-ia.md`](securite-ia.md). Aucun secret, identifiant interne ou extrait non expurgé ne doit être transmis à un service externe.
