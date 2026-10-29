#!/usr/bin/env bash
# Release each plugin version that has no release yet, then release the index.
#
# Usage: publish.sh [--dry-run]
#
# Run it from the repository root, with every tag fetched. It needs GH_TOKEN
# and GITHUB_REPOSITORY. With --dry-run, it prints what it would release and
# creates nothing. A run that fails halfway can run again: it skips each
# version that already has a release.
set -euo pipefail
shopt -s inherit_errexit

dry_run=false
[[ ${1:-} == --dry-run ]] && dry_run=true

scripts=$(dirname "$(realpath "$0")")
repo=$GITHUB_REPOSITORY
sha=$(git rev-parse HEAD)
note=$(git log -1 --format=%s "$sha")
work=$(mktemp -d)

has_tag() { git rev-parse -q --verify "refs/tags/$1" >/dev/null; }

release() {
  if $dry_run; then
    echo "Dry run: would create the release $1 with: ${*:2}"
  else
    gh release create "$@"
  fi
}

# The previous index, if a publish made one.
prev_tag=$(git tag -l 'index-*' | sort -V | tail -n 1)
previous=$work/previous.json
if [[ -n $prev_tag ]]; then
  gh release download "$prev_tag" --repo "$repo" --pattern marketplace.json --output "$previous"
  n=$((${prev_tag#index-} + 1))
else
  echo '{"plugins": []}' >"$previous"
  n=1
fi
index_tag=index-$n
echo "Previous index: ${prev_tag:-none}. New index: $index_tag."

# 1-2. Release each plugin version that has no release yet.
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
    # Released by an earlier run that failed before its index.
    echo "$tag: released, not in the index yet."
    gh release download "$tag" --repo "$repo" --pattern "$(basename "$archive")" --dir "$work"
  else
    echo "$tag: new."
    "$scripts/pack.sh" "$dir" "$archive"
    assets=("$archive")
    mark=$(jq -r '.extensions["ai.pleasefix.client"].mark // empty' "$dir/plugin.json")
    if [[ -n $mark ]]; then
      mkdir -p "$work/$tag"
      cp "$dir/ai.pleasefix.client/$mark" "$work/$tag/mark.${mark##*.}"
      assets+=("$work/$tag/mark.${mark##*.}")
    fi
    release "$tag" "${assets[@]}" --repo "$repo" --target "$sha" --latest=false \
      --title "$tag" --notes "$note"
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
if ((released == 0)) && [[ -n $prev_tag ]]; then
  "$scripts/build-index.sh" "$prev_tag" "$work/facts.json" "$previous" >"$work/same.json"
  mkdir -p "$work/prev-assets"
  gh release download "$prev_tag" --repo "$repo" --pattern 'requestable-*' --dir "$work/prev-assets" 2>/dev/null || true
  if [[ $(jq -S . "$work/same.json") == $(jq -S . "$previous") ]] &&
    diff -r --exclude marketplace.json "$work/index" "$work/prev-assets" >/dev/null; then
    echo "Nothing changed since $prev_tag. No new index."
    exit 0
  fi
fi

release "$index_tag" "$work"/index/* --repo "$repo" --target "$sha" --latest \
  --title "$index_tag" --notes "$note"

# 5. Check that the new index is the latest release.
if ! $dry_run; then
  latest=$(gh api "repos/$repo/releases/latest" --jq .tag_name)
  if [[ $latest != "$index_tag" ]]; then
    echo "The latest release is $latest, not $index_tag." >&2
    exit 1
  fi
  echo "The latest release is $index_tag."
fi
