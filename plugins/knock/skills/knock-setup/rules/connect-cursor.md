---
title: Connect Knock in Cursor
description: Route Cursor sessions — editor uses the Knock MCP server, Cursor CLI uses the Knock CLI
tags:
  - setup
  - mcp
  - cli
  - cursor
category: knock-setup
last_updated: 2026-07-29
---

# Connect Knock in Cursor

Use this rule for anything Cursor. First determine which surface you are on — do not skip this check:

- **Cursor CLI** — this session was launched by running `cursor-agent` (or `agent`) in a terminal; there is no editor UI. → Stop here and follow `rules/connect-knock-cli.md` (Knock CLI, not MCP). Do not use the MCP path below.
- **Cursor editor** — you are the agent chat inside the Cursor IDE. → Continue with the MCP path below.
- If you cannot tell, ask the user in one line: are they in the Cursor editor or the Cursor CLI (`cursor-agent`)? (Do not rely on `CURSOR_AGENT`/`CURSOR_CLI` env vars — the editor's terminal sets them too.)

## MCP path (Cursor editor)

Prerequisite: step 1 (Confirm Knock account) must already be asked and answered in this conversation. If it hasn't been, stop and ask before continuing — do not add the MCP server or start OAuth.

1. Add MCP: add a `knock` server with URL https://mcp.knock.app/mcp (HTTP transport) to `~/.cursor/mcp.json`. Merge the entry into the existing `mcpServers` object — do not replace the file or remove other servers. Cursor picks up the change without a restart.
2. Run: `npx skills add knocklabs/skills`
3. **Auth checkpoint (required — do not skip).** Call a Knock MCP tool once to trigger OAuth and prove it works — prefer `list_environments`, or `execute_mapi_read` with `GET /v1/whoami`. Wait until that call succeeds.
   - If no browser opens within about 10 seconds, do not retry in a loop — direct the user to Cursor Settings → Tools + MCP → knock → "Needs authentication", or have them open the authorization URL from the Output panel (MCP: knock) manually, then retry the same Knock tool call.
   - If the tool is unavailable or still needs authentication, stop here. Do **not** discover, propose, or build workflows. First check that the `knock` entry still exists in `~/.cursor/mcp.json` before re-adding the server.
4. Only after step 3 succeeds: say setup is done (one short line) and continue to `discover-workflows`. Do not summarize or list installed tools/skills.

For users without an account, OAuth sign-in doubles as signup: they'll create their account, complete onboarding, and be redirected back to the IDE automatically. If the redirect doesn't complete (e.g. they land on the dashboard instead), have them finish signup there, then retry the Knock tool call to re-trigger OAuth.

**Hard gate:** steps after Connect Knock tooling (discover, build, implement, wrap-up) are blocked until a Knock MCP tool call has succeeded in this conversation.
