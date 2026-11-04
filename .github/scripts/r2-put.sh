#!/usr/bin/env bash
# Upload one file to the catalog's bucket, and refuse to change an object that
# exists: a published file never changes.
#
# Usage: r2-put.sh <file> <key> [mutable]
#
# The same bytes at the same key are no change, so a run that failed can run
# again. With `mutable`, the upload replaces the object: only the current index
# does that. It needs R2_BUCKET, R2_S3_ENDPOINT and the AWS_* credentials.
set -euo pipefail
shopt -s inherit_errexit

file=$1
key=$2
mode=${3:-}

case "$key" in
  *.json) type=application/json ;;
  *.tar.gz) type=application/gzip ;;
  *.svg) type=image/svg+xml ;;
  *.png) type=image/png ;;
  *) type=application/octet-stream ;;
esac

# R2 answers with the MD5 of a single-part upload as its ETag.
md5=$(md5sum "$file" | cut -d ' ' -f 1)
args=(--bucket "$R2_BUCKET" --key "$key" --body "$file" --content-type "$type"
  --endpoint-url "$R2_S3_ENDPOINT" --output json)

if [[ $mode == mutable ]]; then
  # Read again each time, so a publish is not hidden by a cache.
  answer=$(aws s3api put-object "${args[@]}" --cache-control 'no-cache')
elif ! answer=$(aws s3api put-object "${args[@]}" --if-none-match '*' \
  --cache-control 'public, max-age=31536000, immutable' 2>"$RUNNER_TEMP/r2-put.$$"); then
  if ! grep -q PreconditionFailed "$RUNNER_TEMP/r2-put.$$"; then
    cat "$RUNNER_TEMP/r2-put.$$" >&2
    exit 1
  fi
  answer=$(aws s3api head-object --bucket "$R2_BUCKET" --key "$key" \
    --endpoint-url "$R2_S3_ENDPOINT" --output json)
fi

etag=$(jq -er .ETag <<<"$answer" | tr -d '"')
if [[ $etag != "$md5" ]]; then
  echo "$key: the bucket holds other bytes ($etag, not $md5)." >&2
  exit 1
fi
