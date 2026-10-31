---
name: forge-score
description: >-
  Query ForgeScore codebase health metrics for a project — composite score,
  dimension breakdown, findings, and history. Use when the user asks about
  code health, ForgeScore, maturity level, or score trends over time.
---

# ForgeScore

All tools are MCP tools on your **connected Forge MCP server** (tools as `mcp__<server>__*`). If the Forge tools are not available, ask the user to add the Forge server as a custom server in Settings (see `forge:project-context`).

Backend may return `"ForgeScore not available in this deployment"` when scoring is not configured, or `"No ForgeScore available"` when no score has been run yet — suggest running a score from the Forge web UI first.

## When to Use

Activate this skill when the user:
- Asks about codebase health, quality score, or maturity
- Wants ForgeScore dimensions, findings, or surgical strikes
- Needs score history or trend over recent runs

## Tools

| Tool | Purpose |
|------|---------|
| `get_forge_score` | Latest scorecard: composite score, maturity, 8 dimensions, findings, strengths, surgical strikes |
| `list_forge_score_history` | Recent scores showing how health changed over time |

## Parameters

### `get_forge_score`
- `project_id` — optional if project context is set

Returns: `composite_score`, `composite_maturity`, `dimensions`, `top_findings`, `top_strengths`, `surgical_strikes`, `scored_at`

### `list_forge_score_history`
- `project_id` — optional if project context is set
- `limit` — optional (default 5, max 20)

## Workflow

1. `configure_repo` + `set_project` if not done
2. `get_forge_score` — present summary stats and top findings
3. If user asks about trends: `list_forge_score_history` with desired `limit`
4. Link findings to work orders (`forge:work-orders` skill) if user wants remediation tasks

## Important

- ForgeScore must be generated at least once in the Forge web UI before MCP tools return data.
- Scores are read-only via MCP — no tool to trigger a new score run.
