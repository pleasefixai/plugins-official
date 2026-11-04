#!/usr/bin/env bash
# Upload each plugin version that has no tag yet, then upload the index.
#
# Usage: publish.sh [--dry-run]
#
# Run it from the repository root, with every tag fetched. It needs R2_BUCKET,
# R2_S3_ENDPOINT and the AWS_* credentials, and a token that can push tags. With
# --dry-run, it prints what it would publish and writes nothing. A run that fails
# halfway can run again: the same bytes at the same key are no change, and a
# version that has its tag comes back from the bucket.
set -euo pipefail
shopt -s inherit_errexit nullglob

dry_run=false
[[ ${1:-} == --dry-run ]] && dry_run=true

scripts=$(dirname "$(realpath "$0")")
public=https://plugins.pleasefix.ai
sha=$(git rev-parse HEAD)
work=$(mktemp -d)

has_tag() { git rev-parse -q --verify "refs/tags/$1" >/dev/null; }

# put <file> <key> [mutable]
put() {
  if $dry_run; then
    echo "Dry run: would upload $2."
  else
    "$scripts/r2-put.sh" "$@"
  fi
}

# Tags come last: a version with its tag is in the bucket.
push_tag() {
  if $dry_run; then
    echo "Dry run: would create the tag $1."
  else
    git tag "$1" "$sha"
    git push --quiet origin "refs/tags/$1"
  fi
}

# The previous index, if a publish made one.
prev_tag=$(git tag -l 'index-*' | sort -V | tail -n 1)
previous=$work/previous.json
if [[ -n $prev_tag ]]; then
  curl -sSf --retry 3 "$public/marketplace.json" -o "$previous"
  n=$((${prev_tag#index-} + 1))
else
  echo '{"plugins": []}' >"$previous"
  n=1
fi
index_tag=index-$n
echo "Previous index: ${prev_tag:-none}. New index: $index_tag."

# 1-2. Upload each plugin version that has no tag yet.
echo '{}' >"$work/facts.json"
released=0
for dir in plugins/*/; do
  dir=${dir%/}
  name=$(jq -er .name "$dir/plugin.json")
  version=$(jq -er .version "$dir/plugin.json")
  tag=$name@$version
  archive=$work/$name-$version.tar.gz
  listed=$(jq --arg n "$name" --arg v "$version" \
    'any(.plugins[] | select(.name == $n) | .versions[]; .version == $v)' "$previous")
  if [[ $listed == true ]]; then
    continue
  elif has_tag "$tag"; then
    # Uploaded by an earlier run that failed before its index.
    echo "$tag: uploaded, not in the index yet."
    curl -sSf --retry 3 "$public/plugins/$name/$version/$(basename "$archive")" -o "$archive"
  else
    echo "$tag: new."
    "$scripts/pack.sh" "$dir" "$archive"
    folder=plugins/$name/$version
    put "$archive" "$folder/$(basename "$archive")"
    mark=$(jq -r '.extensions["ai.pleasefix.client"].mark // empty' "$dir/plugin.json")
    if [[ -n $mark ]]; then
      put "$dir/ai.pleasefix.client/$mark" "$folder/mark.${mark##*.}"
    fi
    while IFS=$'\t' read -r logo asset; do
      put "$logo" "$folder/$asset"
    done < <("$scripts/row-logos.sh" "$dir")
    push_tag "$tag"
    released=$((released + 1))
  fi
  jq --arg n "$name" --arg sha256 "$(sha256sum "$archive" | cut -d ' ' -f 1)" \
    --argjson size "$(stat -c %s "$archive")" '.[$n] = {sha256: $sha256, size: $size}' \
    "$work/facts.json" >"$work/facts.tmp" && mv "$work/facts.tmp" "$work/facts.json"
done
echo "New plugin versions: $released."

# 3. Generate the index.
mkdir -p "$work/index"
"$scripts/build-index.sh" "$index_tag" "$work/facts.json" "$previous" >"$work/index/marketplace.json"
jq -r '.plugins[] | "\(.name): \([.versions[].version] | join(", "))"' "$work/index/marketplace.json"

count() { jq '[.plugins[].versions[]] | length' "$1"; }
if (($(count "$work/index/marketplace.json") < $(count "$previous"))); then
  echo "The new index lists fewer versions than $prev_tag." >&2
  exit 1
fi

# The requestable logos, named as the index names them.
for url in $(jq -r '.requestable[].mark // empty' "$work/index/marketplace.json"); do
  asset=$(basename "$url")
  id_ext=${asset#requestable-}
  cp "requestable/$id_ext" "$work/index/$asset"
done

# 4. Stop if nothing changed: same index, same requestable logos.
if ((released == 0)) && [[ -z $prev_tag ]] &&
  [[ $(jq '(.plugins + .requestable) | length' "$work/index/marketplace.json") == 0 ]]; then
  echo "The catalog is empty. No index."
  exit 0
fi
if ((released == 0)) && [[ -n $prev_tag ]]; then
  "$scripts/build-index.sh" "$prev_tag" "$work/facts.json" "$previous" >"$work/same.json"
  mkdir -p "$work/prev-assets"
  for url in $(jq -r '.requestable[].mark // empty' "$previous"); do
    curl -sSf --retry 3 "$url" -o "$work/prev-assets/$(basename "$url")"
  done
  if [[ $(jq -S . "$work/same.json") == "$(jq -S . "$previous")" ]] &&
    diff -r --exclude marketplace.json "$work/index" "$work/prev-assets" >/dev/null; then
    echo "Nothing changed since $prev_tag. No new index."
    exit 0
  fi
fi

# 5. Upload the index folder, then the current index, then the tag.
for file in "$work"/index/*; do
  put "$file" "indexes/$index_tag/$(basename "$file")"
done
put "$work/index/marketplace.json" marketplace.json mutable
push_tag "$index_tag"

# 6. Check that the bucket serves the new index.
if ! $dry_run; then
  curl -sSf --retry 3 -H 'Cache-Control: no-cache' "$public/marketplace.json" -o "$work/served.json"
  if ! cmp -s "$work/index/marketplace.json" "$work/served.json"; then
    echo "The bucket does not serve the index of $index_tag." >&2
    exit 1
  fi
  echo "The bucket serves $index_tag."
fi
