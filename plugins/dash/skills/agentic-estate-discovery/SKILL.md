---
name: agentic-estate-discovery
description: 'Use this skill for a high-level overview of the agentic environment and how AI is used across the organization. This is the front-door discovery view: how many agent platforms are running and their breakdown by type (coding agents, AI assistants, agentic browsers, autonomous agents, LLM apps, local LLMs), how many devices and users are active, how many MCP servers exist, what is managed versus shadow, the risk breakdown, and what needs attention now. Trigger on broad, first-look requests like "give me an overview of my agentic environment", "what''s going on across the org", "how many agents and users do we have", "what AI is running on our workstations", "how many platforms are managed versus shadow", "summarize my security posture", "what needs my attention", or "who is using AI here and how much." Default to this skill for wide, exploratory questions and as the starting point before drilling in; use a more specific skill only when the ask is clearly targeted.'
---

# Agentic Estate Discovery

The front-door overview of the organization's agentic AI footprint, powered by the Dash MCP. Use it to answer wide, exploratory questions and to orient before drilling into a specific area.

## When to use

- Broad first-look questions: "what's running across the org", "summarize my security posture", "what needs attention".
- Counting the estate: platforms, devices, users, MCP servers, managed vs shadow.
- As the entry point before handing off to `supply-chain-risk`, `shadow-ai-risk`, `agent-session-investigation`, or `ai-spend`.

## Tools to use (Dash MCP)

Start with the summary, then fan out only as needed:

1. `get_dashboard_summary` - top-level KPIs (open findings, active devices, sessions today).
2. `list_platforms` - AI platforms across the fleet. Pass `isManaged: true` / `false` to split managed vs shadow.
3. `list_devices` - workstations/devices with agents.
4. `list_users` (and `list_actors`) - active users / identities.
5. `list_saas_agents` - SaaS-side agents.
6. `list_mcp_servers` and `list_inventory_mcps` - MCP server count and the tenant AI BOM.
7. `list_inventory_skills` - installed skills across devices.
8. `list_integrations` - configured integrations (used to reason about managed coverage).

## Recipe

1. Call `get_dashboard_summary` first for the headline numbers.
2. Call `list_platforms` twice (`isManaged: true` and `isManaged: false`) to get the managed-vs-shadow split, or once and group client-side by the `isManaged` field.
3. Pull `list_devices`, `list_users`, `list_mcp_servers` for fleet size.
4. Summarize: platform count by type, device count, active users, MCP count, managed vs shadow, and the current risk/attention items from the summary.
5. Offer the natural next drill-down and name the specific skill that owns it.

## How to interpret

- Managed vs shadow: Dash marks a platform managed when your tenant governs it via an active integration; otherwise it is shadow/unmanaged. Use the `isManaged` flag from `list_platforms`.
- "Needs attention" = open findings (especially HIGH/CRITICAL) plus newly seen MCPs/skills surfaced in the summary.

## Output

Lead with a compact scorecard (platforms, devices, users, MCP servers, managed vs shadow, open findings by severity), then a short "what needs attention now" list, then suggested next steps mapped to the specific skills.

## Guardrails

- Read-only. Do not attempt to change configuration.
- If the account maps to multiple Dash tenants, call `list_tenants` and confirm which tenant to use before reporting numbers.
- Paginate (`page`, `limit`) rather than assuming a single page is the whole estate.
