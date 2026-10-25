# Repository instructions

## Scope and ownership

- Published posts belong in `blog/posts/<slug>/index.md`.
- Published pages belong in `blog/pages/<slug>/index.md`.
- Draft content belongs in `drafts/<post|page>/<slug>/index.md`.
- Do not modify `src/`, `static/`, or CI workflows unless the request explicitly asks for it.


## Content conventions

- Use `templates/post.md` or `templates/page.md` through `scripts/new-content.sh`.
- Every content document uses YAML frontmatter with `title`, `date`, `description`, `type`, `tags`, and `slug`.
- `type` is exactly `post` or `page`.
- `tags` is a lower-case CSV value with no spaces, for example `devops,observability`.
- Every published item uses Blogatto's directory-per-content layout under `blog/posts/` or `blog/pages/`.

## Validation

- Run `just check` after changing content.
- Run `gleam format --check`, `gleam test`, and `just build` before considering the migration ready.
- Do not publish a draft without validating it first.
