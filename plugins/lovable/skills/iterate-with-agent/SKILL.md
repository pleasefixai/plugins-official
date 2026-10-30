---
name: iterate-with-lovable-agent
description: Make changes to an existing Lovable project by messaging its agent, then verify the result in the diff. Use for any edit, fix, or refinement on a project that already exists.
---

# Iterate with the Lovable agent

## When to use

- A Lovable project already exists and someone wants to change it.
- You are fixing a bug, adjusting a screen, or adding a feature to a running app.

## How edits work

You do not patch files directly. You describe the change with `send_message`, the Lovable agent edits the cloud sandbox, and the preview rebuilds. Your job is to write a clear request and then check what actually changed.

## Steps

1. Confirm which project you are editing with `list_projects` or `get_project`. Keep the `preview_url` handy.
2. If the change is open-ended or risky, run `send_message` with `plan_mode=true` first and agree on the approach before code is written.
3. Send the change as one focused `send_message`. Reference the specific screen and element. Attach an image (a screenshot, a design, a wireframe) when the change is visual.
4. Read the reply with `get_message`, then call `get_diff` to see the edit. Use `read_file` to check a specific file when the diff is not enough.
5. If the result is off, send a follow-up that points at what is wrong rather than restating the whole request. The agent keeps the project context.
6. Report what changed using the diff, and share the `preview_url` so it can be looked at.

## Writing requests that land

- One change per message. A list of ten things in one message comes back half-done.
- Point to the place: "the email field on the signup form," not "the form."
- Describe the end state, not the steps. Say what it should do when it works.
- Pin down anything that has more than one reasonable reading before you send it.

## Standing instructions

If you keep repeating the same guidance (tone, naming, a component to always use), save it once with `set_project_knowledge`, or `set_workspace_knowledge` when it applies to every project.
