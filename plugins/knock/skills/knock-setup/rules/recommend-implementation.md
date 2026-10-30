---
title: Recommend an implementation approach
description: Choose one event or API path to trigger the built workflows
tags:
  - setup
  - implementation
  - events
category: knock-setup
last_updated: 2026-07-09
---

# Recommend an implementation approach

Examine how events flow through the codebase, then recommend exactly ONE of these approaches:

1. If there is already an eventing architecture (e.g. Segment, RudderStack, or a similar event pipeline), connect it to Knock as a Data Source and map relevant events to the workflows that were built. Follow `rules/implement-data-source.md` end-to-end (identify user, MCP agent setup, wiring, and testing).

2. If events are processed in one central place, set up a custom HTTP Knock data source, send events to it from that spot, and trigger the workflows from those events. Follow `rules/implement-data-source.md` (custom HTTP path).

3. Otherwise, trigger the workflows directly via the Knock API and identify the exact callsites in the code where each trigger belongs.

## Confirm before implementing

After stating the recommendation (one short line naming the approach and why), **stop and ask** whether they want to continue with that implementation. Do not create branches, edit files, or call Knock MCP to wire sources until they confirm.

The confirmation question must be the **very last thing** in your message: on its own line, and bolded. Nothing after it.

Example ending:

**Continue with this implementation?**

If they decline or want a different approach, adjust the recommendation and ask again the same way — do not implement until they confirm.

## Branch before file changes

Once they confirm, and **before any application file changes**:

1. Create and check out a new git branch named `knock-implementation` (from the current branch / HEAD).
2. Only then implement the confirmed approach (including `rules/implement-data-source.md` when applicable).

If the repo is not a git repository, say so in one line and continue without a branch.
