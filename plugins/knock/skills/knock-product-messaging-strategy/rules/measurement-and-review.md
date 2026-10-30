---
title: Measurement and review
description: Measure product outcomes and fatigue, and apply a launch review standard
tags:
  - strategy
  - measurement
  - analytics
  - fatigue
  - review
category: knock-product-messaging-strategy
last_updated: 2026-07-23
---

# Measurement and review

Sources:

- [The product leader's guide to effective messaging](https://knock.app/manuals/product-leaders-guide-to-effective-notifications/the-product-leaders-guide-to-effective-notifications)
- [In-app messaging best practices](https://knock.app/manuals/in-app-messaging/best-practices-for-in-app-messaging)

Delivery and opens are necessary. They are not the goal.

## Three measurement levels

1. **Delivery.** Did the message arrive?
2. **Engagement.** Did the recipient see or interact?
3. **Outcome.** Did the intended product action occur?

Outcome examples:

- Integration reconnected
- Approval completed
- Payment method updated
- Onboarding step finished
- User returned and activated
- Account issue resolved

Evaluate outcomes next to fatigue signals:

- Preference changes and opt-outs
- Push permission revocation
- Dismissal rates
- Spam complaints
- Declining engagement over time
- Longer time-to-action
- Repeated notifications for the same unresolved issue

Also track volume: notifications per user, account, channel, and product area — segmented by role. Admins in high-volume workspaces experience a different product than occasional end users.

### In-app metrics to watch

- Impressions
- Interaction rate
- Dismissal rate
- Completion rate (downstream action)

Connect interactions to downstream behavior (setup finished faster, upgrade converted). High dismissals usually mean bad timing or weak relevance.

## Launch review checklist

Do not build or ship a workflow until the team can document:

| Field | Required answer |
| --- | --- |
| Trigger and eligibility | … |
| Recipient and ownership | … |
| Intended action | … |
| Primary and escalation channels | … |
| Timing and delays | … |
| Frequency limits | … |
| Batch behavior | … |
| Suppression and stop conditions | … |
| Preference category | … |
| Success metric (outcome) | … |
| Fatigue risk | low / medium / high |

### Example: payment failure

- Trigger when payment fails
- Notify current billing owner
- Email immediately + in-app alert
- Remind after 48 hours if still unpaid
- Stop when payment succeeds
- Category: billing / service-related
- Success metric: successful payment recovery

If a team cannot explain why the recipient needs the message, when the sequence stops, or what outcome defines success, it is not ready.

## Audit scoring (existing programs)

When reviewing an existing system, score each workflow:

| Score | Meaning |
| --- | --- |
| Keep | Clear trigger, owner, stop, outcome |
| Fix | Valuable but missing stop, prefs, or batching |
| Merge | Overlaps another workflow; combine or digest |
| Kill | No clear owner action or high fatigue / low outcome |

Return a prioritized backlog: activation → revenue protection → engagement hygiene → nice-to-haves.

## Agent steps

1. Attach a success metric and fatigue risk to every proposal in `knock-plan.md`.
2. Refuse to mark build-ready for items that fail the checklist; note why in the file.
3. For audits, write Keep / Fix / Merge / Kill with rationale into the plan Audit section — not into chat.
4. Note analytics instrumentation (outcomes + fatigue) in the plan file.
5. Chat: status line only when asking the user to confirm next actions.
