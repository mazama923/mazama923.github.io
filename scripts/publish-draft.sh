#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Utilisation : scripts/publish-draft.sh <post|page> <slug> [--replace]\n' >&2
  exit 64
}

fail() {
  printf 'erreur : %s\n' "$*" >&2
  exit 1
}

[[ $# -ge 2 && $# -le 3 ]] || usage

content_type=$1
slug=$2
option=${3:-}

case "$option" in
  ""|--replace) ;;
  *) usage ;;
esac

case "$content_type" in
  post|page) ;;
  *) fail "le type de contenu doit être post ou page" ;;
esac

[[ $slug =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || fail "le slug doit être en kebab-case minuscule"

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)
source_dir="$repo_root/drafts/$content_type/$slug"
source_file="$source_dir/index.md"
destination_parent="$repo_root/blog/${content_type}s"
destination_dir="$destination_parent/$slug"
destination_file="$destination_dir/index.md"

for path in "$repo_root/drafts" "$repo_root/drafts/$content_type" "$source_dir" "$source_file" \
  "$repo_root/blog" "$destination_parent" "$destination_dir" "$destination_file"; do
  [[ ! -L $path ]] || fail "lien symbolique interdit : ${path#"$repo_root/"}"
done

[[ -f $source_file ]] || fail "brouillon introuvable : ${source_file#"$repo_root/"}"

if [[ $option == --replace ]]; then
  [[ -d $destination_dir && -f $destination_file ]] || fail "contenu publié introuvable : ${destination_file#"$repo_root/"}"
  shopt -s dotglob nullglob
  for path in "$source_dir"/*; do
    [[ $path == "$source_file" ]] || fail "remplacement impossible : le brouillon contient des fichiers annexes ; conservez-les et traitez-les manuellement"
  done
  shopt -u dotglob nullglob
else
  [[ ! -e $destination_dir ]] || fail "le contenu publié existe déjà : ${destination_dir#"$repo_root/"}"
  for path in "$repo_root/blog" "$destination_parent"; do
    [[ ! -e $path || -d $path ]] || fail "répertoire de publication invalide : ${path#"$repo_root/"}"
  done
  links=$(find "$source_dir" -type l -print) || fail "impossible de vérifier les liens symboliques du brouillon"
  [[ -z $links ]] || fail "le brouillon contient des liens symboliques interdits"
fi

"$repo_root/scripts/check-content.sh" --file "$source_file"

awk -v expected_type="$content_type" -v expected_slug="$slug" '
  NR == 1 { next }
  $0 == "---" { exit }
  /^(type|"type"|\047type\047)[[:space:]]*:/ {
    types++
    if ($0 !~ "^type:[[:space:]]*" expected_type "[[:space:]]*$") invalid = 1
  }
  /^(slug|"slug"|\047slug\047)[[:space:]]*:/ {
    slugs++
    if ($0 !~ "^slug:[[:space:]]*" expected_slug "[[:space:]]*$") invalid = 1
  }
  END { if (types != 1 || slugs != 1 || invalid) exit 1 }
' "$source_file" || fail "le type et le slug du frontmatter doivent correspondre aux arguments, sans doublons"

if [[ $option == --replace ]]; then
  temp_file=$(mktemp "$destination_dir/.index.md.XXXXXXXX") || fail "impossible de créer le fichier temporaire"
  trap 'rm -f "$temp_file"' EXIT
  cp -p "$destination_file" "$temp_file"
  cp "$source_file" "$temp_file"
  mv -f "$temp_file" "$destination_file"
  trap - EXIT

  if ! rm "$source_file"; then
    printf 'avertissement : le contenu a été remplacé, mais le brouillon n’a pas pu être supprimé\n' >&2
  elif ! rmdir "$source_dir"; then
    printf 'avertissement : le contenu a été remplacé, mais le répertoire du brouillon n’a pas pu être supprimé\n' >&2
  fi
else
  mkdir -p "$destination_parent"
  mv "$source_dir" "$destination_dir"
fi

printf 'publié : %s\n' "${destination_file#"$repo_root/"}"
