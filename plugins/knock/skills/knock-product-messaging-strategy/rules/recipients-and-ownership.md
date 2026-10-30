---
title: Recipients and ownership
description: Route each message to the person responsible for the next action
tags:
  - strategy
  - recipients
  - ownership
  - escalation
  - roles
category: knock-product-messaging-strategy
last_updated: 2026-07-23
---

# Recipients and ownership

Source: [The product leader's guide to effective messaging](https://knock.app/manuals/product-leaders-guide-to-effective-notifications/the-product-leaders-guide-to-effective-notifications)

Broad recipient rules create most of the noise blamed on "bad notifications." Defaulting to the workspace owner, object creator, or entire account is convenient and often wrong.

## Route to the person who can act

Ask: what does this recipient know or control that makes the notification relevant?

Examples:

| Situation | Better recipient |
| --- | --- |
| Integration failed | Admin who configured it |
| Account limit reached | Billing owner |
| Approval pending | Current reviewer |
| Invite unused | Inviter or workspace owner (not every member) |
| Comment on a doc | Subscribers / participants (batched), not the whole workspace |

Recipient signals can include:

- Role and permissions
- Resource ownership
- Account membership
- Team or project assignment
- Explicit subscriptions
- Recent product activity
- Responsibility for resolution

## Change recipients over time

Escalation should add accountability, not copy everyone from step one.

Example approval path:

1. Notify the reviewer immediately
2. Remind the reviewer after one business day if still pending
3. Escalate to a team lead only when the deadline approaches

Do not CC every participant on every step.

## Multiplayer and B2B rules

For team products:

- Prefer the assignee or billing/admin role over "all users on the tenant"
- Use tenants/objects in Knock when messages are workspace-scoped
- Distinguish end-user tips from admin/ops alerts
- For win-back or activation, target the person who can unblock progress (often the owner or inviter)

## Agent steps

For each workflow in `knock-plan.md` (not chat):

1. Name the primary recipient rule in product terms (not only `user_id`).
2. Define escalation recipients and the condition that advances ownership.
3. List people who must never receive this message (wrong role, already acted, no access).
4. Note any Knock modeling needs (user properties, object subscriptions, tenants).
