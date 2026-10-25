# Architecture

## Runtime

The site targets Erlang and uses Blogatto 7.0.1 as the static-site framework. Lustre provides HTML views; `gleam_time` is available for date and time handling in the site configuration.

The build entrypoint is `src/mazama_blog.gleam`, with `src/mazama_blog/dev.gleam` for the development server. The runtime configuration must configure Blogatto with:

- `blog/` as the post source path;
- `static/` as the asset source path;
- `dist/` as the output directory;
- a public `route_builder`, so a post is emitted at `dist/blog/<slug>/index.html` and a content page at `dist/<slug>/index.html`.

`just preview` starts the existing development-server entrypoint.

## Blogatto upgrade boundary

The integration uses documented public Blogatto modules only: `blogatto`, `blogatto/config`, `blogatto/config/post`, `blogatto/config/feed/rss`, `blogatto/config/robots`, `blogatto/config/sitemap`, `blogatto/dev`, and `blogatto/post`.

Do not import `blogatto/internal/**` or rely on generated `dist/` details. For a dependency upgrade, use a dedicated branch, update the version constraint, run `gleam deps update`, then run `just check`, `gleam format --check`, `gleam test`, and `just build`. Review the generated route and asset layout in `dist/` before merging.

## Content pipeline

```text
templates -> drafts/<type>/<slug> -> validation -> blog/<type>s/<slug> -> Blogatto -> dist
```

`scripts/new-content.sh` creates drafts from the canonical templates. `scripts/check-content.sh` validates published `index.md` files. `scripts/publish-draft.sh` validates a draft before moving it atomically into `blog/`.

## Delivery

The Pages workflow installs Erlang and Gleam, checks formatting and tests, validates content, builds `dist/`, uploads that directory, then deploys it through GitHub Pages. Pull requests run the same validation steps without deployment.

## Boundaries

The legacy Jekyll implementation has been retired. The Blogatto runtime implementation in `src/` and assets in `static/` are intentionally not changed by content/tooling work unless explicitly requested.
