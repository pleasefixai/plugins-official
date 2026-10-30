---
name: runway-media
description: Generate and edit images, video, music, speech, and sound effects with Runway MCP. Use when the user asks to create, animate, edit, restyle, expand, upscale, localize, or clean up visual or audio media, or asks about their Runway assets, credits, or plan.
---

# Runway media generation

> Not for: general questions about AI video that need no generation or account data. Not for: writing tasks with no media output.

The Runway MCP server (`https://mcp.runwayml.com/mcp`) exposes the tools; their descriptions carry current models, ratios, durations, and credit notes. Read them before choosing parameters.

## Before you start

1. Runway MCP is connected and the user has signed in (a workspace is selected). If a tool returns an auth error, ask the user to reconnect the Runway plugin.
2. Confirm what the user wants as the *deliverable*: image, single video, multi-shot story, edit of existing footage, ratio change, audio.
3. Generations consume Runway credits. For anything beyond a single quick generation, state the rough cost and confirm.

## Pick the tool

| Intent | Tool |
| --- | --- |
| New image | `generate_image` |
| Text-to-video, image-to-video | `generate_video` (`startFrame` for i2v) |
| Restyle / transform a whole clip | `generate_video` with `referenceVideo` |
| Change one thing in a clip, keep the rest | `edit_video` |
| New aspect ratio for a clip (uncrop) | `expand_video` |
| Multi-scene story from one prompt | `generate_multishot_video` |
| Product URL or product image to ad | `generate_product_marketing_video` |
| Same ad in another language | `localize_ad` |
| Music / sound effect / voice | `generate_music` / `generate_sound_effect` / `generate_speech` |
| Background removal, upscale, HDR | `remove_*_background`, `upscale_*`, `convert_video_to_hdr` |
| Saved workflows | `list_workflows`, `get_workflow`, `run_workflow` |
| Assets, account, credits | `list_recent`, `whoami`, `list_workspaces`, `show_plans_and_credits` |

## Inputs

- Public HTTPS or Runway-hosted URLs pass straight through.
- Local files: `init_upload` → PUT bytes to the returned URL(s) (the tool returns ready-to-run curl commands) → `complete_upload` → use the returned asset URL.
- Output of an earlier Runway call: pass its `taskId` where the tool accepts one instead of copying a signed URL.
- Never pass local filesystem paths as URLs.

## Results

Generation tools return a task ID immediately. Say generation is in progress. Where an inline viewer renders, it polls by itself. Otherwise call `get_task` at a reasonable interval and report the asset URL when `kind` is `image`, `video`, or `audio`. On `task_failed`, relay the categorized `title` and `hint` rather than retrying blindly.

## Don't

- Invent model IDs, ratios, durations, or defaults — omit a parameter to get the tool's default.
- Escalate a simple request into a workflow graph.
- Mention provider-specific storage services; say "Runway-hosted asset".
