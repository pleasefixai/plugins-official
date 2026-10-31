---
name: mcp-troubleshooting
description: Help developers debug Mailgun plugin startup, environment variables, MCP tag filtering, local server overrides, and missing tool exposure.
metadata:
  author: Mailgun
  version: 0.1.0
  category: Developer Tools
  tags: mailgun, mcp, setup, troubleshooting, developer
---

# MCP Troubleshooting

Use this skill when the user is installing a Mailgun plugin, debugging agent startup, checking why tools are missing, testing a local MCP server, or validating environment configuration.

Use Mailgun workflow skills when the MCP server is running and the user wants to perform account tasks.

This plugin does not carry the Mailgun server: the user adds it as a custom server in Settings, with the command `npx -y @mailgun/mcp-server@2.1.2` and `MAILGUN_API_KEY` (plus `MAILGUN_API_REGION` and `MAILGUN_MCP_TAGS` when needed) set on that server.

## Intake

Ask for the host app, plugin package, operating system, whether the issue happens at startup or tool call time, and which environment variables are configured. Do not ask the user to paste secrets.

## Workflow

1. Confirm `MAILGUN_API_KEY` is set on the custom server in Settings and that the server was reconnected after changes.
2. Check whether `MAILGUN_API_REGION` is needed for EU accounts.
3. Check whether `MAILGUN_MCP_TAGS` is hiding expected tools. Valid tags are `send`, `validate`, `optimize`, and `inspect`.
4. Verify the custom server in Settings launches `npx -y @mailgun/mcp-server@2.1.2` unless the user is intentionally testing a local server build.
5. For local testing, point the custom server's command at the built `mailgun-mcp.js` from a local `mailgun-mcp-server` checkout.
6. Use the MCP Inspector or the custom server's Test and tool list in Settings to confirm which Mailgun tools are exposed.
7. Classify failures as missing environment, wrong region, tag filtering, host reload, local build, network/auth, or account permission issues.

## Safety

Never ask users to paste API keys into chat or commit secrets to files. If a config example is needed, use placeholder values such as `key-...` and explain where the user should set the value locally.
