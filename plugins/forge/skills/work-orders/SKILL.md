---
name: work-orders
description: >-
  Manage Forge work orders — list, pick, update, transition, and complete
  development tasks. Use when the user asks about their current task, next work
  item, wants to update progress, create PRs, prepare commits, post comments,
  ask clarifications, or manage workflow stages.
---

# Work Orders

All tools are MCP tools on your **connected Forge MCP server** (tools as `mcp__<server>__*`). If the Forge tools are not available, ask the user to add the Forge server as a custom server in Settings (see `forge:project-context`).

## When to Use

Activate this skill when the user:
- Asks "what should I work on next?" or "what's my current task?"
- Wants to browse or filter work orders by status or priority
- Wants to update progress or report dev activity after a commit
- Is ready to commit and wants a formatted commit message
- Wants to create a PR linked to their work order
- Asks about workflow stages or work order statistics
- Wants to post or read comments on a work order
- Needs to ask a clarification question visible in the Forge UI

## Tools

| Tool | Purpose |
|------|---------|
| `list_work_orders` | List tasks; filter by `status`, `priority` |
| `get_work_order` | Enriched details — `implementation_brief`, dependencies, models, RTM; accepts `WO-NNN` or UUID |
| `get_next_work_order` | Pick highest-priority backlog task and auto-transition to next stage |
| `update_work_order` | Update fields and report post-commit dev activity |
| `transition_work_order` | Manually move to the next valid workflow stage |
| `complete_work_order` | Mark done (requires synced merged PR, or `user_confirmed_complete_without_merged_pr: true`) |
| `get_workflow_stages` | Canonical stage definitions, order, and allowed transitions |
| `get_work_order_stats` | Status distribution summary |
| `prepare_commit` | Generate `[WO-...]` commit message (requires `work_order_id`) |
| `create_pull_request` | Generate PR title/body, record activity, return CLI command — does not open the PR on the host |
| `ask_question` | Post a clarification question (visible in Forge UI for team answers) |
| `get_clarifications` | List clarification Q&A for the project |
| `comment_on_work_order` | Post a comment on a work order thread (optional AI reply) |
| `reply_to_work_order_comment` | Reply to an existing work order comment (no AI) |
| `get_work_order_comments` | List all comments and AI responses on a work order |

## Tool Distinctions

- **`get_next_work_order`** — picks from backlog and **auto-transitions** to the tenant's next stage. Use for "start my next task."
- **`transition_work_order`** — manual stage move. Call **`get_workflow_stages`** first for valid `status` keys and transition rules.
- **`update_work_order`** — post-commit activity report with git-derived fields and `rtm_drift_summary`. **Not** the same as `complete_work_order`.
- **`complete_work_order`** — terminal step after PR is merged and synced (or explicit user override).
- **`ask_question`** vs **`comment_on_work_order`** — clarifications for team Q&A (`ask_question` / `get_clarifications`) vs threaded WO discussion (`comment_on_work_order` / `get_work_order_comments`).
- **ID formats:** `get_work_order` (and most WO tools) accept `work_order_id` as **`WO-NNN` or UUID**. Comment tools use `wo_id` (human label, e.g. `WO-001`). `get_clarifications` filters by `task_id` (UUID) or `artifact_id`.

## Enriched `get_work_order` response

Treat these fields as first-class when implementing:

| Field | How to use |
|-------|------------|
| `implementation_brief` | **Primary implement guide** — reading order, execution protocol, present/missing fields |
| `custom_instructions` | User requirements **beyond** acceptance criteria — honor them |
| `dependency_status` / `dependency_warning` | Check blockers before coding; warn user if deps incomplete |
| `recommended_models` | Optional model hints from complexity |
| Hydrated story fields | `current_behavior`, `target_behavior`, `technical_details`, `implementation_hints`, `edge_cases`, etc. |
| `traceability` | RTM rows when available |
| `wo_id` | Human-readable label echoed when resolved from `WO-NNN` |

## Parameters

### `get_work_order`
- `work_order_id` — **`WO-003` or UUID**
- `project_id` — optional if project context is set

### `list_work_orders`
- `status` — workflow status key (call `get_workflow_stages` for valid values)
- `priority` — `critical`, `high`, `medium`, `low`

### `transition_work_order`
- `work_order_id` — `WO-NNN` or UUID
- `status` — must be the **next** valid stage from current status
- `notes` — optional transition note

### `comment_on_work_order`
- `wo_id` — human work order label (e.g. `WO-001`), not UUID
- `content` — comment text
- `trigger_ai` — `true` (default) triggers an AI reply; `false` posts only

### `reply_to_work_order_comment`
- `wo_id`, `comment_id`, `content`

### `get_work_order_comments`
- `wo_id` — human work order label

### `ask_question`
- `question` — required
- `work_order_id` or `artifact_id` — optional attachment

### `get_clarifications`
- `artifact_id` or `task_id` — optional filter

### `create_pull_request`
- `work_order_id` — required
- `branch_name`, `changes_summary`, `repo_url`, `repo_name` — recommended
- `pr_url`, `pr_number` — pass if PR already exists on the host

### `update_work_order` (post-commit dev activity)

After committing, call with `work_order_id` plus the dev-activity fields Forge expects:

- `commit_summary` — what changed (files, features, refactors)
- `test_summary` — test results (run, passed, failed, fixes)
- `rtm_drift_summary` — RTM drift check results (see project-context skill)
- `repo_url` — from `git remote get-url origin`
- `repo_name` — `owner/repo` parsed from URL
- `branch_name` — from `git branch --show-current`
- `commit_hash` — from `git rev-parse HEAD`
- `commit_message` — full message used
- `commit_author` — from `git config user.name`
- `files_changed`, `lines_added`, `lines_removed`, `changed_files` — from `git diff HEAD~1`
- `tests_total`, `tests_passed`, `tests_failed`, `tests_skipped`, `test_coverage`
- `pr_url`, `pr_number` — after PR is created

Optional field updates: `status`, `priority`, `title`, `description`, `assignee_id`, `story_points`, `wo_type`.

## Workflows

### Browse tasks
1. `get_workflow_stages` — learn valid status keys
2. `list_work_orders` with `status` / `priority` filters
3. `get_work_order` with `work_order_id` (`WO-NNN` or UUID) for full details

### Start next task
1. `configure_repo` (pass `workspace_project_id` / `hook_version` from `.forge/*` when present) → `set_project` only if needed
2. `get_next_work_order` (auto-transitions from backlog)
3. `get_work_order` — follow **`implementation_brief`**; check `dependency_status` and `custom_instructions`
4. `list_linked_repos` — clone repos before coding

### Comments and clarifications
- **Thread:** `get_work_order_comments` → `comment_on_work_order` or `reply_to_work_order_comment`
- **Team Q&A:** `ask_question` → later `get_clarifications`

### Full commit → PR → complete lifecycle
1. `get_work_order` — use `implementation_brief` + AC + `custom_instructions`
2. Load artifacts (see project-context skill): `get_artifact` types `intent`, `prd`, `prd_spec`, `architecture`, `ui_design`, `rtm` as needed
3. Implement and test (honor dependency warnings)
4. RTM drift check — compare implementation against RTM rows linked to this WO
5. `prepare_commit` with `work_order_id` → commit with returned `[WO-...]` message
6. `update_work_order` with full dev-activity fields and `rtm_drift_summary`
7. Push
8. `create_pull_request` → run returned CLI command (e.g. `gh pr create`)
9. `sync_dev_activity`
10. After PR merges and syncs: `complete_work_order`

## Prerequisites

0. Call `configure_repo` once per session before any work order tool:
   - **Marketplace plugin installed**: `{ "ide": "cursor", "hooks_already_present": true }` plus optional `workspace_project_id` / `hook_version` from `.forge/*`
   - **No plugin**: `{ "ide": "cursor" }` — show the user the returned hook files and ask before you write them to the workspace
1. Ensure a project is set (via restore or `set_project`) before querying work orders.
