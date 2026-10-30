---
title: Relevance and preferences
description: Personalize with actionable context and design preference categories users can control
tags:
  - strategy
  - personalization
  - preferences
  - relevance
category: knock-product-messaging-strategy
last_updated: 2026-07-23
---

# Relevance and preferences

Sources:

- [The product leader's guide to effective messaging](https://knock.app/manuals/product-leaders-guide-to-effective-notifications/the-product-leaders-guide-to-effective-notifications)
- [In-app messaging best practices](https://knock.app/manuals/in-app-messaging/best-practices-for-in-app-messaging)

## Personalize the path to action

Useful personalization reduces work to understand and resolve the event. First-name tokens are not enough.

Weak:

> Your account has an update.

Strong:

> Your Salesforce integration for Acme stopped syncing 42 minutes ago. Reconnect it to resume lead enrichment.

Include context that matches channel and role:

- Account or project name
- Actor who caused the event
- Usage, plan, deadline, or amount due
- Error status or severity
- Previous attempts
- Recipient role
- Deep link to the affected resource

Admins may need diagnostic detail; end users need a simpler next step. Email can carry more context than push. In-app messages can rely on on-screen state.

For copy craft, also use `knock-notification-best-practices`.

## Target with segments, not blasts

In-app and lifecycle relevance categories:

- **Role-based.** Developer tips only for API users
- **Plan-based.** Upgrade prompts only for free-tier users
- **Behavior-based.** Suggest features after related success
- **Engagement-based.** Dormant users get a different path than daily actives

When users dismiss a guide or message, respect that choice for at least the session, preferably longer.

## Design preferences for granular control

A single on/off control forces users to choose between noise and silence.

Offer control across dimensions that match product complexity:

- Notification category
- Channel
- Immediate vs digest
- Project / resource subscriptions
- Individual vs team activity

### Recommended starter categories

Use recognizable groups; avoid dozens of unexplained toggles:

1. Security and account access
2. Billing and plan
3. Collaboration and mentions
4. Product activity (batched where possible)
5. Product updates / education
6. Marketing / announcements (if applicable)

Labels should describe covered events and expected frequency. Defaults should match role and product use — not "everything on."

Enforce preferences consistently across every workflow and channel in that category. Security, billing, legal, and service-critical messages may be exempt; mark those exemptions explicitly.

## Agent steps

Write these into `knock-plan.md` (not chat):

1. List the context fields each workflow template needs.
2. Propose a preference taxonomy for the product (categories + channel controls).
3. Map each workflow to a preference category or an explicit transactional exemption.
4. Set sensible defaults by role where possible.
5. Note Knock implementation: workflow [categories](https://docs.knock.app/concepts/workflows#workflow-categories), preference set keys, [conditions](https://docs.knock.app/preferences/preference-conditions), [hosted](https://docs.knock.app/preferences/hosted-preference-center) vs headless preference center. See [preferences overview](https://docs.knock.app/preferences/overview).
