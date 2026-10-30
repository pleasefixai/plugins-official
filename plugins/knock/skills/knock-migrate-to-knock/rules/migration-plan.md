---
title: Migration plan
description: Produce a phased Knock migration plan without mutating Knock resources
tags:
  - migrate
  - plan
  - phases
category: knock-migrate-to-knock
last_updated: 2026-07-24
---

# Migration plan

After inventory and mapping, write a phased plan into `knock-plan.md` under a `## Migration plan` section — do not paste it into chat. Do not execute Knock resource creation unless the user explicitly asks.

## Plan structure

### 1. Summary

- Source platform(s) detected
- Approximate number of message types
- Suggested first slice (usually auth + billing transactional)
- Link the primary tutorial (Braze / Courier / generic)

### 2. Technical resource order

When migrating Knock dashboard / API resources, follow the dependency order from the [Braze](https://docs.knock.app/tutorials/migrate-from-braze) and [Courier](https://docs.knock.app/tutorials/migrate-from-courier) tutorials:

1. Channels
2. Workflows (+ templates)
3. Translations
4. Tenants (if needed)
5. Users
6. Subscriptions
7. Preferences

Do not migrate preferences before users exist in the target environment.

### 3. Product cutover phases

Within that technical order, ship product value in slices:

| Phase | Work | Done when |
| --- | --- | --- |
| 0. Foundations | Knock account, environments, channel providers | Channels send a test in development |
| 1. Critical transactional | Password reset, verify email, invites, receipts | Parity with old sends; dual-run or feature flag |
| 2. Product / collaboration | Mentions, assignments, digests | Batching defined; workflow categories assigned |
| 3. Lifecycle | Onboarding, trial, win-back | Stop / exit criteria documented |
| 4. Recipients model | Identify users, tenants, subscriptions | Scoped correctly for B2B / lists |
| 5. Preferences | Preference center + category mapping; honor old opt-outs | Opt-outs respected in Knock |
| 6. In-app | Feed and/or guides | UI wired in app |
| 7. Cutover | Remove old provider calls | No dual sends |
| 8. Cleanup | Delete unused campaigns/providers | Docs updated |

### 4. Application code changes (local only)

List concrete files/modules to change for triggers and identify calls. Propose diffs only if the user asks. Do not push workflows.

### 5. Risks and open questions

- Dashboard-only templates with no export path
- Missing stable user ids
- Marketing vs transactional deliverability (separate email channels)
- Compliance (SMS consent, unsubscribe)

### 6. What not to do yet

Explicitly state that Knock MCP/CLI resource writes and the [email MCP migration tutorial](https://docs.knock.app/tutorials/migrate-email-with-mcp-server) wait until the user opts in.

## Closing chat message

After writing the plan file, chat is one status line plus a single bold confirmation question as the last line, for example:

Wrote `knock-plan.md`: 14 message types inventoried, 8-phase migration plan drafted.

**Which migration phase should we plan in more detail next?**
