#!/usr/bin/env bash
# List the row logos of one plugin folder, one per line: the logo's path, a
# tab, and its asset name in the plugin's release (row-<id>.<ext>). A row's
# logo is integrations/<id>.svg, or else integrations/<id>.png.
#
# Usage: row-logos.sh <plugin folder>
set -euo pipefail
shopt -s inherit_errexit nullglob

integrations=$1/ai.pleasefix.client/integrations
for row in "$integrations"/*.json; do
  id=$(jq -er .id "$row")
  for ext in svg png; do
    if [[ -f $integrations/$id.$ext ]]; then
      printf '%s\trow-%s.%s\n' "$integrations/$id.$ext" "$id" "$ext"
      break
    fi
  done
done
