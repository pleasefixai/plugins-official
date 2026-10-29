#!/usr/bin/env bash
# Write the catalog index (marketplace.json) to stdout, from the plugin folders
# and the requestable entries.
#
# Usage: build-index.sh <index tag> <facts.json> [<previous index>]
#
# Run it from the repository root. <index tag> is the tag of the index release
# that will hold the requestable logos. <facts.json> maps a plugin name to
# {"sha256", "size"} of its latest version's archive. A plugin with no facts
# takes them from the previous index, which must then list its latest version.
# Each plugin's older versions come from the previous index, as they are.
set -euo pipefail
shopt -s inherit_errexit nullglob

index_tag=$1
facts=$2
previous=${3:-}
if [[ -z $previous ]]; then
  previous=$(mktemp)
  echo '{"plugins": []}' >"$previous"
fi

base="https://github.com/${GITHUB_REPOSITORY:-pleasefixai/plugins-official}/releases/download"
ext_key='ai.pleasefix.client'
scripts=$(dirname "$(realpath "$0")")

plugins=$(
  for dir in plugins/*/; do
    dir=${dir%/}
    rows=("$dir/$ext_key"/integrations/*.json)
    skills=("$dir"/skills/*/SKILL.md)
    category=other
    if ((${#rows[@]} == 1)); then
      category=$(jq -er '.group' "${rows[0]}") || { echo "$dir: the row has no group" >&2; exit 1; }
    fi
    logos=$("$scripts/row-logos.sh" "$dir" | jq -R -n '[inputs | split("\t") | {key: (.[1] | ltrimstr("row-") | sub("\\.[^.]*$"; "")), value: .[1]}] | from_entries')
    row_list=$(for row in "${rows[@]}"; do jq . "$row"; done | jq -s 'sort_by(.id)')
    jq --arg folder "${dir#plugins/}" --arg category "$category" \
      --argjson mcps ${#rows[@]} --argjson skills ${#skills[@]} \
      --argjson rows "$row_list" --argjson logos "$logos" \
      --arg base "$base" --arg key "$ext_key" '
      def need(f; what): f // error("\($folder): plugin.json has no \(what)");
      need(.name; "name") as $name
      | if $name != $folder then error("\($folder): plugin.json names \($name)") else . end
      | need(.version; "version") as $version
      | need(.extensions[$key]; "extension \($key)") as $ext
      | "\($base)/\($name)@\($version)" as $release
      | {
          name: $name,
          description: need(.description; "description"),
          author: (.author | if type == "object" then .name else . end | if . == "" then null else . end),
          homepage: .homepage,
          license: .license,
          keywords: (.keywords // []),
          category: $category,
          mark: (if $ext.mark then "\($release)/mark.\($ext.mark | split(".") | last)" else null end),
          format: ($ext.format // false),
          required: ($ext.required // false),
          withdrawn: ($ext.withdrawn // false),
          contents: {mcps: $mcps, skills: $skills},
          rows: [$rows[] | . + (if $logos[.id] then {mark: "\($release)/\($logos[.id])"} else {} end)],
          version: {
            version: $version,
            engines: need($ext.engines; "engines"),
            url: "\($release)/\($name)-\($version).tar.gz"
          }
        }
      | with_entries(select(.value != null))' "$dir/plugin.json"
  done
)

requestable=$(
  for file in requestable/*.json; do
    mark=
    for ext in svg png; do
      [[ -f ${file%.json}.$ext ]] && { mark=$ext; break; }
    done
    jq --arg mark "$mark" --arg release "$base/$index_tag" '
      {id, name, description, category}
      + (if $mark != "" then {mark: "\($release)/requestable-\(.id).\($mark)"} else {} end)' "$file"
  done
)

jq -n --slurpfile facts "$facts" --slurpfile previous "$previous" \
  --argjson plugins "$(jq -s . <<<"$plugins")" \
  --argjson requestable "$(jq -s . <<<"$requestable")" '
  ($facts[0]) as $facts
  | ($previous[0].plugins | map({key: .name, value: .versions}) | from_entries) as $older
  | {
      name: "pleasefix",
      owner: {name: "Pleasefix", url: "https://pleasefix.ai"},
      description: "The plugins and integrations of the Pleasefix app.",
      plugins: [
        $plugins | sort_by(.name)[]
        | .name as $name
        | ($older[$name] // []) as $kept
        | .version.version as $v
        | ($facts[$name] // ($kept | map(select(.version == $v)) | .[0] | if . then {sha256, size} else null end)
            // error("\($name)@\($v): no sha256 and size")) as $f
        | .versions = [.version + {sha256: $f.sha256, size: $f.size}] + ($kept | map(select(.version != $v)))
        | del(.version)
      ],
      requestable: ($requestable | sort_by(.id))
    }'
