set shell := ["bash", "-euo", "pipefail", "-c"]

# Create a post draft: just draft-post <slug> <title> <description> <tags>
draft-post slug title description tags:
    ./scripts/new-content.sh post "{{slug}}" "{{title}}" "{{description}}" "{{tags}}"

# Create a page draft: just draft-page <slug> <title> <description> <tags>
draft-page slug title description tags:
    ./scripts/new-content.sh page "{{slug}}" "{{title}}" "{{description}}" "{{tags}}"

# Publish a validated draft: just publish <post|page> <slug>
publish type slug:
    ./scripts/publish-draft.sh "{{type}}" "{{slug}}"

check:
    ./scripts/check-content.sh

format:
    gleam format --check

test:
    gleam test

build:
    gleam run -m mazama_blog

preview:
    gleam run -m mazama_blog/dev
