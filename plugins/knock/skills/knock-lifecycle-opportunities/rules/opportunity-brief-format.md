---
title: Opportunity brief format
description: Write lifecycle opportunity briefs to knock-plan.md; keep chat minimal
tags:
  - lifecycle
  - output
  - plan
category: knock-lifecycle-opportunities
last_updated: 2026-07-29
---

# Opportunity brief format

All briefs go in **`knock-plan.md`** at the repo root (create or update the same shared plan). Chat stays status + confirmation only — never paste the full briefs.

The full skeleton lives in `knock-product-messaging-strategy/rules/knock-plan-file.md`. For this skill, fill these sections (create any that are missing, preserve sections other skills filled):

```markdown
# Knock plan

## Product context
## Signals found
## Recommendations
## Deferred / blocked
## Setup handoff
```

## Recommendation fields (lifecycle)

For each ranked opportunity under `## Recommendations`:

```markdown
### [N]. [Name]
- **Status.** proposed | confirmed | skipped | deferred | blocked
- **Lifecycle stage.** activation | engagement | expansion | revenue | win-back
- **Evidence in code.** paths / models / events
- **Trigger (precise).** …
- **Recipient.** …
- **Intended action.** …
- **Stop condition.** …
- **Suggested channels.** …
- **Knock shape (future).** workflow | guide | both
- **Why it matters.** 1–2 sentences on growth outcome
- **Dependencies.** data you do not yet emit, etc.
```

Number opportunities as an ordered list (`1.`, `2.`, … — never unnumbered bullets) so the user can answer with indexes. Keep the same numbering any time you list recommended opportunities in chat.

## Chat after drafting

Wrote `knock-plan.md` with N ranked opportunities.

**Which opportunities should we take next?**

## After user confirms

1. Update **Status** and **Setup handoff** in `knock-plan.md`.
2. Chat: one line with confirmed/skipped + path.
3. If they want Knock build next, hand off to `knock-setup` with the payload (no re-rank).
4. If they want deeper messaging design next, hand off to `knock-product-messaging-strategy` with the confirmed list (that skill continues in the same `knock-plan.md`).

Do not ask `knock-setup` to propose a new top-5 unless the user asks to re-rank.
