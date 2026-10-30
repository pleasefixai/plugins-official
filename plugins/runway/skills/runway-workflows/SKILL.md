---
name: runway-workflows
description: Build, inspect, validate, and run Runway editor workflow graphs via MCP. Use when the user asks to create, edit, list, or run Runway workflows, design multi-step generation pipelines, or work with workflow graphs, nodes, and dynamic_workflow tasks.
---

# Runway MCP workflows

> Not for: one-shot `generate_image` / `generate_video` — use the `runway-media` skill. Not for: published Workflow Apps.

Domain knowledge (port types, node catalog, model modes, worked examples) lives in the server's MCP resources, which are always current. Do not copy tables into this skill.

## Before you start

1. Runway MCP connected, workspace selected.
2. Read the resources: `runway://docs/workflows/overview`, then `authoring`, `models`, `catalog`, and `examples`.
3. `list_workflows` → `get_workflow` with `include_graph: true` on a similar template. **Copy** that graph shape; do not invent `{ type, config, inputs }` or human-readable ids like `input_photo`.
4. Sketch the pipeline as a mermaid `flowchart LR` and show it to the user with inputs, node count, and estimated credits before writing JSON.

## Author and run

- New workflow → `create_workflow`. Edit an existing one → `save_workflow_version` with the API graph JSON copied from `get_workflow` (graphs must use UUID ids).
- `validate_workflow_graph` before saving when unsure; the save still succeeds with `errorCount > 0`, so surface errors to the user.
- Run with `run_workflow`. It returns a task id; say generation is in progress. The inline viewer polls where available — do not `sleep` + `get_task` in a loop unless the authoring guide says to.
- Never tell the user to build the graph themselves in the editor when the tools can do it.
