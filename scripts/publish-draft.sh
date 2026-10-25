#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: scripts/publish-draft.sh <post|page> <slug>\n' >&2
  exit 64
}

fail() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

[[ $# -eq 2 ]] || usage

content_type=$1
slug=$2

case "$content_type" in
  post|page) ;;
  *) fail "content type must be post or page" ;;
esac

[[ $slug =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || fail "slug must be lowercase kebab-case"

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source_file="$repo_root/drafts/$content_type/$slug/index.md"
destination_dir="$repo_root/blog/${content_type}s/$slug"
destination_file="$destination_dir/index.md"

[[ -f $source_file ]] || fail "draft not found: ${source_file#"$repo_root/"}"
[[ ! -e $destination_dir ]] || fail "published content already exists: ${destination_dir#"$repo_root/"}"

"$repo_root/scripts/check-content.sh" --file "$source_file"

mkdir -p "$(dirname "$destination_dir")"
mv "$(dirname "$source_file")" "$destination_dir"

printf 'published: %s\n' "${destination_file#"$repo_root/"}"
