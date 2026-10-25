#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: scripts/check-content.sh [--file path/to/index.md]\n' >&2
  exit 64
}

validate_file() {
  local file=$1

  awk -v file="$file" '
    function report(message) {
      printf "%s: %s\n", file, message > "/dev/stderr"
      invalid = 1
    }
    NR == 1 {
      if ($0 != "---") {
        report("frontmatter must start on the first line")
        exit
      }
      in_frontmatter = 1
      next
    }
    in_frontmatter && $0 == "---" {
      closed = 1
      exit
    }
    in_frontmatter {
      if ($0 ~ /^title:[[:space:]]*[^[:space:]]/) title = 1
      if ($0 ~ /^date:[[:space:]]*[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][[:space:]][0-9][0-9]:[0-9][0-9]:[0-9][0-9]([[:space:]].*)?$/) date = 1
      if ($0 ~ /^description:[[:space:]]*[^[:space:]]/) description = 1
      if ($0 ~ /^type:[[:space:]]*(post|page)[[:space:]]*$/) content_type = 1
      if ($0 ~ /^tags:[[:space:]]*[a-z0-9]+(-[a-z0-9]+)*(,[a-z0-9]+(-[a-z0-9]+)*)*[[:space:]]*$/) tags = 1
      if ($0 ~ /^slug:[[:space:]]*[a-z0-9]+(-[a-z0-9]+)*[[:space:]]*$/) slug = 1
      next
    }
    END {
      if (!closed) report("frontmatter closing delimiter is missing")
      if (!title) report("required title is missing or empty")
      if (!date) report("required date must be YYYY-MM-DD HH:MM:SS with optional timezone")
      if (!description) report("required description is missing or empty")
      if (!content_type) report("required type must be post or page")
      if (!tags) report("required tags must be lower-case CSV without spaces")
      if (!slug) report("required slug must be lower-case kebab-case")
      exit invalid
    }
  ' "$file"
}

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

if [[ $# -eq 2 && $1 == "--file" ]]; then
  [[ -f $2 ]] || {
    printf 'error: content file not found: %s\n' "$2" >&2
    exit 1
  }
  validate_file "$2"
  printf 'content check passed: %s\n' "$2"
  exit 0
fi

[[ $# -eq 0 ]] || usage

blog_dir="$repo_root/blog"
if [[ ! -d $blog_dir ]]; then
  printf 'content check passed: no blog directory yet\n'
  exit 0
fi

failed=0
count=0
while IFS= read -r -d '' file; do
  count=$((count + 1))
  if ! validate_file "$file"; then
    failed=1
  fi
done < <(find "$blog_dir" -type f -name index.md -print0)

if [[ $count -eq 0 ]]; then
  printf 'content check passed: no published index.md files\n'
  exit 0
fi

if [[ $failed -ne 0 ]]; then
  printf 'content check failed\n' >&2
  exit 1
fi

printf 'content check passed: %d file(s)\n' "$count"
