---
name: omneky-ab-tests
description: >-
  Create or measure an Omneky paid-media A/B test. Use for A/B
  test creation (one hypothesis, one variable, precommitted
  plan, PAUSED launch) or A/B test measurement (z-test, CI,
  power, SRM, interim peek with no verdict, refuse a thin
  winner). Do not use for generic ROAS tables
  (omneky-analytics-and-catalogue), competitor analysis
  (omneky-competitor-analysis), first-run onboarding
  (omneky-onboarding), agency (omneky-agency), weekly marketing
  plans (omneky-marketing-plan), generating creatives
  (omneky-image-ads, omneky-product-video, omneky-avatar-ugc),
  or credit balance (omneky-billing). Keywords: A/B test,
  ab test create, ab test measurement, which variant won,
  significance, two-proportion z-test, MDE, SRM, interim peek,
  underpowered, commercially meaningful, budget split.
---

# A/B tests

Use the connected Omneky MCP server. Gate every named tool on this
session's `tools/list`. If the tool for a requested step is missing,
say so and point to the Omneky app. Do not invent a tool.

This skill owns the **test plan** (create) and the **readout**
(measure). Generic winner lists stay in
`omneky-analytics-and-catalogue`. A one-off `PAUSED` launch without
a test plan stays in `omneky-launch-and-connect`.

Handoff fields:
[handoff-contract](references/handoff-contract.md)
(including the A/B test plan fields).
Formulas and worked examples (example data only):
[ab-test-statistics](references/ab-test-statistics.md).
Sourced ids:
[preconditions](references/preconditions.md).
Acceptance gates:
[creative-quality-gates](references/creative-quality-gates.md).
Structured brief:
[creative-brief](references/creative-brief.md).
Other intents:
[capability-registry](references/capability-registry.md).
Write for:
[marketer-persona](references/marketer-persona.md).

## Goal

Create a one-variable `PAUSED` A/B test with a precommitted plan,
or measure it with a two-proportion z-test and a marketer verdict.

## When to use

- A/B test create, A/B test measurement, which variant won,
  significance, stop rule, interim peek, SRM, MDE

## When not to use

- Generic ROAS table → `omneky-analytics-and-catalogue`
- Launch without a test plan → `omneky-launch-and-connect`

## Prerequisites

| Need | Check | If missing |
|---|---|---|
| Brand | `list_brands` | Ask which |
| Channel | `get_channel_connection_status` | Connect or managed |
| Budget floor | `minimum_budget_for_objective` | Do not launch under the floor |
| Variants | prior creative handoff | Owning creative skill |
| Baseline | `get_daily_metrics` with `date_range` | State an assumed `baseline_rate` |
| Coverage (measure) | `check_reporting_data_available` | Do not declare a winner |
| Metrics (measure) | `get_performance_breakdown` / `get_daily_metrics` | Narrow the window |

## Flow

Follow Create or Measure. **Invalid** is exempt from the
horizon gate. The setup check (step 4) runs on every look,
including pre-horizon peeks. If it fails, give the verdict
Invalid immediately, Stop, and recommend pausing or fixing the
test (a pause is a later yes via `omneky-launch-and-connect`;
never mutate here). Only Winner, Not commercially
meaningful, Inconclusive, and No detectable difference wait
for `horizon`. A peek that passes the setup check is INTERIM
with no statistical verdict. Refuse a winner when the sample
is thin.

## Hard rules

- Stick to the chosen `brand_id`. Never silent-switch brands.
- One hypothesis, **one** variable. Extra changes are a new test.
- Default new launches to `PAUSED`. Live spend needs an explicit
  yes in the same summary.
- Call the budget-floor tool (`minimum_budget_for_objective`)
  before any budget. Do not set a daily budget under that floor.
  Split the approved total across variants; each arm stays at or
  above the floor or you do not launch.
- Paid creatives that precede the test use the owning creative
  skill: Never invent a price.
- Precommit and record the test plan: `primary_metric` (one),
  `baseline_rate`, `mde`, `alpha` (default 0.05), `power`
  (default 0.8), `n_per_arm` from the two-proportion formula
  (show it), `randomization_unit` plus the ad-level-split caveat,
  `attribution_window`, and `horizon` (end date or sample).
- Measure: **Invalid** is exempt from the horizon gate. The
  setup check runs on every look, including pre-horizon
  peeks. If it fails, give the verdict Invalid immediately,
  Stop, and recommend pausing or fixing (pause is a later yes via
  `omneky-launch-and-connect`; never mutate here). Only
  Winner, Not commercially meaningful, Inconclusive, and
  No detectable difference wait for `horizon`. A peek that
  passes setup is INTERIM. Early stop needs an explicit
  acknowledgement and a Bonferroni or O'Brien-Fleming
  correction (or say it is not supported).
- Report effect size + CI, p-value, and achieved power.
  Significance is not commercial meaning — compare to `mde` and
  a CPA / ROAS $ impact.
- SRM → Invalid only on a randomized planned split (platform
  A/B / split-test, or an explicit planned allocation). Default
  one-ad-group, one-ad-per-variant delivery is auction-driven:
  do not run SRM as a gate; report imbalance as a caveat and
  compare rates, not totals. Broken setup (near-zero delivery,
  mid-test change, more than one variable) → Invalid. Low
  counts → Insufficient data. Many variants → Bonferroni.
- Scale / kill / iterate needs a later yes
  (`omneky-launch-and-connect`).

## Create

1. Write the test plan with the user (one turn if they already
   gave it):
   - Hypothesis (what should win, and why)
   - Single variable (creative, or headline, or audience — pick one)
   - `primary_metric` (CTR or CVR — one only)
   - `baseline_rate` from `get_daily_metrics` with `date_range`,
     or a stated assumption
   - `mde` (absolute rate)
   - `alpha` 0.05 and `power` 0.8 unless they set others
   - `n_per_arm` from the two-proportion formula (show it;
     [ab-test-statistics](references/ab-test-statistics.md))
   - `randomization_unit` and the caveat that platform ad-level
     splits are not true user randomization unless platform A/B
     is used
   - `attribution_window`
   - `horizon` (end date or sample). This is the stop rule.
2. Variants come from the structured brief (or a prior creative
   handoff). Same brief except the one variable.
3. Structure: one campaign, one ad group, one ad per variant
   (same targeting and budget split). Use an existing campaign
   only when they named it (`campaign_spec.id`).
4. Preflight the channel with `omneky-launch-and-connect` rules:
   connect status, budget floor, targeting pre-call, copy / CTA /
   landing URL, credits. Default new launches to `PAUSED`.
5. One summary: channel, tool, variants, budget split, floor,
   the full test plan, `PAUSED`. Wait for one yes.
6. Call the matching `launch_*`. Then write the test plan back
   (`primary_metric`, `baseline_rate`, `mde`, `alpha`, `power`,
   `n_per_arm`, `randomization_unit`, `attribution_window`,
   `horizon`, campaign / ad ids).

Do not go live unless that yes said to go live.

## Measure

1. Reuse the test plan. Missing ids: `get_campaigns` /
   `get_ad_groups` (pass `campaign_id`) / `get_ads`. Do not guess.
2. `check_reporting_data_available` for the brand + window +
   channel. No imported data → stop. Empty is not zero.
3. `get_performance_breakdown` (dimension ad or creative) and
   `get_daily_metrics` for the window. `get_performance_movers`
   when they asked what changed vs the prior period.
4. Setup check on every look, including pre-horizon peeks.
   **Invalid** only for a broken setup: near-zero delivery
   on a variant, a variant changed mid-test, or more than
   one variable differs. Default setup (one ad group, one
   ad per variant) is auction-driven: do not run SRM as a
   gate. Report delivery imbalance as a caveat and compare
   rates, not totals. Run SRM → Invalid only when traffic
   was randomized with a planned split (platform A/B /
   split-test, or an explicit planned allocation) and
   χ² p < 0.001. If the setup check fails, give the verdict
   Invalid immediately, Stop, and recommend pausing or fixing the
   test (a pause is a later yes via
   `omneky-launch-and-connect`; never mutate here).
5. Sample size: state impressions, clicks, and conversions per
   arm. Thin if either arm has fewer than about 1,000 impressions
   or 30 clicks (or 10 conversions when the metric is CVR) →
   Insufficient data. Do not declare a winner.
6. Horizon not reached and setup check passed → **INTERIM**
   status only. No statistical verdict (Winner / Not
   commercially meaningful / Inconclusive / No detectable
   difference). Do not relabel a failed setup check as
   INTERIM. If they insist on early stopping, require an
   explicit acknowledgement and apply Bonferroni across
   looks or O'Brien-Fleming-style (see the statistics
   reference). If they will not acknowledge, say early
   stopping is not supported.
7. Horizon reached (or corrected early stop): two-proportion
   z-test on the precommitted metric. Two-sided. Show n,
   successes, z, p-value, 95% CI, achieved power. This is a
   simple frequentist check, not an uncorrected sequential test
   — say that.
8. Verdict:
   - **Invalid** — exempt from the horizon gate. From the
     step-4 setup check on every look, including peeks.
     Immediate Stop. Recommend pausing or fixing (later yes
     via `omneky-launch-and-connect`; never mutate here).
   - Only these wait for `horizon` (or a corrected early
     stop — lead with this):
     - **Inconclusive (underpowered)** — power < 0.8 and not
       significant
     - **No detectable difference** — |z| < 1.96 and power ≥ 0.8
     - Not commercially meaningful — significant but |lift| < `mde`
       (or $ impact below the stated floor)
     - **Winner** — significant, |lift| ≥ `mde`, $ impact stated
9. Scale / kill / iterate is a later yes on
   `omneky-launch-and-connect`. Do not mutate here.

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
There is no sequential-testing platform tool. Early stop is
acknowledgement + correction, or not supported.
