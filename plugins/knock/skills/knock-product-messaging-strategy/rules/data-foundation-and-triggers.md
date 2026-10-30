---
title: Data foundation and triggers
description: Define meaningful product moments, event payloads, and eligibility data for messaging workflows
tags:
  - strategy
  - events
  - triggers
  - data
  - lifecycle
category: knock-product-messaging-strategy
last_updated: 2026-07-23
---

# Data foundation and triggers

Source: [The product leader's guide to effective messaging](https://knock.app/manuals/product-leaders-guide-to-effective-notifications/the-product-leaders-guide-to-effective-notifications)

Messaging quality starts with data. A workflow can only decide eligibility, recipients, channel, copy, and cancellation if the event model is clear.

## Prefer meaningful state changes

Use events that represent an action or state change a human can act on:

- ✅ `report_export_completed`, `invoice_payment_failed`, `integration_disconnected`, `invite_accepted`
- ❌ `button_clicked`, `page_viewed` alone (too ambiguous without product state)

For each trigger, document:

1. What happened
2. Who is affected
3. What action is expected
4. How urgent that action is
5. Which event or state should cancel future messages

## Four moment types

Classify every candidate message into one type:

### 1. User-requested outcomes

The user started something and is waiting on a result (export finished, file processed, job completed). These can usually send immediately.

### 2. Collaborative activity

Another person created work for the recipient (mention, assignment, comment, approval, share). Decide immediate vs batched based on urgency.

### 3. Product or account state changes

Something material changed (integration disconnected, usage threshold, payment failed, deployment error). Often needs role-aware recipients and clear suppression.

### 4. Time-based conditions

A deadline is approaching or an unresolved state persisted (trial ending, overdue approval, incomplete onboarding step).

Time-based workflows must re-check current state between messages. Do not run fixed sequences that ignore completion.

## Avoid naive inactivity campaigns

"User has not logged in for 7 days" is easy to define and usually a weak trigger. The user may have finished their work, lost access, gone on vacation, or be blocked on a teammate.

Prefer precise combinations of behavior + product state + responsibility, for example:

- Workspace owner
- Invited teammate still inactive
- Implementation step incomplete
- Teammate participation required to proceed

## Event payload checklist

A useful payload typically includes:

| Field | Purpose |
| --- | --- |
| Action / state change | What happened |
| Actor | Who caused it |
| Affected user or account | Who it impacts |
| Product object | Document, project, invoice, integration |
| Current state | Enough to decide if the issue still exists |
| Timestamp | Timing and SLAs |
| Response context | Deep link, amount due, error code, deadline |

Workflows should combine the event with live customer/account data when needed (billing owner, unpaid status, role). Prefer verifying current state over trusting a stale snapshot for reminders.

## Growth-oriented trigger backlog

When scanning a product for messaging opportunities, look for:

1. **Activation blockers.** Signup without first key action, invite sent but not accepted, empty-state abandoned
2. **Core loop reinforcement.** Collaboration that needs a response, digestible activity summaries
3. **Revenue protection.** Failed payment, trial ending with incomplete setup, plan limit hit
4. **Reliability moments.** Integration disconnect, sync failure, security event
5. **Expansion cues.** Team invite opportunity, feature adjacent to recent success (use low-interrupt channels)

## Agent steps

1. Capture candidate moments from the product or codebase in `knock-plan.md` (not chat).
2. Tag each with a moment type.
3. Reject or rewrite triggers that lack a clear action or cancel condition.
4. Specify the minimum event + user/account properties Knock needs in the plan file.
5. Carry only the strongest moments into recipient and delivery design.
6. Chat stays a one-line status (or silent until the plan is ready for confirmation).
