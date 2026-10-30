---
name: tierzero-fetch
description: Fetch a TierZero conversation, investigation, or artifact by URL or UUID and fold it into the current task. Use when the user pastes a TierZero link (chat, investigation, or artifact), shares a bare artifact UUID, or asks you to load saved context from a prior TierZero (also referred to as t0, tz, or tzero) session.
allowed-tools:
  - tierzero_fetch_context
triggers:
  - app\.tierzero\.ai/(chat|investigations)
  - (tierzero|t0|tz|tzero).?fetch
  - load.?(tierzero|t0|tz|tzero|investigation)
---

# TierZero: Fetch Context

Load saved TierZero context (a chat thread, investigation, or artifact) so the agent can act on it.

## When to use

- The user pastes a TierZero URL (`https://app.tierzero.ai/chat/c/...` or `https://app.tierzero.ai/investigations/...`).
- The user pastes a bare artifact UUID (e.g. `bf904904-afdc-4cf2-94d8-76a4a8bb4f75`).
- The user says "load that investigation" / "pull in the context from TierZero" / similar.

## How to call

Use the `tierzero_fetch_context` MCP tool exposed by the `tierzero` MCP server registered by this plugin.

Arguments:

- `url` (string, required): the chat URL, investigation URL, or artifact UUID.
- `include_sources` (bool, optional, default `false`): set to `true` only when the user asks for source-by-source breakdowns or you need to cite specific log lines / traces.

Supported inputs:

| Type | Example |
|------|---------|
| Chat URL | `https://app.tierzero.ai/chat/c/<GlobalID>` |
| Investigation URL | `https://app.tierzero.ai/investigations/<GlobalID>` |
| Artifact UUID | `bf904904-afdc-4cf2-94d8-76a4a8bb4f75` |

## After the call

Parse the response and surface what's relevant for the current task:

- **Conversations** — walk the messages (use `messageType` and `output`); summarize the conclusion, then note any open questions.
- **Investigations** — present the `outputJson` result; quote findings, list evidence sources.
- **Artifacts** — show the artifact `value` and `type`; if it's a log/metric snapshot, summarize what it contains.

Only include source metadata if the user explicitly asks for it (and call with `include_sources: true`). Otherwise it's noise.
