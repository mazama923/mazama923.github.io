#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)
test_root=$(mktemp -d "${TMPDIR:-/tmp}/publish-draft-test.XXXXXXXX")
trap 'rm -rf "$test_root"' EXIT

case_number=0
case_root=

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

new_case() {
  case_number=$((case_number + 1))
  case_root="$test_root/case-$case_number"
  mkdir -p "$case_root/scripts" "$case_root/drafts/post" "$case_root/drafts/page" \
    "$case_root/blog/posts" "$case_root/blog/pages" "$case_root/targets"
  cp "$repo_root/scripts/publish-draft.sh" "$repo_root/scripts/check-content.sh" "$case_root/scripts/"
  chmod +x "$case_root/scripts/publish-draft.sh" "$case_root/scripts/check-content.sh"
}

write_content() {
  local directory=$1 type=$2 slug=$3 body=$4 extra=${5:-}
  mkdir -p "$directory"
  cat > "$directory/index.md" <<EOF
---
title: Synthetic content
date: 2026-01-01 12:00:00
description: Synthetic description
type: $type
tags: test,synthetic
slug: $slug
$extra
---

$body
EOF
}

write_draft() {
  write_content "$case_root/drafts/$1/$2" "$1" "$2" 'Draft body'
}

write_published() {
  write_content "$case_root/blog/${1}s/$2" "$1" "$2" 'Published body'
}

assert_absent() {
  [[ ! -e $1 && ! -L $1 ]] || fail "unexpected path: $1"
}

assert_same_file() {
  [[ -f $1 && -f $2 ]] && cmp -s "$1" "$2" || fail "files differ: $1 and $2"
}

# Compare paths, file contents and link targets without following symbolic links.
assert_tree_unchanged() {
  local snapshot=$1 path
  (cd "$snapshot" && find . -print | LC_ALL=C sort) > "$test_root/before.list"
  (cd "$case_root" && find . -print | LC_ALL=C sort) > "$test_root/after.list"
  cmp -s "$test_root/before.list" "$test_root/after.list" || fail 'paths changed after rejection'
  while IFS= read -r path; do
    if [[ -L $snapshot/$path ]]; then
      [[ -L $case_root/$path ]] || fail "link changed after rejection: $path"
      [[ $(readlink "$snapshot/$path") == "$(readlink "$case_root/$path")" ]] || \
        fail "link target changed after rejection: $path"
    elif [[ -d $snapshot/$path ]]; then
      [[ -d $case_root/$path && ! -L $case_root/$path ]] || fail "directory changed after rejection: $path"
    elif [[ -f $snapshot/$path ]]; then
      [[ -f $case_root/$path && ! -L $case_root/$path ]] || fail "file changed after rejection: $path"
      assert_same_file "$snapshot/$path" "$case_root/$path"
    else
      fail "unsupported fixture path: $path"
    fi
  done < "$test_root/before.list"
}

expect_rejection() {
  local expected=$1
  shift
  local snapshot="$test_root/snapshot-$case_number"
  mkdir -p "$snapshot"
  cp -R -P "$case_root/." "$snapshot/"
  if "$case_root/scripts/publish-draft.sh" "$@" > "$test_root/output" 2>&1; then
    fail "publication unexpectedly succeeded: $*"
  fi
  if ! grep -F -q "$expected" "$test_root/output"; then
    cat "$test_root/output" >&2
    fail "expected rejection containing: $expected"
  fi
  assert_tree_unchanged "$snapshot"
}

# Normal publication moves the entire draft, including assets, for both types.
for type in post page; do
  new_case
  write_draft "$type" example
  mkdir -p "$case_root/drafts/$type/example/images"
  printf 'image data\n' > "$case_root/drafts/$type/example/images/image.txt"
  printf 'hidden data\n' > "$case_root/drafts/$type/example/.asset"
  cp "$case_root/drafts/$type/example/index.md" "$test_root/expected-index"
  "$case_root/scripts/publish-draft.sh" "$type" example > "$test_root/output" 2>&1 || \
    fail "normal publication failed for $type: $(cat "$test_root/output")"
  assert_same_file "$test_root/expected-index" "$case_root/blog/${type}s/example/index.md"
  [[ $(cat "$case_root/blog/${type}s/example/images/image.txt") == 'image data' ]] || fail 'asset not published'
  [[ $(cat "$case_root/blog/${type}s/example/.asset") == 'hidden data' ]] || fail 'hidden asset not published'
  assert_absent "$case_root/drafts/$type/example"
done

# Existing content must not be overwritten without explicit replacement.
new_case
write_draft post example
write_published post example
printf 'published asset\n' > "$case_root/blog/posts/example/asset.txt"
expect_rejection 'le contenu publié existe déjà' post example

# Replacement updates only index.md, retains published assets and consumes the draft.
for type in post page; do
  new_case
  write_draft "$type" example
  write_published "$type" example
  printf 'published asset\n' > "$case_root/blog/${type}s/example/asset.txt"
  cp "$case_root/drafts/$type/example/index.md" "$test_root/expected-index"
  cp "$case_root/blog/${type}s/example/asset.txt" "$test_root/expected-asset"
  "$case_root/scripts/publish-draft.sh" "$type" example --replace > "$test_root/output" 2>&1 || \
    fail "replacement failed for $type: $(cat "$test_root/output")"
  assert_same_file "$test_root/expected-index" "$case_root/blog/${type}s/example/index.md"
  assert_same_file "$test_root/expected-asset" "$case_root/blog/${type}s/example/asset.txt"
  assert_absent "$case_root/drafts/$type/example"
done

# Fail after the temporary file is created, before the published index is replaced.
for command_name in cp mv; do
  new_case
  write_draft post example
  write_published post example
  printf 'published asset\n' > "$case_root/blog/posts/example/asset.txt"
  mkdir "$case_root/bin"
  cat > "$case_root/bin/$command_name" <<'EOF'
#!/usr/bin/env bash
if [[ $PUBLISH_TEST_COMMAND == cp && ${1:-} == "$PUBLISH_TEST_DRAFT" && \
      ${2:-} == "$PUBLISH_TEST_DEST_DIR"/.index.md.* && -f ${2:-} ]] || \
   [[ $PUBLISH_TEST_COMMAND == mv && ${1:-} == -f && \
      ${2:-} == "$PUBLISH_TEST_DEST_DIR"/.index.md.* && -f ${2:-} && \
      ${3:-} == "$PUBLISH_TEST_DEST_DIR/index.md" ]]; then
  printf 'injected %s failure\n' "$PUBLISH_TEST_COMMAND" >&2
  exit 1
fi
exec "$PUBLISH_TEST_REAL_COMMAND" "$@"
EOF
  chmod +x "$case_root/bin/$command_name"
  real_command=$(command -v "$command_name")
  physical_case_root=$(cd "$case_root" && pwd -P)
  PATH="$case_root/bin:$PATH" \
    PUBLISH_TEST_COMMAND="$command_name" \
    PUBLISH_TEST_REAL_COMMAND="$real_command" \
    PUBLISH_TEST_DRAFT="$physical_case_root/drafts/post/example/index.md" \
    PUBLISH_TEST_DEST_DIR="$physical_case_root/blog/posts/example" \
    expect_rejection "injected $command_name failure" post example --replace
done

for destination in absent missing-index; do
  new_case
  write_draft post example
  if [[ $destination == missing-index ]]; then
    mkdir -p "$case_root/blog/posts/example"
    printf 'published asset\n' > "$case_root/blog/posts/example/asset.txt"
  fi
  expect_rejection 'contenu publié introuvable' post example --replace
done

# Replacement must reject every extra draft entry, including hidden files and links.
for asset in file hidden directory link; do
  new_case
  write_draft post example
  write_published post example
  printf 'published asset\n' > "$case_root/blog/posts/example/asset.txt"
  case $asset in
    file) printf 'draft asset\n' > "$case_root/drafts/post/example/asset.txt" ;;
    hidden) printf 'hidden draft asset\n' > "$case_root/drafts/post/example/.asset" ;;
    directory) mkdir "$case_root/drafts/post/example/images" ;;
    link)
      printf 'link target\n' > "$case_root/targets/asset.txt"
      ln -s "$case_root/targets/asset.txt" "$case_root/drafts/post/example/asset-link"
      ;;
  esac
  expect_rejection 'le brouillon contient des fichiers annexes' post example --replace
done

# Exercise validation in both publication modes; valid duplicate fields are still invalid.
for mode in normal replace; do
  for variant in invalid-header missing-title wrong-type wrong-slug duplicate-type duplicate-slug quoted-type quoted-slug; do
    new_case
    write_draft post example
    case $variant in
      invalid-header)
        printf 'Not frontmatter\n' > "$case_root/drafts/post/example/index.md"
        expected='le frontmatter doit commencer'
        ;;
      missing-title)
        awk '!/^title:/' "$case_root/drafts/post/example/index.md" > "$case_root/edited"
        mv "$case_root/edited" "$case_root/drafts/post/example/index.md"
        expected='le titre obligatoire'
        ;;
      wrong-type)
        write_content "$case_root/drafts/post/example" page example 'Draft body'
        expected='le type et le slug du frontmatter'
        ;;
      wrong-slug)
        write_content "$case_root/drafts/post/example" post other 'Draft body'
        expected='le type et le slug du frontmatter'
        ;;
      duplicate-type)
        write_content "$case_root/drafts/post/example" post example 'Draft body' 'type: post'
        expected='le type et le slug du frontmatter'
        ;;
      duplicate-slug)
        write_content "$case_root/drafts/post/example" post example 'Draft body' 'slug: example'
        expected='le type et le slug du frontmatter'
        ;;
      quoted-type)
        write_content "$case_root/drafts/post/example" post example 'Draft body' '"type": post'
        expected='le type et le slug du frontmatter'
        ;;
      quoted-slug)
        write_content "$case_root/drafts/post/example" post example 'Draft body' "'slug': example"
        expected='le type et le slug du frontmatter'
        ;;
    esac
    if [[ $mode == replace ]]; then
      write_published post example
      printf 'published asset\n' > "$case_root/blog/posts/example/asset.txt"
      expect_rejection "$expected" post example --replace
    else
      expect_rejection "$expected" post example
    fi
  done
done

# Every path component checked by the publisher must reject symbolic links.
for component in drafts draft-type draft-dir draft-file blog blog-type published-dir published-file; do
  new_case
  write_draft post example
  write_published post example
  case $component in
    drafts) path="$case_root/drafts" ;;
    draft-type) path="$case_root/drafts/post" ;;
    draft-dir) path="$case_root/drafts/post/example" ;;
    draft-file) path="$case_root/drafts/post/example/index.md" ;;
    blog) path="$case_root/blog" ;;
    blog-type) path="$case_root/blog/posts" ;;
    published-dir) path="$case_root/blog/posts/example" ;;
    published-file) path="$case_root/blog/posts/example/index.md" ;;
  esac
  mv "$path" "$case_root/targets/link-target"
  ln -s "$case_root/targets/link-target" "$path"
  expect_rejection 'lien symbolique interdit' post example --replace
done

# A link nested inside an otherwise valid draft must also be rejected in normal mode.
new_case
write_draft post example
mkdir -p "$case_root/drafts/post/example/images"
printf 'link target\n' > "$case_root/targets/asset.txt"
ln -s "$case_root/targets/asset.txt" "$case_root/drafts/post/example/images/asset-link"
expect_rejection 'liens symboliques interdits' post example

printf 'PASS: %s isolated publication cases\n' "$case_number"
