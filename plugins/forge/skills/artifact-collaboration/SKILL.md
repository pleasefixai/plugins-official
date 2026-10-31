---
name: artifact-collaboration
description: >-
  Display, edit, and collaborate on Forge journey artifacts — formatted downloads,
  markdown updates, impact analysis, and inline section comments. Use when the
  user wants to view formatted artifacts, update PRD/BRD/intent, comment on
  artifact sections, or analyze downstream impact of changes.
---

# Artifact Collaboration

All tools are MCP tools on your **connected Forge MCP server** (tools as `mcp__<server>__*`). If the Forge tools are not available, ask the user to add the Forge server as a custom server in Settings (see `forge:project-context`).

## When to Use

Activate this skill when the user:
- Wants a **formatted** artifact document (headers, metadata) — use `download_artifact`
- Needs raw/latest artifact content quickly — use `get_artifact` (project-context skill)
- Plans to **edit** intent, prd, prd_spec, or brd markdown
- Wants to **comment** on a specific section of an artifact
- Asks what happens if they change an upstream artifact (impact analysis)

## Tools

| Tool | Purpose |
|------|---------|
| `download_artifact` | Fully rendered markdown with headers and metadata |
| `analyze_artifact_update` | Preview downstream impact before editing |
| `update_artifact` | Write new markdown version (append-only; clears stage approval) |
| `add_section_comment` | Inline comment on an artifact section |
| `list_section_comments` | List comments for an artifact or section |
| `resolve_section_comment` | Mark a section comment resolved |

## `get_artifact` vs `download_artifact`

| Need | Tool |
|------|------|
| Agent briefing, quick read | `get_artifact` |
| Shareable formatted doc, export-style view | `download_artifact` |

Both support types: `intent`, `prd`, `prd_spec`, `brd`, `architecture`, `work_orders`, `rtm`.

`get_artifact` also supports **`ui_design`**. **`download_artifact` does not yet** — use `get_artifact` with `type: "ui_design"` until the download enum catches up.

## `update_artifact` Scope

Updatable via markdown: `intent`, `prd`, `prd_spec`, `brd` only.

`architecture`, `ui_design`, and `work_orders` require regeneration via `trigger_stage_generation` (journey skill).

## Section Comment `artifact_type` Values

| Value | Artifact |
|-------|----------|
| `INTENT_PROFILE` | Intent |
| `PRD_DRAFT` | PRD |
| `PRD_SPEC_DRAFT` | PRD-Spec |
| `BRD_DRAFT` | BRD |
| `ARCHITECTURE_OPTIONS` | Architecture |
| `UI_DESIGN_SPEC` | UI design |
| `TASK_BREAKDOWN` | Work orders breakdown |

## Parameters

### `analyze_artifact_update`
- `type` — `intent`, `prd`, `prd_spec`, or `brd`
- `proposed_changes` — natural language description of planned edits

### `update_artifact`
- `type` — `intent`, `prd`, `prd_spec`, or `brd`
- `updated_markdown` — full replacement markdown body

### `add_section_comment`
- `artifact_type` — enum above
- `section_id` — section title or index
- `content` — comment text
- `highlighted_text` — optional annotated excerpt

### `list_section_comments`
- `artifact_type` — required
- `section_id` — optional filter

### `resolve_section_comment`
- `comment_id` — UUID of comment to resolve

## Workflows

### Safe artifact edit
1. `get_artifact` or `download_artifact` — load current content
2. `analyze_artifact_update` with `proposed_changes` — show affected stages and approval resets
3. Confirm with user
4. `update_artifact` with full `updated_markdown`
5. Warn about downstream staleness; suggest `trigger_stage_generation` if needed

### Section comment thread
1. `list_section_comments` for `artifact_type` (and optional `section_id`)
2. `add_section_comment` to post new feedback
3. `resolve_section_comment` when addressed

## Important

- **RBAC:** `update_artifact` and section comment tools require write access — confirm user intent.
- `update_artifact` clears the stage's approval flag and may stale downstream artifacts.
- Always run `analyze_artifact_update` before `update_artifact` unless the user explicitly skips impact review.
