#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage: scripts/render-diagrams.sh [--all|--published]

Render Mermaid (*.mmd) diagrams into static SVG assets.
EOF
  exit 64
}

scope=${1:---all}

case "$scope" in
  --all)
    roots=("drafts" "blog")
    ;;
  --published)
    roots=("blog")
    ;;
  *)
    usage
    ;;
esac

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
sources=()

output_for_source() {
  local source=$1
  local content_type
  local content_path

  case "$source" in
    "$repo_root/drafts/post/"*)
      content_type=post
      content_path=${source#"$repo_root/drafts/post/"}
      ;;
    "$repo_root/drafts/page/"*)
      content_type=page
      content_path=${source#"$repo_root/drafts/page/"}
      ;;
    "$repo_root/blog/posts/"*)
      content_type=post
      content_path=${source#"$repo_root/blog/posts/"}
      ;;
    "$repo_root/blog/pages/"*)
      content_type=page
      content_path=${source#"$repo_root/blog/pages/"}
      ;;
    *)
      printf 'error: unsupported Mermaid source: %s\n' "$source" >&2
      return 1
      ;;
  esac

  printf '%s\n' "$repo_root/static/assets/diagrams/$content_type/${content_path%.mmd}.svg"
}

for root in "${roots[@]}"; do
  directory="$repo_root/$root"
  [[ -d $directory ]] || continue

  while IFS= read -r -d '' source; do
    sources+=("$source")
  done < <(find "$directory" -type f -name '*.mmd' -print0)
done

if [[ ${#sources[@]} -eq 0 ]]; then
  printf 'No Mermaid diagram to render.\n'
  exit 0
fi

if ! command -v mmdc >/dev/null 2>&1; then
  for source in "${sources[@]}"; do
    output=$(output_for_source "$source")
    [[ -f $output ]] || {
      printf 'error: Mermaid CLI (mmdc) is required to create %s\n' "${output#"$repo_root/"}" >&2
      exit 127
    }
  done

  printf 'Mermaid CLI not found; using committed SVG files.\n'
  exit 0
fi

browser_path=${PUPPETEER_EXECUTABLE_PATH:-}

if [[ -z $browser_path ]]; then
  for candidate in \
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
    "/Applications/Chromium.app/Contents/MacOS/Chromium"
  do
    if [[ -x $candidate ]]; then
      browser_path=$candidate
      break
    fi
  done
fi

if [[ -z $browser_path ]]; then
  for candidate in google-chrome google-chrome-stable chromium chromium-browser; do
    if command -v "$candidate" >/dev/null 2>&1; then
      browser_path=$(command -v "$candidate")
      break
    fi
  done
fi

for source in "${sources[@]}"; do
  output=$(output_for_source "$source")
  mkdir -p "$(dirname "$output")"

  if [[ -n $browser_path ]]; then
    PUPPETEER_EXECUTABLE_PATH="$browser_path" mmdc \
      --quiet \
      --theme dark \
      --backgroundColor transparent \
      --size 1200 \
      --input "$source" \
      --output "$output"
  else
    mmdc \
      --quiet \
      --theme dark \
      --backgroundColor transparent \
      --size 1200 \
      --input "$source" \
      --output "$output"
  fi

  printf 'Rendered %s\n' "${output#"$repo_root/"}"
done
