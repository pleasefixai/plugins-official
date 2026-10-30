---
title: Connect the Knock CLI
description: Install and authenticate the Knock CLI for CLI-based coding agents
tags:
  - setup
  - cli
category: knock-setup
last_updated: 2026-07-30
---

# Connect the Knock CLI

**Never set up MCP on this path — not now, and not in any later step of this skill.** Do not run `claude mcp add` or `codex mcp add`, do not edit `mcp.json` or any MCP config, and do not tell the user to add a connector. Later rules mention Knock MCP tools because they are shared with the MCP path; on this path every one of those mentions means the Knock CLI equivalent, never "install MCP first."

Prerequisite: step 1 (Confirm Knock account) must already be asked and answered in this conversation. If it hasn't been, stop and ask before continuing — do not install the CLI or start auth.

1. Install the Knock CLI ([docs](https://docs.knock.app/cli/overview)): run `npm install -g @knocklabs/cli` (on macOS, `brew install knocklabs/tap/knock` also works). Skip the install if `knock --version` already succeeds.
2. Run: `npx skills add knocklabs/skills`
3. **Auth checkpoint (required — do not skip).** Run `knock login` — it opens a browser where the user signs in to their Knock account and authorizes the CLI. Then run `knock whoami` and wait for a successful response (account name and user id). If `knock whoami` fails, re-run `knock login` once, then stop and report the CLI error — do not continue.
4. Only after step 3 succeeds: say setup is done (one short line) and continue to `discover-workflows`. Do not summarize or list installed tools/skills.

For users without an account, the `knock login` browser flow doubles as signup: they'll create their account, complete onboarding, and return here. If the redirect doesn't complete (e.g. they land on the dashboard instead), have them finish signup there, then re-run `knock login`.

On this path, use Knock CLI commands wherever later rules reference Knock MCP tools — follow the `knock-cli` skill for pull, push, workflow, and template commands (e.g. `knock workflow run` for test sends). If a later step names an MCP-only tool with no CLI equivalent, say so in one line and use the closest CLI command instead.

**Hard gate:** steps after Connect Knock tooling (discover, build, implement, wrap-up) are blocked until `knock whoami` has succeeded in this conversation.
