#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Utilisation : scripts/check-content.sh [--file chemin/vers/index.md]\n' >&2
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
        report("le frontmatter doit commencer à la première ligne")
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
      if (!closed) report("le délimiteur fermant du frontmatter est absent")
      if (!title) report("le titre obligatoire est absent ou vide")
      if (!date) report("la date obligatoire doit respecter YYYY-MM-DD HH:MM:SS avec un fuseau horaire facultatif")
      if (!description) report("la description obligatoire est absente ou vide")
      if (!content_type) report("le type obligatoire doit être post ou page")
      if (!tags) report("les tags obligatoires doivent être une liste CSV en minuscules sans espaces")
      if (!slug) report("le slug obligatoire doit être en kebab-case minuscule")
      exit invalid
    }
  ' "$file"
}

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

if [[ $# -eq 2 && $1 == "--file" ]]; then
  [[ -f $2 ]] || {
    printf 'erreur : fichier de contenu introuvable : %s\n' "$2" >&2
    exit 1
  }
  validate_file "$2"
  printf 'validation du contenu réussie : %s\n' "$2"
  exit 0
fi

[[ $# -eq 0 ]] || usage

blog_dir="$repo_root/blog"
if [[ ! -d $blog_dir ]]; then
  printf 'validation du contenu réussie : aucun répertoire blog pour le moment\n'
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
  printf 'validation du contenu réussie : aucun fichier index.md publié\n'
  exit 0
fi

if [[ $failed -ne 0 ]]; then
  printf 'échec de la validation du contenu\n' >&2
  exit 1
fi

printf 'validation du contenu réussie : %d fichier(s)\n' "$count"
