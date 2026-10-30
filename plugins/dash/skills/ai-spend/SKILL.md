---
name: ai-spend
description: 'Use this skill whenever you want AI cost and consumption metrics: spend, token usage, model consumption, and usage trends across your whole organization, or scoped to a single user, group, or department. Trigger on requests like "show me our AI spend", "how much is this team spending on AI", "break down token usage by department", "what is this user costing us", "who are our heaviest AI consumers", "trend our model spend this month", or any ask about AI cost, consumption, usage volume, or spend attribution. The skill handles two modes: a full organization-wide picture, or a scoped view when you name a user, group, or department, so watch for a named scope in the request and apply it. Use this skill whenever the question is about what AI is costing and where that cost comes from.'
---

# AI Spend

AI cost and consumption analytics - spend, token usage, model consumption, and trends - org-wide or scoped to a user, group, or department. Powered by the Dash MCP.

## When to use

- "Show me our AI spend", "who are our heaviest consumers", "trend model spend this month".
- Scoped cost: "what is this user/team/department costing us", "break down token usage by department".

## Two modes (detect the scope)

- Organization-wide: no named subject -> full picture.
- Scoped: the request names a user, group, or department -> pass that scope to the tools.

## Tools to use (Dash MCP)

1. `get_ai_spend` - the core analytics: total spend, avoidable waste, model-task fit, work-type and department breakdowns, trend, top spenders, action items. Filters: `from`, `to`, `platforms`, `department`, `userIds`, `models`, `repos`, `workTypes`, and `view` (`overview` | `savings` | `tickets` | `full`).
2. `get_ai_spend_brief` - narrative brief of spend patterns, waste hotspots, and recommendations (same `from`/`to`/`platforms`/`department` filters).
3. `get_dashboard_model_usage` - model consumption rollup (use when available).
4. `list_session_model_usage` - per-session model/token usage for bottom-up attribution.
5. `list_users` - resolve a named person/team to `userIds` for scoping.

## Recipe

Org-wide:

1. `get_ai_spend` with a time window (`from`/`to`) and `view: "full"` (or `overview` for a fast headline).
2. Optionally `get_ai_spend_brief` for the narrative + recommendations.
3. Report totals, trend, top spenders, avoidable waste, and action items.

Scoped:

1. Resolve the subject: for a user/team, use `list_users` to get `userIds`; for a department, use the `department` filter directly.
2. Call `get_ai_spend` with `userIds` and/or `department` (+ optional `platforms`, `models`).
3. Optionally add `get_ai_spend_brief` with the same scope, and `list_session_model_usage` for session-level detail.
4. Report scoped spend, model mix, trend, and waste/recommendations.

## How to interpret

- "Avoidable waste" and "model-task fit" from `get_ai_spend` drive the cost-optimization recommendations.
- Use `view: "overview"` for a quick number; `full` for breakdowns and action items.
- Dates are ISO-8601 UTC; default to a sensible window (e.g. last 30 days) and state the window used.

## Output

Lead with the headline spend for the requested scope and window, then trend, top spenders / model mix, avoidable waste, and prioritized recommendations. Always state the scope and time window applied.

## Guardrails

- Read-only.
- Confirm tenant via `list_tenants` when multiple are available.
- If a named user/team cannot be resolved to `userIds`, say so rather than reporting org-wide numbers as if scoped.
