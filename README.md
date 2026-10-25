# mazama923.github.io

Site statique personnel construit avec [Blogatto 7.0.1](https://hex.pm/packages/blogatto), Gleam et la cible Erlang.

## Prérequis

- Erlang/OTP 27 ou version ultérieure
- Gleam 1.19 ou version ultérieure
- [just](https://just.systems/)
- [Gitleaks](https://github.com/gitleaks/gitleaks)
- Bash 3.2 ou version ultérieure

Installez les dépendances avec `gleam deps download`.

## Workflow de contenu

Créez un brouillon avec un slug en kebab-case minuscule et des tags CSV en minuscules :

```sh
just brouillon-article activation-socket-systemd \
  "Activer un service Podman à la demande avec systemd" \
  "Exécuter un service Podman à la demande grâce à l’activation de sockets systemd." \
  "systemd,podman,conteneurs"
```

Modifiez ensuite `drafts/post/activation-socket-systemd/index.md`, puis validez-le :

```sh
just verifier-contenu
```

Le brouillon doit être relu et approuvé par un humain avant toute publication. Après cette approbation explicite, publiez-le :

```sh
just publier post activation-socket-systemd
```

Un article publié se trouve dans `blog/posts/<slug>/index.md` ; une page publiée se trouve dans `blog/pages/<slug>/index.md`. Les scripts refusent les slugs invalides, les tags mal formés, les destinations existantes et les frontmatters incomplets.

Les agents IA suivent strictement le parcours brouillon → revue humaine → publication. Ils ne publient pas, ne déploient pas et n’effectuent aucun appel réseau sans demande explicite. Consultez [`docs/securite-ia.md`](docs/securite-ia.md) avant de partager du contenu avec un LLM cloud.

## Commandes

```sh
just brouillon-article <slug> <titre> <description> <tags>
just brouillon-page <slug> <titre> <description> <tags>
just publier <post|page> <slug>
just verifier-contenu
just securite
just verifier
just apercu
```

`just construire` utilise `src/mazama_blog.gleam` ; `just apercu` utilise `src/mazama_blog/dev.gleam`. `just verifier` exécute le scan de secrets, le formatage, les tests, la validation du contenu et la génération. Blogatto lit récursivement `blog/`, donc le contenu nouvellement publié est inclus automatiquement.

## Architecture

```text
blog/posts/<slug>/index.md  Article Blogatto publié
blog/pages/<slug>/index.md  Page Blogatto publiée
drafts/<type>/<slug>/       Contenu de travail non publié
templates/                  Modèles de frontmatter stricts
scripts/                    Création, validation et publication de contenu
src/                        Implémentation du site avec Blogatto et Lustre
static/                     Ressources copiées dans dist/
dist/                       Site généré, déployé sur GitHub Pages
docs/                       Documentation de migration, d’édition et de sécurité
```

Lisez [`docs/architecture.md`](docs/architecture.md), [`docs/content-model.md`](docs/content-model.md), [`docs/editorial-style.md`](docs/editorial-style.md), [`docs/guide-ia.md`](docs/guide-ia.md) et [`docs/securite-ia.md`](docs/securite-ia.md) avant d’étendre le site.

## Licence

- Le code, les scripts et la configuration de ce dépôt sont distribués sous [licence MIT](LICENSE).
- Les articles, pages, images, schémas et autres contenus originaux sont distribués sous [CC BY 4.0](LICENSE-CONTENT.md).
- Les dépendances et ressources de tiers restent soumises à leurs licences respectives.

## Limites de modification

Les automatisations et agents IA ne doivent pas modifier `src/`, `static/` ni les workflows CI sans demande explicite. Ils ne lisent ni ne divulguent de secrets ; la politique complète est décrite dans [`SECURITY.md`](SECURITY.md).
