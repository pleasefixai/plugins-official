#!/usr/bin/env bash
# Check the plugin folders that a change touches, against the released tags.
#
# Usage: check-plugins.sh <base commit>
#
# Run it from the repository root, with every tag fetched. It fails if:
# - a plugin folder of the base commit is gone;
# - a changed plugin's version already has a release, or is not higher than
#   its newest release;
# - the repository holds a symbolic link, or a file over 5 MB.
set -euo pipefail
shopt -s inherit_errexit

base=$1
failed=0
fail() {
  echo "::error::$*"
  failed=1
}

for dir in $(git ls-tree -d --name-only "$base" plugins/); do
  [[ -d $dir ]] || fail "$dir is deleted. A plugin leaves through a version that is withdrawn."
done

for name in $(git diff --name-only "$base" HEAD -- 'plugins/*/*' | cut -d / -f 2 | sort -u); do
  dir=plugins/$name
  [[ -d $dir ]] || continue
  if ! version=$(jq -er .version "$dir/plugin.json"); then
    fail "$dir/plugin.json has no version."
    continue
  fi
  newest=$(git tag -l "$name@*" | sed "s/^$name@//" | sort -V | tail -n 1)
  if git rev-parse -q --verify "refs/tags/$name@$version" >/dev/null; then
    fail "$name changes, but $name@$version is already released. Raise its version."
  elif [[ -n $newest && $(printf '%s\n' "$newest" "$version" | sort -V | tail -n 1) != "$version" ]]; then
    fail "$name@$version is lower than its newest release, $name@$newest."
  else
    echo "$name@$version: ok (newest release: ${newest:-none})."
  fi
done

while IFS= read -r -d '' path; do
  fail "${path#./} is a symbolic link."
done < <(find . -path ./.git -prune -o -type l -print0)

while IFS= read -r -d '' path; do
  fail "${path#./} is larger than 5 MB."
done < <(find . -path ./.git -prune -o -type f -size +5M -print0)

exit $failed
