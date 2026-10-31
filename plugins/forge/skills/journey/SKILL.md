---
name: journey
description: >-
  Manage Forge journey progress — stage approvals, generation, chat, and
  blockers. Use when the user asks about journey progress, stage approvals,
  unlocking stages, generating artifacts, journey chat, or staleness/blockers.
---

# Journey

All tools are MCP tools on your **connected Forge MCP server** (tools as `mcp__<server>__*`). If the Forge tools are not available, ask the user to add the Forge server as a custom server in Settings (see `forge:project-context`).

Backend may return `"not available in this deployment"` when `journeyState`, `journeyAgent`, or `sessions` services are not configured — report that clearly and suggest the Forge web UI.

## When to Use

Activate this skill when the user:
- Asks about journey progress, stage status, unlocks, or blockers
- Wants to approve or reject a journey stage
- Needs to trigger AI generation for a stage (PRD, architecture, etc.)
- Wants to chat within a journey step (chat-only — does not write artifacts)
- Asks about staleness, RAG status, or version info across stages

For basic project metadata only, `get_project_state` (project-context skill) is lighter. Prefer **`get_journey_progress`** for full journey state.

## Tools

| Tool | Purpose |
|------|---------|
| `get_journey_progress` | Full computed journey state: per-stage unlock/complete/approved, blockers, staleness, versions |
| `approve_stage` | Approve a stage (records audit trail; unlocks downstream generation) |
| `reject_stage` | Un-approve a stage; optional `reason` recorded as section comment |
| `trigger_stage_generation` | Start AI generation for a stage (same lock as web UI) |
| `send_journey_chat` | Send chat message in a journey step (`chat_only` — no artifact writes) |
| `list_journey_messages` | List journey chat history; optional filter by `step` |

## Stage Names

**Approval stages** (`approve_stage` / `reject_stage`): `intent`, `brd`, `prd`, `prd_spec`, `architecture`, `ui_design`, `work_orders`

**Generation stages** (`trigger_stage_generation`): `assessment`, `intent`, `brd`, `prd`, `prd_spec`, `architecture`, `ui_design`, `work_orders`, `testing_artifact`

Pipeline order places **`ui_design` between `architecture` and `work_orders`**.

**Journey chat steps** (`send_journey_chat` / `list_journey_messages`): any step in the project journey (`STAGE_ORDER` from backend).

## Parameters

### `approve_stage` / `reject_stage`
- `stage` — required stage name (see approval enum above)
- `reason` — optional (reject only); posted as section comment visible in web UI

### `trigger_stage_generation`
- `project_id` — required
- `stage` — required generation stage
- `generation_mode` — optional: `quick` or `in_depth`
- `force_regenerate` — optional boolean (default false)

### `send_journey_chat`
- `step` — required journey step context
- `message` — required user message text

### `list_journey_messages`
- `step` — optional filter
- `limit` — optional (default 50, max 200)

## Workflows

### Journey briefing
1. `configure_repo` + `set_project` if not done
2. `get_journey_progress` — summarize unlocked/complete/approved stages, blockers, stale stages
3. Suggest next action: approve, generate, pick a work order (`forge:work-orders`), or load project context (`forge:project-context`)

### Approve a stage (requires explicit user intent)
1. `get_journey_progress` — confirm stage has an artifact and prerequisites met
2. Warn if staleness flags exist for the stage
3. `approve_stage` with `stage`
4. Re-fetch `get_journey_progress` to show updated state

### Generate a stage
1. `get_journey_progress` — confirm stage is unlocked
2. `trigger_stage_generation` with `project_id` and `stage`
3. Poll or re-check progress; generation runs async like web UI

### Journey chat
1. `list_journey_messages` for context (optional `step` filter)
2. `send_journey_chat` with `step` and `message`
3. Summarize assistant response from returned `messages_appended`

## Important

- **RBAC:** `approve_stage`, `reject_stage`, and `trigger_stage_generation` require write/approval permissions — confirm user intent before calling.
- **Do not auto-approve** without explicit user request.
- Work orders in the plugin map to backend "user stories" — same entities, different label.
