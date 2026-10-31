---
name: project-context
description: >-
  Set up and query Forge project context — select projects, list linked repos,
  manage artifacts, and configure repositories. Use when the user asks about
  project setup, linked repositories, artifacts, UX references, journey state,
  project search, or wants to switch between projects.
---

# Project Context

All tools are MCP tools on your **connected Forge MCP server** (tools as `mcp__<server>__*`). Check the connection by calling `list_my_projects`: a project list means connected; a 401 means the token is missing, invalid, or expired.

This plugin does not carry the Forge server. If the Forge tools are not available, ask the user to add it as a custom server in Settings: the address `https://app.softwareforge.ai/api/mcp`, with the header `Authorization: Bearer <token>`, using a `forge_…` API token from [app.softwareforge.ai](https://app.softwareforge.ai) (**User Settings** → **API Tokens**).

## When to Use

Activate this skill when the user:
- Asks "which project am I on?" or wants to switch projects
- Needs to list or link repositories
- Asks about project artifacts (PRD, BRD, architecture, RTM, work orders breakdown)
- Wants to search across project documentation
- Wants to search for a project by name or ref code
- Needs UX/design references or basic journey metadata
- Must load requirements before implementing a work order

## Tools

| Tool | Purpose |
|------|---------|
| `set_project` | Set active project for this MCP session |
| `list_my_projects` | List accessible projects with pagination and filters |
| `search_projects` | Search projects by name, ref_code, intent, or type (up to 10 matches) |
| `list_linked_repos` | Repos linked to the current project |
| `link_repo` | Link a new repository |
| `get_project_state` | Basic journey step, ref code, and metadata |
| `configure_repo` | Session hooks gate; optionally restore project from `.forge/project-id` and upgrade hooks via `hook_version` |
| `get_artifact` | Retrieve the **latest** version of a journey artifact |
| `list_ux_references` | UX/design reference images with download URLs |
| `search_artifacts` | Full-text search across all project artifacts |

## MCP Resources (read-only)

When a project is set, these URIs are also available as MCP resources:

- `forge://docs/introduction` — Forge overview
- `forge://docs/tools` — available MCP tools list
- `forge://project/{projectId}/intent` — latest intent profile
- `forge://project/{projectId}/prd` — latest PRD
- `forge://project/{projectId}/prd_spec` — latest PRD-Spec
- `forge://project/{projectId}/architecture` — latest architecture doc
- `forge://project/{projectId}/ui_design` — latest UI design spec

No MCP resource URI for `brd` — use `get_artifact` with `type: "brd"`. Prefer **`get_artifact`** in agent workflows; resources are useful for direct reads.

## `get_artifact` Types

The `type` parameter accepts:

| `type` value | Document |
|--------------|----------|
| `intent` | Intent profile / problem statement |
| `prd` | Product requirements document |
| `prd_spec` | Product requirements specification |
| `brd` | Business requirements document |
| `architecture` | Architecture options and decisions |
| `ui_design` | UI design specification |
| `work_orders` | Full task breakdown (epics/stories) |
| `rtm` | Requirements traceability matrix |

Returns the **latest** version only. Use `search_artifacts` to find content by keyword across artifacts.

## Parameters

### `list_my_projects`
- `limit` — max projects (default 20)
- `offset` — pagination skip (default 0)
- `search` — filter by name, intent, ref_code, or type
- `project_type` — `new`, `refactor`, or `migrate`
- `team_id` — filter by team UUID
- `completion` — `not_started`, `in_progress`, or `complete`

Returns `current_project`, `projects`, `total`, `limit`, `offset`.

### `search_projects`
- `query` — search string (min 2 characters); returns up to 10 matches

### `configure_repo`
- `ide` — required; use `"cursor"` for this plugin
- `hooks_already_present` — `true` when the marketplace plugin (or workspace hooks) already provide Forge guards
- `workspace_project_id` — optional; first line of `.forge/project-id` if present (auto-restores project context)
- `hook_version` — optional **JSON number** from `.forge/hook-version`. Missing/`non-number` is treated as `0`. With `hooks_already_present: true`, version below the server (currently **3**) returns `needs_update` even when marketplace hooks are present — write/overwrite returned files (including `.forge/hook-version`) so the next call can return `already_configured`.

Responses: `already_configured` (ready; may include restored `project_id` / `linked_repos`), `needs_update` / `needs_setup` (show the user the returned files and ask before you write or overwrite them, `chmod +x` scripts, merge `gitignore_entries`).

### `link_repo`
Provide either:
- `git_url` — HTTPS clone URL (public repos), or
- `repo_full_name` (`owner/repo`) + `connector_id` (connector-based repos)

Optional: `default_branch` (defaults to `main`).

### `search_artifacts`
- `query` — search string (minimum 2 characters)

### `get_project_state`
Returns `current_step`, `ref_code`, `metadata`, and `project_name` for the active project.

## Pre-Implementation Context Load

Before coding on a work order:

1. `get_project_state` — basic journey step and ref code (use `get_journey_progress` from journey skill for full stage status)
2. `get_artifact` type `intent` — goals and scope
3. `get_artifact` type `prd` — product requirements
4. `get_artifact` type `architecture` — technical decisions
5. `get_artifact` type `ui_design` — when UI/design stage is present
6. `get_artifact` type `rtm` — traceability matrix (required for drift check before commit)
7. `search_artifacts` — when the user asks about a specific requirement by keyword
8. `list_ux_references` — design refs; entries include `download_url` paths

## RTM Drift Check (before commit)

1. Call `get_artifact` with `type: "rtm"`
2. Find RTM rows linked to the current work order (also returned by `get_work_order` as `traceability`)
3. For each row, compare implementation against linked PRD sections and architecture components
4. Record results in `update_work_order` field `rtm_drift_summary` — per Req ID: artifacts compared, drift yes/no, details, resolution. If clean: `No drift detected — all RTM rows aligned with artifacts.`

## Workflow

1. Call `configure_repo` once per MCP session before work order operations:
   - Read `.forge/project-id` → pass as `workspace_project_id` when present
   - Read `.forge/hook-version` → pass as `hook_version` when present
   - **Marketplace plugin installed**: `{ "ide": "cursor", "hooks_already_present": true, ...optional restore fields }`
   - **No plugin / fresh clone**: `{ "ide": "cursor", ...optional restore fields }` — show the user the returned hook files and ask before you write them to the workspace
   - If `status` is `needs_update`, overwrite **all** returned files once the user agrees
2. Call `set_project` only if project context was not restored (no `project_id` in configure response / no valid `.forge/project-id`).
3. After setting the project, call `list_linked_repos` to know which repos to work with.
4. Load artifacts with `get_artifact` before implementing scoped work.
5. When the user asks about design references, use `list_ux_references`.

## Important

- All subsequent tool calls use the active project unless `project_id` is overridden.
- Linked repos are the ONLY repos that should be used for commits and PRs.
- Clone all linked repos before making code changes.
- Prefer `.forge/project-id` restore over re-prompting for project selection when the file is valid.
