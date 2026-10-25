# mazama923.github.io

Personal static site built with [Blogatto 7.0.1](https://hex.pm/packages/blogatto), Gleam, and the Erlang target.

## Prerequisites

- Erlang/OTP 27 or newer
- Gleam 1.19 or newer
- [just](https://just.systems/)
- Bash 3.2 or newer

Install dependencies with `gleam deps download`.

## Content workflow

Create a draft with a lower-case kebab-case slug and lower-case CSV tags:

```sh
just draft-post systemd-socket-activation \
  "Systemd socket activation with Podman" \
  "Run a Podman service on demand through systemd socket activation." \
  "systemd,podman,containers"
```

Edit `drafts/post/systemd-socket-activation/index.md`, then validate and publish it:

```sh
just check
just publish post systemd-socket-activation
```

A published post lives at `blog/posts/<slug>/index.md`; a published page lives at `blog/pages/<slug>/index.md`. The scripts refuse invalid slugs, malformed tags, duplicate destinations, and incomplete frontmatter.

## Commands

```sh
just draft-post <slug> <title> <description> <tags>
just draft-page <slug> <title> <description> <tags>
just publish <post|page> <slug>
just check
gleam format --check
gleam test
just build
just preview
```

`just build` uses `src/mazama_blog.gleam`; `just preview` uses `src/mazama_blog/dev.gleam`. Blogatto recursively reads `blog/`, so newly published content is included automatically.

## Architecture

```text
blog/posts/<slug>/index.md  Published Blogatto post
blog/pages/<slug>/index.md  Published Blogatto page
drafts/<type>/<slug>/       Unpublished working content
templates/                  Strict frontmatter templates
scripts/                    Content creation, validation, and publication
src/                        Blogatto and Lustre site implementation
static/                     Assets copied into dist/
dist/                       Generated site, deployed to GitHub Pages
docs/                       Migration and editorial documentation
```

Read [`docs/architecture.md`](docs/architecture.md), [`docs/content-model.md`](docs/content-model.md), and [`docs/editorial-style.md`](docs/editorial-style.md) before extending the site.

## Change boundaries

Automation and AI agents must not modify `src/`, `static/`, or CI workflows unless explicitly requested.
