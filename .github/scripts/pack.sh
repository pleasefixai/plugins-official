#!/usr/bin/env bash
# Pack one plugin folder into a .tar.gz archive, with the folder's contents at
# the archive's root. The same folder always gives the same bytes.
#
# Usage: pack.sh <plugin folder> <out.tar.gz>
set -euo pipefail

folder=$1
out=$(realpath -m "$2")

(cd "$folder" && find . -mindepth 1 -printf '%P\0' | LC_ALL=C sort -z) |
  tar --create --format=gnu --sort=name --mtime=@0 --owner=0 --group=0 --numeric-owner \
    --mode='u+rw,go+r,go-w' --directory "$folder" --no-recursion --null --files-from - |
  gzip -n -9 >"$out"
