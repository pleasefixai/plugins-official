# Contributing

Most changes to this catalog come from a sync that Pleasefix runs. You can also open a pull request by hand. Pleasefix reviews each pull request before it merges.

## The rules

- A change to a plugin raises its version, in the `version` field of the plugin's `plugin.json`. The new version must be higher than each released version of the plugin.
- Do not delete a plugin folder. To remove a plugin, publish a new version that is withdrawn (`"withdrawn": true` in its `ai.pleasefix.client` extension).
- Do not add symbolic links, or files larger than 5 MB.
- Do not add secrets, such as tokens or client secrets.

The `check` workflow runs on each pull request and checks these rules.

## Publishing

Do not create releases or tags by hand. When a pull request merges into `main`, the `publish` workflow does these steps:

1. It packs each plugin version that has no release yet, and releases it with the tag `<name>@<version>`.
2. It generates the index, `marketplace.json`, and releases it with the tag `index-<n>`, marked "latest".

To see what a publish would do, run the `publish` workflow by hand with `dry_run` set. It creates nothing.
