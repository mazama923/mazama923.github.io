#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage: scripts/new-content.sh <post|page> <slug> <title> <description> <tags>

Tags must be lower-case CSV values without spaces, for example:
  devops,observability
EOF
  exit 64
}

fail() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

[[ $# -eq 5 ]] || usage

content_type=$1
slug=$2
title=$3
description=$4
tags=$5

case "$content_type" in
  post|page) ;;
  *) fail "content type must be post or page" ;;
esac

[[ $slug =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || fail "slug must be lowercase kebab-case"
[[ ${#slug} -le 80 ]] || fail "slug must be at most 80 characters"
[[ -n $title && $title != *$'\n'* && $title != *$'\r'* ]] || fail "title must be a single non-empty line"
[[ -n $description && $description != *$'\n'* && $description != *$'\r'* ]] || fail "description must be a single non-empty line"
[[ $tags =~ ^[a-z0-9]+(-[a-z0-9]+)*(,[a-z0-9]+(-[a-z0-9]+)*)*$ ]] || fail "tags must be lower-case CSV values without spaces"

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
template="$repo_root/templates/$content_type.md"
destination_dir="$repo_root/drafts/$content_type/$slug"
destination="$destination_dir/index.md"

[[ -f $template ]] || fail "template not found: $template"
[[ ! -e $destination_dir ]] || fail "draft already exists: $destination_dir"

escaped_title=${title//\\/\\\\}
escaped_title=${escaped_title//\"/\\\"}
escaped_title=${escaped_title//\\/\\\\}
escaped_description=${description//\\/\\\\}
escaped_description=${escaped_description//\"/\\\"}
escaped_description=${escaped_description//\\/\\\\}
escaped_title=${escaped_title//&/\\&}
escaped_title=${escaped_title//|/\\|}
escaped_description=${escaped_description//&/\\&}
escaped_description=${escaped_description//|/\\|}
published_at="$(date -u '+%Y-%m-%d %H:%M:%S')"

tmp_file=$(mktemp)
trap 'rm -f "$tmp_file"' EXIT

sed \
  -e "s|__TITLE__|$escaped_title|g" \
  -e "s|__DESCRIPTION__|$escaped_description|g" \
  -e "s|__DATE__|$published_at|g" \
  -e "s|__TAGS__|$tags|g" \
  -e "s|__SLUG__|$slug|g" \
  "$template" > "$tmp_file"

mkdir -p "$destination_dir"
mv "$tmp_file" "$destination"
trap - EXIT

printf 'created draft: %s\n' "${destination#"$repo_root/"}"
