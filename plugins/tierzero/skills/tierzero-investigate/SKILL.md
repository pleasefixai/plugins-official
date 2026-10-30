---
name: tierzero-investigate
description: The entry point for any production or infrastructure problem — deployment failures, errors, latency regressions, traffic anomalies, alerts, or anything misbehaving in live systems. Use when the user wants to understand what's happening in prod, check the status of an investigation, ask about a service's behavior, kick off a root-cause investigation, query TierZero (also referred to as t0, tz, or tzero) for production context, or debug any change where real production data would inform a better answer. Handles the full investigation lifecycle from discovery through analysis.
allowed-tools:
  - tierzero_ask
  - tierzero_fetch_context
triggers:
  - (tierzero|t0|tz|tzero).?ask
  - (tierzero|t0|tz|tzero).?investigate
  - investigate.?prod
---

# TierZero: Production Investigation Skill

Query production telemetry through TierZero's MCP server and run end-to-end investigations across logs, metrics, traces, CI/CD runs, and knowledge bases.

## When to use

TRIGGER when:

- The user is debugging a production issue, error, or alert
- The user references an incident, alert page, or recent deploy
- The user asks "what's happening with X?" / "is service Y healthy?" / "did the deploy break anything?"
- A code change touches a hot path and you don't yet know what calls it or how often
- A PR review hinges on whether something is actually broken in prod
- The user pastes a service name, error string, stack trace, or alert from a real environment
- Any task where understanding real traffic, error rates, latency, or usage would change the answer

DO NOT trigger for pure unit tests, doc-only changes, or local-dev questions where production data is irrelevant.

## How to call

This plugin registers TierZero as an MCP server (`tierzero`) in Cursor. Call the MCP tools directly — do **not** shell out to curl or wrap them in scripts.

Primary tools:

- `tierzero_ask` — kicks off an investigation and returns a grounded answer. Pass a single `query` argument in plain English. Be specific (service name, time range, symptom).
- `tierzero_fetch_context` — load a TierZero conversation, investigation, or artifact by URL or UUID. Use the `tierzero-fetch` skill when this applies.

Other tools the TierZero MCP server exposes are also available — check the server's tool list when you need more specific access (raw logs, traces, CI runs).

## Writing good queries

A good query for `tierzero_ask`:

- Names the service or component (e.g. `payment-service`, not "the API")
- Specifies a time window (e.g. "last 30 minutes", "since 14:00 UTC", "during the deploy at 13:42")
- States the symptom (errors, latency, drop in traffic, unexpected log line)
- Mentions the integration if relevant (Datadog, Sentry, GitHub Actions, etc.)

Examples:

- `What errors occurred in payment-service in the last hour?`
- `Show p95 latency for /api/checkout over the last 24h and flag anomalies.`
- `Did any GitHub Actions workflows for the api repo fail today?`
- `Has the rate of 5xx on auth-service changed since the deploy at 13:42 UTC?`

## After the call

- Summarize findings tied back to the user's current task
- Cite the integration the data came from (Datadog logs, Sentry issue, etc.) when relevant
- If the result returns a TierZero investigation or chat URL, surface it so the user can drill in
- If the result is empty or an integration isn't connected, say so and suggest what to connect

## Prerequisites

- The user must have a TierZero account with at least one integration connected (Datadog, New Relic, CloudWatch, Grafana Cloud, Sentry, GitHub, BuildKite, Temporal, Confluence, Notion, Slack, etc.).
- Authentication is automatic via OAuth. If MCP calls fail with auth errors, tell the user to open Cursor Settings → MCP → tierzero and click Authorize (or re-authorize), then retry.
