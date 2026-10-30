---
name: agent-session-investigation
description: 'Use this skill whenever you want to investigate a specific agent runtime session or security detection: pulling the full session timeline, reconstructing what the agent actually did, and surfacing intent drift, data exposure, unsafe actions, and blast radius to produce an incident write-up with a recommended response. Trigger on requests like "investigate this detection", "what happened in this session", "pull the runtime timeline for this alert", "did this agent leak data or run something unsafe", "write up this incident", or any depth-first dive on one session, alert, or agent behavior. Also use this when triaging an alert into a clear findings narrative. This skill is depth on a single session or detection, so use it whenever you need to understand and document exactly what one agent did.'
---

# Agent Session Investigation

Depth-first investigation of a single agent runtime session or detection: reconstruct the timeline, surface intent drift / data exposure / unsafe actions, assess blast radius, and produce an incident write-up with a recommended response. Powered by the Dash MCP.

## When to use

- "Investigate this detection / session / alert", "what did this agent do", "write up this incident".
- Triaging one alert into a clear findings narrative.
- NOT for broad org overviews (use `agentic-estate-discovery`) or cost questions (use `ai-spend`).

## Tools to use (Dash MCP)

1. `list_sessions` - find the session (filter by `actorEmail`, `actorId`, `platform`, `hasDetections`, time window; sort by `severity`/`detectionCount`).
2. `get_session` - session metadata and summary.
3. `list_session_events` - the full event-by-event timeline (what the agent actually did).
4. `list_session_aggregates` / `list_session_model_usage` - rollups and model/token usage for the session.
5. `get_session_mcp_usage` - which MCP tools the session invoked (unsafe-action / exfil surface).
6. `list_detections` and `get_finding` / `list_finding_evidence` - the detection(s) and their evidence.
7. `get_actor` - who ran it, for attribution and prior behavior.

## Recipe

1. Resolve the target: from an alert/finding start at `get_finding` + `list_finding_evidence`; from a session start at `get_session`. Use `list_sessions` / `list_detections` to locate it if you only have a user, platform, or time.
2. Pull `list_session_events` for the ordered timeline; note prompts, tool calls, file/data access, and shell/unsafe actions.
3. Use `get_session_mcp_usage` and `list_session_model_usage` to see external tool calls and model/token footprint.
4. Assess intent drift (did the agent's actions diverge from the stated task?), data exposure, and unsafe actions.
5. Determine blast radius via `get_actor` (identity, devices) and cross-session context.
6. Produce an incident write-up + recommended response.

## How to interpret

- Intent drift = later actions diverge from the initial user intent/prompt in the timeline.
- Data exposure / unsafe actions come from detection evidence plus tool/shell events in `list_session_events` and `get_session_mcp_usage`.
- Blast radius = affected identity, device(s), data, and any downstream systems the tools touched.

## Output

An incident write-up: summary, timeline of what happened, findings (intent drift / data exposure / unsafe actions with evidence references), blast radius, and a concrete recommended response (contain, notify, block, tune policy).

## Guardrails

- Read-only investigation; recommend response actions, do not execute them.
- Confirm tenant via `list_tenants` when multiple are available.
- Cite specific event/finding evidence rather than inferring; if the timeline is truncated, paginate `list_session_events` before concluding.
