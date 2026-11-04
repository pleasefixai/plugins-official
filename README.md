# Pleasefix plugins

This repository holds the official plugin catalog of the [Pleasefix](https://pleasefix.ai) app. A plugin adds integrations (MCP servers) and skills to the app.

## What it holds

- `plugins/`: one folder per plugin, at its latest version. The version is in the plugin's `plugin.json`.
- `requestable/`: the providers that a user can request in the app, but that the catalog does not offer yet.

## Where the catalog is published

The catalog is published to `plugins.pleasefix.ai`. Each plugin version has a folder, `plugins/<name>/<version>/`, with the plugin's archive and its logo, and a tag, `<name>@<version>`. The folders keep every version, also the versions that the repository no longer holds.

Each publish also makes a folder, `indexes/index-<n>/`, and a tag, `index-<n>`. The app reads the current index at this address:

```
https://plugins.pleasefix.ai/marketplace.json
```

## Who writes the plugins

Some plugins are written by Pleasefix. Others come from their upstream authors. Pleasefix reviews and publishes all of them.

## Licence

Each imported plugin keeps the licence of its upstream author. The licence is in the plugin's `LICENSE` file and in the `license` field of its `plugin.json`.
