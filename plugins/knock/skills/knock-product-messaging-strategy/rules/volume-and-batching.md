---
title: Volume and batching
description: Control frequency across workflows and batch related activity into useful summaries
tags:
  - strategy
  - frequency
  - batching
  - digests
  - fatigue
category: knock-product-messaging-strategy
last_updated: 2026-07-23
---

# Volume and batching

Source: [The product leader's guide to effective messaging](https://knock.app/manuals/product-leaders-guide-to-effective-notifications/the-product-leaders-guide-to-effective-notifications)

Notification fatigue is usually a system problem. One reasonable email per team becomes five messages for the user in ten minutes.

## Frequency controls that matter

Design these explicitly:

- **Per-workflow limits.** Cap repeated execution over a window (Knock throttle).
- **Cooldowns.** Pause related messages after delivery, dismissal, or engagement.
- **Suppression rules.** Skip users who acted, lost access, or became ineligible.
- **Global / category limits.** Cap non-critical communication across workflows.
- **Priority rules.** Let operational messages outrank campaigns and education.

Test the collision case: five workflows become eligible for the same user within ten minutes. Decide whether to suppress, delay, combine, or send only the highest-priority message.

## Batching models

Batching reduces interruptions without hiding meaning.

| Model | Use when |
| --- | --- |
| Time-window | Related events arrive in a burst |
| Object-based | Activity centers on one doc, project, or account |
| Recipient-based | One user has many updates across objects |
| Threshold-based | Notify only after activity reaches a meaningful level |

Example summary:

> Alex, Priya, and Morgan added four comments to the Q3 planning document.

Define for each batched workflow:

- What can wait
- How long it can wait
- Which events break the batch (for example a direct mention)
- How grouped data renders per channel

Products with collaboration, monitoring, or high account activity should plan batching early. It is harder after templates assume one event per message.

## Digests vs real-time

| Prefer digest | Prefer real-time |
| --- | --- |
| Low-urgency activity | Direct mentions, security, payment failure |
| High-volume accounts | Single critical ops alert |
| Education / product updates | User-requested outcomes |

Active users often need stricter caps. Dormant users may need fewer, higher-value emails rather than the same stream they ignored in-product.

## Agent steps

Write these into `knock-plan.md` (not chat):

1. Label each workflow critical vs non-critical for volume policy.
2. Add throttle / cooldown / suppression notes.
3. Decide batch key and window where activity clusters.
4. Call out digest candidates and their cadence.
5. Describe the multi-workflow collision behavior for this product.
