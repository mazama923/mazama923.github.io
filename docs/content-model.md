# Content model

## Locations

| State | Location |
| --- | --- |
| Draft post | `drafts/post/<slug>/index.md` |
| Draft page | `drafts/page/<slug>/index.md` |
| Published post | `blog/posts/<slug>/index.md` |
| Published page | `blog/pages/<slug>/index.md` |

Blogatto discovers `index.md` recursively below `blog/`. Assets stored next to an `index.md` are copied with the generated page.

## Required frontmatter

Every content document starts on line one with YAML frontmatter:

```yaml
---
title: "Human-readable title"
date: 2026-10-25 12:00:00
description: "Short, factual summary."
type: post
tags: devops,observability
slug: human-readable-title
---
```

`title`, `date`, and `description` are required by Blogatto. `type`, `tags`, and `slug` are repository conventions exposed as Blogatto extra metadata.

## Constraints

- `type` is exactly `post` or `page`.
- `date` is `YYYY-MM-DD HH:MM:SS`, optionally followed by a timezone.
- `tags` is non-empty lower-case CSV with no spaces.
- `slug` is lower-case kebab-case and matches its content directory.
- Use `index.md` as the default-language content filename.

Run `just check` after any content change. It checks each published `blog/**/index.md`; the publish script also validates the draft being moved.
