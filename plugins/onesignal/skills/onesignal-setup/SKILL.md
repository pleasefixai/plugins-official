---
name: onesignal-setup
description: Use this skill when the user wants to install, configure, authenticate, test, or troubleshoot the OneSignal Cursor plugin or OneSignal MCP server. Triggers on "set up OneSignal in Cursor", "configure the OneSignal MCP", "how do I connect Cursor to OneSignal", or any first-run plugin setup question.
---

# OneSignal Cursor Plugin Setup

## Purpose

Help the user connect Cursor to OneSignal through the hosted OneSignal MCP server.

This plugin uses OAuth through the hosted OneSignal MCP server.

## Required Setup

The user needs:

- Cursor with plugin support.
- A OneSignal account.

## Authentication Guidance

Tell users to follow Cursor's OAuth prompt for the OneSignal MCP server. Never ask users to paste OAuth tokens, API keys, private keys, or credentials into chat, source files, rules, skills, commits, screenshots, or issue reports.

If Cursor was already open when the plugin was installed or updated, ask the user to reload Cursor with `Developer: Reload Window` or fully restart Cursor.

## First Test

Use a read-only or utility MCP tool first. Prefer:

- `onesignal_health`
- `onesignal_config`
- `onesignal_reference_overview`

Do not start with message sends, segment updates, template updates, Journey creation, exports, or subscription transfers.

## Troubleshooting

If tools do not appear:

1. Confirm the plugin is installed or symlinked into `~/.cursor/plugins/local/onesignal`.
2. Confirm `.cursor-plugin/plugin.json` is at the plugin root.
3. Confirm `mcp.json` has a top-level `mcpServers` object.
4. Reload Cursor.
5. Check Cursor's MCP logs from the Output panel.

If tools appear but calls fail:

1. Confirm the user completed the OneSignal OAuth flow in Cursor.
2. Confirm the account has access to OneSignal MCP.
3. Check whether the server URL is `https://api.onesignal.com/mcp/oauth`.
4. Retry with a read-only utility tool.

## Safety Defaults

For any write or send operation:

- Prefer test users and narrow test audiences.
- Summarize audience, content, timing, and expected effect.
- Require explicit user approval before running the tool.
- Add an extra confirmation for large audiences, production sends, deletes, or irreversible operations.
