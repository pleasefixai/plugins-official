#!/usr/bin/env bash
# Copy what the newest GitHub index lists to the catalog's bucket, then write the
# index with its addresses moved. It runs once, when the catalog moves off GitHub
# releases. A run that failed can run again.
#
# Usage: copy-to-r2.sh [--dry-run]
#
# Run it from the repository root, with every tag fetched. With --dry-run, it
# checks every download against the index and writes nothing to the bucket. It
# needs GH_TOKEN and GITHUB_REPOSITORY, and, to write, R2_BUCKET, R2_S3_ENDPOINT
# and the AWS_* credentials.
set -euo pipefail
shopt -s inherit_errexit

dry_run=false
[[ ${1:-} == --dry-run ]] && dry_run=true

scripts=$(dirname "$(realpath "$0")")
repo=$GITHUB_REPOSITORY
public=https://plugins.pleasefix.ai
releases="https://github.com/$repo/releases/download"
work=$(mktemp -d)
export scripts dry_run work

tag=$(git tag -l 'index-*' | sort -V | tail -n 1)
gh release download "$tag" --repo "$repo" --pattern marketplace.json --output "$work/github.json"
echo "Copying $tag: $(jq '[.plugins[].versions[]] | length' "$work/github.json") versions."

# copy_one <GitHub address> <key> <size or empty> <sha256 or empty>
copy_one() {
  local url=$1 key=$2 size=$3 sha=$4 file
  file=$(mktemp -p "$work")
  curl -sSfL --retry 8 --retry-all-errors --max-time 300 -o "$file" "$url"
  if [[ -n $size ]] && [[ $(stat -c %s "$file") != "$size" ]]; then
    echo "$url: not $size bytes." >&2
    exit 1
  fi
  if [[ -n $sha ]] && [[ $(sha256sum "$file" | cut -d ' ' -f 1) != "${sha#sha256:}" ]]; then
    echo "$url: not the index's SHA-256." >&2
    exit 1
  fi
  $dry_run || "$scripts/r2-put.sh" "$file" "$key"
  rm -f "$file"
}

# copy_line <address, key, size and SHA-256, split by tabs>
copy_line() {
  local url key size sha
  IFS=$'\t' read -r url key size sha <<<"$1"
  copy_one "$url" "$key" "$size" "$sha"
}

# check_address <address and size, split by a tab>
check_address() {
  local url size got
  IFS=$'\t' read -r url size <<<"$1"
  got=$(curl -sSfIL --retry 3 "$url" | tr -d '\r' | awk 'tolower($1)=="content-length:"{n=$2} END{print n}')
  if [[ $got != "$size" ]]; then
    echo "$url: $got bytes, not $size." >&2
    exit 1
  fi
}
export -f copy_one copy_line check_address

# One line per file: address, key, size, SHA-256. A logo has no size or checksum
# in the index. GitHub drops connections when many open at once, so four at a time.
jq -r --arg releases "$releases" '
  def key: ltrimstr($releases + "/") | split("/") as $p | ($p[0] | split("@")) as $n
    | "plugins/\($n[0])/\($n[1])/\($p[1])";
  (.plugins[] | .versions[] | [.url, (.url | key), .size, .sha256]),
  (.plugins[] | .mark // empty | [., key, "", ""]),
  (.plugins[] | .rows[]? | .mark // empty | [., key, "", ""]),
  (.requestable[] | .mark // empty | [., "indexes/" + (ltrimstr($releases + "/") | split("/") | "\(.[0])/\(.[1])"), "", ""])
  | @tsv' "$work/github.json" >"$work/files.tsv"
echo "Files: $(wc -l <"$work/files.tsv")."
# shellcheck disable=SC2016
xargs -P 4 -n 1 -d '\n' bash -c 'set -euo pipefail; copy_line "$0"' <"$work/files.tsv"

# The same index, with each address on the bucket.
jq --arg releases "$releases" --arg public "$public" '
  def moved: ltrimstr($releases + "/") | split("/") as $p | ($p[0] | split("@")) as $n
    | "\($public)/plugins/\($n[0])/\($n[1])/\($p[1])";
  .plugins |= map(
    .versions |= map(.url |= moved)
    | (if .mark then .mark |= moved else . end)
    | (if .rows then .rows |= map(if .mark then .mark |= moved else . end) else . end))
  | .requestable |= map(if .mark then
      .mark |= ("\($public)/indexes/" + (ltrimstr($releases + "/") | split("/") | "\(.[0])/\(.[1])"))
    else . end)' "$work/github.json" >"$work/marketplace.json"

left=$(grep -c "$releases" "$work/marketplace.json" || true)
if [[ $left != 0 ]]; then
  echo "The moved index still names GitHub, on $left lines." >&2
  exit 1
fi
if $dry_run; then
  echo "Dry run: every download matches $tag, and nothing was written."
  exit 0
fi
"$scripts/r2-put.sh" "$work/marketplace.json" "indexes/$tag/marketplace.json"
"$scripts/r2-put.sh" "$work/marketplace.json" marketplace.json mutable

# Read it back as a user does: every address must answer with the right size.
curl -sSf "$public/marketplace.json" -o "$work/served.json"
cmp "$work/marketplace.json" "$work/served.json"
# shellcheck disable=SC2016
jq -r '.plugins[].versions[] | [.url, .size] | @tsv' "$work/served.json" |
  xargs -P 8 -n 1 -d '\n' bash -c 'set -euo pipefail; check_address "$0"'
jq -r '(.plugins[] | .mark // empty), (.plugins[] | .rows[]? | .mark // empty), (.requestable[] | .mark // empty)' "$work/served.json" |
  xargs -P 8 -I {} curl -sSfIL --retry 3 -o /dev/null {}
echo "Copied $tag to $public: every address answers."
