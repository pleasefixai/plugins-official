# Pleasefix plugins

This repository holds the official plugin catalog of the [Pleasefix](https://pleasefix.ai) app. A plugin adds integrations (MCP servers) and skills to the app.

## What it holds

- `plugins/`: one folder per plugin, at its latest version. The version is in the plugin's `plugin.json`.
- `requestable/`: the providers that a user can request in the app, but that the catalog does not offer yet.

## Releases

Each plugin version is a release, with the tag `<name>@<version>`. The release holds the plugin's archive and its logo. Releases keep every version, also the versions that the repository no longer holds.

Each publish also makes an index release, with the tag `index-<n>`. The newest index release is marked "latest". The app reads the index at this address:

```
https://github.com/pleasefixai/plugins-official/releases/latest/download/marketplace.json
```

## Who writes the plugins

Some plugins are written by Pleasefix. Others come from their upstream authors. Pleasefix reviews and publishes all of them.

## Licence

Each upstream author keeps the licence of their plugin. A plugin folder that has its own licence file is under that licence. The other files in this repository are under the MIT licence, in [LICENSE](LICENSE).
