---
title: Delivery strategy
description: Match channel, timing, and escalation to urgency and context
tags:
  - strategy
  - channels
  - timing
  - escalation
  - orchestration
category: knock-product-messaging-strategy
last_updated: 2026-07-23
---

# Delivery strategy

Sources:

- [The product leader's guide to effective messaging](https://knock.app/manuals/product-leaders-guide-to-effective-notifications/the-product-leaders-guide-to-effective-notifications)
- [In-app messaging best practices](https://knock.app/manuals/in-app-messaging/best-practices-for-in-app-messaging)

Supporting more channels does not mean sending more messages. Define a progression, not a broadcast to every channel.

## Match channel to urgency and context

| Channel | Best for | Weakness |
| --- | --- | --- |
| In-app feed / guides | Session context, guidance, lower urgency, collaboration history | Misses users who are away |
| Email | Detail, durable record, digests, re-engagement | Crowded inbox, slower |
| Push | Concise, time-sensitive return-to-app | High interrupt; easy to disable |
| SMS | Urgent, high-confidence, consented cases | Cost, compliance, low tolerance |
| Slack / Teams | Ops and collaborative work already in chat | Shared-channel noise |

### In-app format ↔ urgency

From the in-app manual:

- Critical transactional → banner or modal
- Referenceable transactional → feed / inbox
- Promotional / education → card or feed (low interrupt)
- Save high-attention formats for true urgency (for example final trial warning)

## Prefer progressive reach

Example approval progression:

1. Add to in-app feed
2. Email if still unseen after several hours
3. Slack the next business day if still pending
4. Stop all steps when approved

For each notification type define:

- Primary channel
- Fallback / escalation channel(s)
- Condition that advances the workflow
- Condition that cancels remaining steps

## Timing rules

**Send immediately** when the recipient expects the result or must act quickly: mentions, security events, failed payments, completed exports, operational failures.

**Delay** when the user may resolve it alone or related events may accumulate. Example: user leaves onboarding → wait ~30 minutes → re-check completion → then remind.

Before every reminder step, verify:

- The underlying condition remains unresolved
- The recipient still has access and responsibility
- The user has not already acted through another channel
- The workflow has not exceeded its frequency limit
- A higher-priority message has not superseded it

**Schedule** digests, reports, and non-urgent education. Respect time zones and working hours.

Follow-ups need a reason: new information, added urgency, channel switch, or ownership escalation. Repeating the same copy on a fixed cadence trains users to ignore you.

## Growth defaults

| Goal | Typical primary → escalation |
| --- | --- |
| Activation | In-app guide / checklist → email if incomplete |
| Collaboration | In-app + optional push for mentions → email digest for the rest |
| Failed payment | Email + in-app → remind → escalate urgency |
| Feature adoption | In-app guide at a natural break → optional email |
| Win-back | Email (user is away) → stop on return / activation event |

## Agent steps

For each workflow, update `knock-plan.md` (not chat):

1. Pick primary channel and interrupt level.
2. Define escalation path with explicit advance conditions.
3. Define delay / send window / timezone needs.
4. Write the stop condition that cancels remaining steps.
5. Note whether an in-app guide should pair with the workflow.
