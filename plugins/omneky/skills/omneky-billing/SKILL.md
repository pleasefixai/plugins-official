---
name: omneky-billing
description: >-
  Call get_account_credit_balance by name for remaining Omneky prepaid ad
  credits. Also plan entitlements and Stripe billing portal / plan
  upgrade links. Use when the user asks how many ad credits remain,
  credit balance, credit history, out of credits, upgrade plan,
  invoices, or card on file. Do not use for campaign spend/ROAS
  (omneky-analytics-and-catalogue), competitor analysis
  (omneky-competitor-analysis), A/B tests (omneky-ab-tests),
  first-run onboarding (omneky-onboarding), agency
  (omneky-agency), weekly marketing plans
  (omneky-marketing-plan), creating ads, launching
  campaigns (omneky-launch-and-connect), or collecting card numbers.
  Keywords: ad credits, credit balance, remaining credits, how many
  credits, credit history audit, top-up, upgrade plan, Stripe
  portal, invoices.
---

# Ad credits, plan, and billing portal

The connected Omneky MCP server exposes plan / Stripe portal billing and
prepaid credit balance / history. Call `get_account_credit_balance`
**by that exact name** for remaining ad credits.

URL redirects only. Never collect a PAN. Never invent a prepaid-credit
purchase tool. Running out of credits is resolved by a **plan upgrade**,
and only when the user chooses one. Never complete Checkout or the
portal yourself.

Handoff fields:
[handoff-contract](references/handoff-contract.md).
Sourced ids (how to obtain / what to do if absent):
[preconditions](references/preconditions.md).
Acceptance gates (when a later creative is in play):
[creative-quality-gates](references/creative-quality-gates.md).
Other intents:
[capability-registry](references/capability-registry.md).
Write for:
[marketer-persona](references/marketer-persona.md).

## Goal

Show credits, quote context, upgrade/top-up URLs, and a credit-history audit. Never collect a PAN.

## Prerequisites

| Need | Check | If missing |
|---|---|---|
| Balance | `get_account_credit_balance` | Say the tool is missing; Omneky app |
| Ledger | `get_credit_history` | Skip the audit line |
| Plans | `list_available_plans` | Cannot start upgrade |
| Upgrade | `start_plan_upgrade` | Portal: `create_billing_portal_session` |
| After pay | `get_checkout_session_status` | Poll once after they say they paid |
| Managed pay | `get_managed_launch_payment_status` | Only for managed-launch Checkout |

## Flow

Lead with remaining credits, the shortfall if any, one action
(upgrade URL or stop), and confidence. Do not narrate the
billing tools unless one is missing.

- **credits-and-cost.** `get_account_credit_balance`, then
  `quote_creative_credits` when they asked what a generate
  costs. Never guess a credit number.
- **upgrade-top-up.** One yes naming the plan.
  `list_available_plans` → `start_plan_upgrade`, or
  `create_billing_portal_session`. After they say they paid,
  `get_checkout_session_status` once. Never collect a PAN.
- **credit-history-audit.** `get_credit_history` as a dated
  ledger, not the live balance.

## When to use

- How many ad credits remain, credit balance, credit history
- Which plan, upgrade plan, invoices, card on file
- `credit_insufficient` after a creative or launch, when the user wants
  to upgrade

## When not to use

- Campaign spend, ROAS, or daily metrics (analytics skill)
- Weekly marketing plan create / revise / poll / approve
- Creating or launching ads
- Collecting a card number

## Call by name

Call only names that appear on this session's `tools/list`; if one is
missing, use the fallback at the end of this skill.

| User ask | Tool |
|---|---|
| how many credits / remaining credit balance | `get_account_credit_balance` |
| credit grants / usage ledger | `get_credit_history` |
| which plan, Stripe flags, credit snapshot | `get_billing_summary` |
| upgrade / switch plan | `list_available_plans` then `start_plan_upgrade` |
| invoices, live prices, card on file, cancel | `create_billing_portal_session` |
| card brand / last4 only | `get_payment_method_summary` |
| after the user returns from plan Checkout | `get_checkout_session_status` |
| managed-launch Checkout | `get_managed_launch_payment_status` |
| company record without the credit snapshot | `get_company` |

## Sequence

1. Remaining credits → `get_account_credit_balance` (`credit_balance`,
   `usd_per_credit`). Ledger → `get_credit_history` (not the live
   balance). Plan snapshot → `get_billing_summary`.
2. Upgrade, only when the user asked for it or chose it after a
   shortfall: `list_available_plans` returns lookup keys
   (`cgp_standard_monthly`, `cgp_pro_yearly`, …), **not** dollar prices.
   The user picks a plan. `start_plan_upgrade` with that
   `stripe_price_lookup_key` may change the plan immediately on a saved
   card, so get one explicit yes naming the plan first. Without a saved
   card it returns a `checkout_url` to hand over.
3. Portal: `create_billing_portal_session` → hand `portal_url` for live
   prices, invoices, or the card. Account owner only.
4. After the user pays, `get_checkout_session_status` once
   (plan-upgrade). Managed-launch Checkout →
   `get_managed_launch_payment_status`.

## credit_insufficient

The render or launch did not start and nothing was charged. The server
reports `required` and `balance`.

1. Tell the user the shortfall in one line. Offer the choices: upgrade
   the plan, or stop. Do not call `start_plan_upgrade` unless they
   choose to upgrade.
2. If they choose to upgrade: Sequence step 2 (or the portal). Hand the
   Stripe URL. Never collect a PAN.
3. If they decline: stop. Do not retry the job until they have enough
   credits.

## Prices

Do not quote credit prices for images, videos, edits, resizes, or
launches. Call `quote_creative_credits` when it appears on `tools/list`;
that tool returns the amounts, including each line's `expected_credits`
(the unit figure to pass back on the paid tool when that field is
listed). If the field is not listed, omit it. Do not pass
`expected_credits` for a figure you did not get from a quote. Skills
must not hardcode credit numbers. A `credit_insufficient` result also
reports `required`. 
Creative procedure lives in
`omneky-image-ads`, `omneky-product-video`, `omneky-avatar-ugc`,
`omneky-voice-and-video-clone`, and `omneky-edit-and-resize`.
See [creative-pricing-and-polling](references/creative-pricing-and-polling.md).

Whole-call miss: `quote_creative_credits` missing, errors,
`quote_unavailable`, or every line is `not_quotable`
(`total_credits` omitted or null). The price is not available:
never treat a missing or 0 total as the price. You decide whether
to proceed; say the price was not available and report credits
actually charged afterward. Mixed batch (some lines quoted, some
`not_quotable`, e.g. a clone-video line off the 30/60 tier): show
the quoted totals and pass no `expected_credits` for the
`not_quotable` line.

## If a billing tool is not available

If this session cannot call `get_account_credit_balance`, say the tool
is not available in this session. Do **not** invent a balance, a
purchase tool, or a claim that Omneky has no credits. The user can check
credits and plan in the Omneky app (Ads Central).

## Failure and recovery

Auth / 401 → `omneky-getting-started-and-failures` (host OAuth).
Empty reporting → `check_reporting_data_available`; empty is not zero.
`credit_insufficient` → nothing charged; `omneky-billing` only if they
choose to upgrade (`list_available_plans` → `start_plan_upgrade`).
`needs_user_decision` → `request_user_decision`; never dump JSON.
Missing tool → say so; Omneky app. Do not invent it.
Never ask for internal ids. Never silent-switch `brand_id`.

## Gaps

This connector cannot do comment/social inbox, landing pages,
subtitle burn-in, email/SMS, organic scheduling, Meta Ad Library
competitor ads, virtual try-on, or website builder. Decline those.
See [capability-gaps](references/capability-gaps.md).
