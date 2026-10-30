---
title: Apply in Knock
description: Map messaging strategy decisions onto Knock workflows, guides, audiences, preferences, and triggers
tags:
  - strategy
  - knock
  - workflows
  - guides
  - preferences
  - audiences
category: knock-product-messaging-strategy
last_updated: 2026-07-24
---

# Apply in Knock

After the strategy checklist passes, map each message onto Knock primitives. Prefer Knock MCP tools or the CLI when available. Use docs for details: https://docs.knock.app

## Decision table

| Strategy need | Knock primitive |
| --- | --- |
| Event-driven cross-channel journey | Workflow |
| In-session guidance, checklist, paywall, announcement | Guide (+ message type) |
| Both "notify while away" and "guide while in product" | Workflow + guide, shared eligibility where possible |
| Who is in a lifecycle stage | Audience (or user/object properties) |
| User control of categories/channels | Preferences (+ preference center) |
| Wait / drip / business hours | [Delay](https://docs.knock.app/designing-workflows/delay-function) + [send windows](https://docs.knock.app/designing-workflows/send-windows) |
| Collapse bursts of activity | [Batch](https://docs.knock.app/designing-workflows/batch-function) |
| Cap repeats | [Throttle](https://docs.knock.app/designing-workflows/throttle-function) |
| Branch on plan, role, or state | [Branch](https://docs.knock.app/designing-workflows/branch-function) + [conditions](https://docs.knock.app/designing-workflows/step-conditions) |
| Compare copy/timing | [Experiment](https://docs.knock.app/designing-workflows/experiment-function) |
| One-off launch to a segment | [Broadcast](https://docs.knock.app/concepts/broadcasts) (keep separate from transactional reputation) |

## Workflow shape checklist

For each approved workflow, specify:

1. **Key and name** (sentence case name, stable key)
2. **Trigger data schema** (required payload fields from the data foundation rule)
3. **Steps**
   - Delays with re-check conditions
   - Channel steps in escalation order
   - Batch / throttle as designed
   - Branch for role or plan when needed
4. **Cancellation** — which event or condition terminates the run
5. **Preference category** binding
6. **Tenant / object** usage for B2B scope

## Guides shape checklist

When the moment is in-product:

1. Choose format from urgency rules (banner, modal, card, custom message type)
2. Target by audience, properties, or page context
3. Wire engagement (seen / interacted / archived) so dismissals are respected
4. Pair with a workflow only when out-of-app reach is required
5. For React implementation details, use `knock-in-app-ui`

## Trigger wiring

Recommend one primary trigger path per workflow:

- Application SDK / API on the domain event ([triggering workflows](https://docs.knock.app/send-notifications/triggering-workflows))
- CDP / Knock [data source](https://docs.knock.app/integrations/sources/overview) mapping
- [Audience entry](https://docs.knock.app/send-notifications/triggering-workflows/audiences) for lifecycle stages (workflows trigger when a user **joins** an audience, not on exit)
- [Schedule](https://docs.knock.app/concepts/schedules) for pure digests ([recurring digests tutorial](https://docs.knock.app/tutorials/building-recurring-digests))

Identify users consistently. Import or identify users before production sends. Use [cancellation](https://docs.knock.app/send-notifications/canceling-workflows) (and step conditions after delays) for stop conditions.

## Build order for startups

1. Preference taxonomy + critical transactional workflows (auth, billing, security)
2. Activation journey (guide + email with exit on activation event)
3. Core collaboration / product activity (with batching)
4. Revenue protection (failed payment, trial)
5. Digests and re-engagement with precise eligibility
6. Announcements / education last

## Agent steps

1. Convert each approved plan item into a Knock resource sketch (workflow and/or guide) **inside `knock-plan.md`** — do not paste sketches into chat.
2. Chat: one line that the plan file was updated with Knock shapes.
3. Create via MCP or CLI only if the user explicitly asks to build now; confirm development environment first. Do not invent dashboard-only steps when tools can do the work.
4. For copy inside templates, apply `knock-notification-best-practices`.
5. After building, put happy-path and cancel-path test notes in the plan file; chat stays one line.
6. If the user wants end-to-end install + trigger wiring next, hand off to `knock-setup` with an explicit build list and pointer to `knock-plan.md`. Do not invite rediscovery or re-ranking.

### Setup handoff payload

```markdown
### Setup handoff
- **plan.** knock-plan.md
- **confirmed.** [names]
- **skipped.** [names]
- **deferred / blocked.** [names + reason]
```

`knock-setup` treats `confirmed` as the build list, reads detail from `knock-plan.md`, and skips `discover-workflows` rediscovery.

## Cross-skill routing

| Need | Skill |
| --- | --- |
| MCP connect + first workflows in app | `knock-setup` (pass confirmed/skipped/deferred) |
| Copy / channel formatting | `knock-notification-best-practices` |
| React guides providers and rendering | `knock-in-app-ui` |
| Pull/push resources as code | `knock-cli` |
