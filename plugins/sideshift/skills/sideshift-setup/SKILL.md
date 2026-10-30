---
name: sideshift-setup
description: Use when the user needs to install, authorize, troubleshoot, or verify the SideShift MCP connection in ChatGPT, Codex, Claude, Cursor, or another MCP-compatible host.
---

# SideShift setup

SideShift uses one hosted Streamable HTTP MCP server and browser-based OAuth. The canonical
endpoint is `https://app.sideshift.app/api/mcp`.

## Connect

1. Confirm the SideShift plugin or MCP connection is enabled in the current host.
2. Start the host's connection or authorization flow; do not ask the user to create an API key.
3. Complete SideShift sign-in in the browser, select the intended company, review the requested
   scopes, and approve only if the company and permissions are correct.
4. Call `whoami` after authorization and report the connected company and granted scopes.
5. Do not perform another SideShift operation until the user confirms that the reported company is
   the intended one.

## Troubleshoot

- If the host reports an authorization error, restart the host's OAuth connection flow. Never ask
  for an access token, refresh token, cookie, or client secret in chat.
- If a required scope is missing, explain the missing scope and ask the user to re-authorize.
- If `whoami` is unavailable, confirm that the SideShift MCP is enabled and reload the host's
  plugins/connections before trying again.
- Keep credentials, private creator data, company data, and raw OAuth responses out of logs,
  screenshots, commits, and public issue reports.
