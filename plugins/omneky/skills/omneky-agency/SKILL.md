---
name: omneky-agency
description: >-
  Agency multi-brand Omneky work. Use for a weekly cross-brand
  report (per-client summaries) or a multi-brand campaign rollout
  with per-brand confirmation. Never silent-switch brands. Do not
  use for a single-brand ROAS table
  (omneky-analytics-and-catalogue), first-run onboarding
  (omneky-onboarding), competitor analysis
  (omneky-competitor-analysis), A/B tests (omneky-ab-tests), or
  credit balance (omneky-billing). Keywords: weekly cross-brand
  report, per-client summary, multi-brand rollout, agency
  clients, all brands this week.
---

# Agency multi-brand work

Use the connected Omneky MCP server. Gate every named tool on this
session's `tools/list`. Missing tools → Omneky app. Do not invent
a tool. Never ask for internal ids.

This skill owns **cross-brand** reports and rollouts. One brand
only → `omneky-analytics-and-catalogue` or the matching creative /
launch skill.

Handoff fields:
[handoff-contract](references/handoff-contract.md).
Sourced ids:
[preconditions](references/preconditions.md).
Acceptance gates:
[creative-quality-gates](references/creative-quality-gates.md).
Other intents:
[capability-registry](references/capability-registry.md).
Write for:
[marketer-persona](references/marketer-persona.md).
Gaps:
[capability-gaps](references/capability-gaps.md).

## Goal

Give an agency operator per-client numbers and a safe multi-brand
rollout: one brand at a time, explicit confirmation, no silent
switch.

## When to use

- Weekly cross-brand / per-client report
- Multi-brand campaign rollout
- "All my clients this week"

## When not to use

- One brand's ROAS / movers → `omneky-analytics-and-catalogue`
- First-run setup → `omneky-onboarding`
- Credit ledger → `omneky-billing`
- Sign-in only → `omneky-getting-started-and-failures`

## Prerequisites

| Need | Check | If missing |
|---|---|---|
| Session | `get_current_user` | Host OAuth reconnect |
| Brand list | `list_brands` | No brands → Omneky app. Do not invent |
| Reporting coverage | `check_reporting_data_available` per `brand_id` | Skip that brand; empty is not zero |
| Metrics | `get_performance_breakdown` / `get_daily_metrics` / `get_performance_movers` | Narrow the window; do not invent ROAS |
| Launch apply | matching `launch_*` / `set_ad_budget` / `set_ad_entity_status` | Per-brand yes first. Default `PAUSED` |

## Flow

One short card per brand (spend, ROAS, CTR, mover, next step),
then a one-line roll-up. Never silent-switch brands. Confirm the
brand set once; do not re-ask per metric.

### weekly-cross-brand-report

1. `list_brands`. Show the name + id list. Confirm the set
   (or the named subset) before any metric call.
2. For each confirmed `brand_id`:
   - `check_reporting_data_available`
   - `get_performance_breakdown` (winners / spend)
   - `get_performance_movers` when they asked what changed
   - `get_daily_metrics` when they asked for the chart
3. Thin samples: "too little data to conclude" + the numbers.
4. Deliverable: one short card per client (spend, ROAS, CTR,
   mover, recommendation) and a one-line roll-up. Confidence =
   coverage + sample size per brand.

### multi-brand-rollout

1. Confirm the brand set. One brand per cycle.
2. Say the brand name and id. Wait for a yes on **that** brand
   before generate or launch. A yes for brand A is not a yes
   for brand B.
3. Creative / launch follow those skills. Default `PAUSED`.
   Pass each brand's own `brand_id`.
4. Deliverable: per-brand status table (quoted, generated,
   launched `PAUSED`, skipped).

## Failure and recovery

Auth / 401 → `omneky-getting-started-and-failures`.
One brand empty → skip it; do not pull another brand's rows
to fill the card.
`status=timeout` → narrow that brand's window; do not retry
the identical call this turn.
`credit_insufficient` → stop that brand; billing if they
upgrade. Continue other brands only after a new yes.

## Gaps

No agency inbox, no organic scheduler, no cross-account
login. See
[capability-gaps](references/capability-gaps.md).
