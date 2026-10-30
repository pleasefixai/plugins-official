---
title: Map product lifecycle
description: Locate activation, engagement, and retention signals in the codebase
tags:
  - lifecycle
  - discovery
category: knock-lifecycle-opportunities
last_updated: 2026-07-23
---

# Map product lifecycle

## Areas to inspect

| Stage | Code / product clues |
| --- | --- |
| Acquisition / signup | Auth routes, `User.create`, invite tokens |
| Activation | Onboarding wizards, checklist models, “first X” flags, empty states |
| Habit / engagement | Core resource CRUD, collaboration (comments, assigns), dashboards |
| Expansion | Seat invites, plan upgrades, feature gates, usage limits |
| Revenue | Stripe/Billing webhooks, trial fields, dunning |
| Risk / churn | `last_seen_at`, canceled flags, failed payments, unused seats |

## Prefer precise signals

Avoid recommending “user inactive 7 days” alone. Prefer combinations such as:

- Invite sent + not accepted + workspace still needs member
- Trial ending + onboarding incomplete
- Integration disconnected + still enabled in UI
- Payment failed + subscription past_due

## Capture

For each signal, write into `knock-plan.md` (Signals found table): model/field or event name, file path, who the actor/recipient is, and whether a message already exists.

Do not paste the inventory into chat.
