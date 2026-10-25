#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Utilisation : scripts/new-content.sh <post|page> <slug> <titre> <description> <tags>

Les tags doivent être une liste CSV en minuscules sans espaces, par exemple :
  devops,observability
EOF
  exit 64
}

fail() {
  printf 'erreur : %s\n' "$*" >&2
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
  *) fail "le type de contenu doit être post ou page" ;;
esac

[[ $slug =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || fail "le slug doit être en kebab-case minuscule"
[[ ${#slug} -le 80 ]] || fail "le slug doit comporter au plus 80 caractères"
[[ -n $title && $title != *$'\n'* && $title != *$'\r'* ]] || fail "le titre doit tenir sur une seule ligne non vide"
[[ -n $description && $description != *$'\n'* && $description != *$'\r'* ]] || fail "la description doit tenir sur une seule ligne non vide"
[[ $tags =~ ^[a-z0-9]+(-[a-z0-9]+)*(,[a-z0-9]+(-[a-z0-9]+)*)*$ ]] || fail "les tags doivent être une liste CSV en minuscules sans espaces"

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
template="$repo_root/templates/$content_type.md"
destination_dir="$repo_root/drafts/$content_type/$slug"
destination="$destination_dir/index.md"

[[ -f $template ]] || fail "modèle introuvable : $template"
[[ ! -e $destination_dir ]] || fail "le brouillon existe déjà : $destination_dir"

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

printf 'brouillon créé : %s\n' "${destination#"$repo_root/"}"
