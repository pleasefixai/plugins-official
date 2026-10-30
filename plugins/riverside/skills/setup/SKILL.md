---
name: setup
description: Use when installing or connecting Riverside; when authentication, 401, auth-loop, tool-not-found, account, or plan issues prevent tools from working; or when a feature-disabled or precondition error might be mistaken for a connection failure. Do not use for normal content, editing, or publishing after the connection works.
---

# Setup and connection

This plugin wraps Riverside's remote MCP server at `https://mcp.riverside.com/mcp`.
The tools run against the user's own Riverside account over an authenticated
connection.

## Requirements

- **A Riverside account.** Sign up or sign in at https://riverside.com.
- **A qualifying paid plan.** The MCP is available only on qualifying Riverside
  paid plans; Free and Pro accounts are not admitted, and their tool calls will
  not authorize. Plan details are at https://riverside.com/pricing.
- This plugin installed and switched on.

## First-time connection

Ask the user to connect the Riverside server in the plugin's Edit dialog,
Connections tab. It ends in a browser sign-in at
Riverside, after which the tools work.

1. The sign-in page opens in the browser. It is found automatically by
   discovering the MCP endpoint, so there is no URL to enter by hand, and
   there is no client ID or secret to configure.
2. Sign in and approve access.
3. The browser hands the authorization back, the MCP server connects, and the
   tools become available.

The plugin supplies the four Riverside skills — the guidance the model follows;
the connection supplies the tools themselves. If the connection is missing or
signed out, the skills still load but the Riverside tools are missing or fail as
not-logged-in.

After the first connection, it is remembered — subsequent tool calls
run without re-prompting until the authorization expires or is revoked. A
connection currently lasts about a week, and there is no silent refresh, so
reconnecting through the browser periodically is expected rather than a fault.

## Troubleshooting

Reconnect only for authentication or connection failures. A feature-disabled or
precondition error is an operational result, not evidence that authentication
failed.

| Symptom | Likely cause | Fix |
|---|---|---|
| `401` / repeated auth loop / "unauthorized" | Authorization expired or was revoked | Reconnect Riverside in the plugin's Edit dialog, Connections tab, and re-authenticate. Complete the browser sign-in fully. |
| No Riverside tools listed | Riverside is not connected | Connect Riverside in the plugin's Edit dialog, Connections tab; the plugin alone provides no tools. |
| A tool is not listed — including reads working while every write is missing | Not exposed here | Report it as unsupported; do not reconnect, the connection is fine. Use a listed alternative only if it fits the request. |
| Tools appear but every call fails to authorize | Account on a plan that is not admitted | The MCP requires a qualifying paid plan; Free and Pro accounts cannot use it. Plan details are at https://riverside.com/pricing. |
| Sign-in never returns / hangs | Browser/redirect interrupted | Close the tab, retry to restart the flow, and complete the browser step in one go. |
| A specific tool reports feature disabled or a missing prerequisite | Tool or workflow unavailable or incomplete (e.g. an edit with no transcript) | Surface the message; do not reconnect or retry blindly. Load the relevant operational skill only if the user asks to recover or continue. |

## Getting help

- Product, plans, and account: https://riverside.com
- Support: https://support.riverside.com/hc/en-us
