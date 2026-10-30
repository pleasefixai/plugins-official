---
name: omneky-getting-started-and-failures
description: >-
  Recover Omneky session context: sign-in/OAuth, unknown brand,
  unauthorized, pending/timeout/needs_user_decision/credit_insufficient.
  Also the named-preset menu when they ask what they can do. Do not
  use for first-run onboarding (omneky-onboarding), agency
  cross-brand (omneky-agency), weekly marketing plans
  (omneky-marketing-plan), paid-media analysis or catalogue
  (omneky-analytics-and-catalogue), competitor analysis
  (omneky-competitor-analysis), A/B tests (omneky-ab-tests),
  generating creatives, launch/connect
  (omneky-launch-and-connect), or credits (omneky-billing).
  Keywords: sign in, OAuth, list brands, unauthorized, timeout,
  empty data, no brands, which brand, needs user decision,
  credit insufficient, named presets, what can you do.
---

# Session context and failure recovery

The user signs in to the connected Omneky MCP server through the host's
OAuth. Never ask for or paste a JWT, token, or password.

This skill is the recovery entry. Healthy creative (`omneky-image-ads`,
`omneky-product-video`, `omneky-avatar-ugc`,
`omneky-voice-and-video-clone`, `omneky-edit-and-resize`), launch,
analytics, catalogue, billing, and marketing-plan requests go straight
to those skills.

Handoff fields:
[handoff-contract](references/handoff-contract.md).
Sourced ids (how to obtain / what to do if absent):
[preconditions](references/preconditions.md).
Quote, retry, and polls:
[creative-pricing-and-polling](references/creative-pricing-and-polling.md).
Acceptance gates:
[creative-quality-gates](references/creative-quality-gates.md).
Structured brief:
[creative-brief](references/creative-brief.md).
QA and cheapest repair:
[media-qa-and-repair](references/media-qa-and-repair.md).
Named presets and other intents:
[capability-registry](references/capability-registry.md).
Write for:
[marketer-persona](references/marketer-persona.md).

## Goal

Recover a broken session and list named presets. First-run setup is `omneky-onboarding`.

## Prerequisites

| Need | Check | If missing |
|---|---|---|
| Session | `get_current_user` | Host OAuth reconnect |
| Brand | `list_brands` | Ask which; no brands → Omneky app |
| Connectors | `list_connector_statuses` | Connect via `omneky-launch-and-connect` |
| Credits (shortfall) | `get_account_credit_balance` | `omneky-billing` |

## Flow

Open the named-preset menu when they ask what they can do. Recover failures below. Show: what broke, the fix, what to do next. Do not quiz them.

## When to use

- 401 / JWT errors, unknown or ambiguous `brand_id`
- Empty metrics, `status=timeout` / `pending` / `needs_user_decision`
- `credit_insufficient`
- `price_changed`
- A video pick that returns `narrative_unresolved`

## When not to use

- A healthy "make a branded ad" / "video ad" / "which ads should I make
  more of" / "how many credits" / "weekly marketing plan" request —
  open that skill directly
- Weekly plan create / revise / poll / approve →
  `omneky-marketing-plan` (this skill does not own that loop)
- Competitor analysis → `omneky-competitor-analysis`
- A/B test create or measure → `omneky-ab-tests`
- First-run setup / first ad today → `omneky-onboarding`
- Cross-brand / all clients → `omneky-agency`
- Not a license to invent purchase, card-PAN, or warehouse tools

## Named presets

When they ask what they can do, list these one-liners, then open
the owning skill from the capability registry. Do not run a
healthy creative, launch, plan, or billing request here.

| Preset | One-liner |
|---|---|
| `winners-this-week` | This week's top ROAS ads (calendar week to date). |
| `weekly-performance-report` | Coverage, winners, and movers for the stated window. |
| `fatigue-refresh` | Find fatigued Meta ads; brief 3 replacement hypotheses. |
| `top-roas-variations` | N distinct stills from verified top-ROAS winners. |
| `budget-reallocation` | Read-only move recommendation; apply only after a yes. |
| `ugc-from-best-messaging` | Talking-head UGC from the winning line of copy. |
| `ugc-product` | Product-in-hand talking-head from the catalogue still. |
| `ugc-review` | Truthful review; no invented claims. |
| `ugc-unboxing` | Reveal arc; product visible by the recorded beat. |
| `ugc-tutorial` | Demonstrable steps, not a voiceover-only lecture. |
| `ugc-website-demo` | Accurate UI; use a real HTTPS capture. |
| `hero-still` | One product-hero still from the catalogue image. |
| `before-after-still` | Two-state still; both states from approved evidence. |
| `thumbnail-still` | One still for a placement thumbnail. |
| `stills-of-one-concept` | Up to 3 stills of one concept when that tool is listed. |
| `product-video-story` | Pick a narrative card, then generate. |
| `faceless-product-video` | Product / professional video with no talking head. |
| `generate-now-video` | Skip the card list only when they say so. |
| `paused-campaign-from-winners` | Launch winners `PAUSED` after one yes. |
| `competitor-analysis` | Cited positioning, angles, and gaps. |
| `ab-test-create` | One hypothesis, one variable, `PAUSED`, recorded plan. |
| `ab-test-measure` | z-test readout; refuse a winner when data is thin. |
| `weekly-marketing-plan` | Goal → analyze → create → revise → preview; host runs steps. |
| `brand-setup-from-website` | Analyse the site, import products, stay on that brand. |
| `first-ad-today` | URL → brief → quote → `PAUSED` launch. |
| `managed-run-it-for-me` | Omneky-managed Meta / OpenAI when they have no ad account. |
| `roas-cpa-drop` | Movers + breakdown + daily; what to pause or scale. |
| `waste-pruner` | Underperformers; pause only after a yes. |
| `weekly-cross-brand-report` | Per-client cards; no silent brand switch. |
| `hero-to-all-sizes` | One hero, then every remaining placement size. |
| `seasonal-promo-kit` | One promo brief across the placements they named. |
| `product-launch-video` | Launch / explainer product video from catalogue stills. |
| `founder-spokesperson` | Talking-head; custom face allowed; cloned voice optional. |
| `localized-ad-set` | One talking-head per locale via listed voices. |
| `clone-winning-format` | Clone a library video onto our product (not a public file). |
| `audience-targeting` | Breakdowns + `search_ad_targeting`; apply only after a yes. |
| `target-cpa-budget` | Floor from `minimum_budget_for_objective` / `reach_estimate`. |
| `gsc-queries-to-ad-angles` | Search Console queries → cited ad angles. |
| `keyword-gaps` | Semrush / Ahrefs gaps, both sides fetched. |
| `domain-rating-backlinks` | Ahrefs rating + backlink overview (not Ad Library). |
| `hubspot-attribution` | Campaign/deal labels side by side; inferred, not attributed. |
| `abm-from-hubspot` | Cited firmographic lines into a creative brief. |
| `multi-brand-rollout` | One brand per yes; never silent-switch. |
| `credits-and-cost` | Balance then `quote_creative_credits`. |
| `upgrade-top-up` | `list_available_plans` → `start_plan_upgrade` or portal. |
| `credit-history-audit` | Ledger via `get_credit_history`. |

Capability gaps (subtitles burn-in, website builder, try-on,
motion-craft, video edit, narrator-on-existing, YouTube pack,
video ad-multiplier) live in the capability registry. Decline
those asks. Do not fake them.

## Context, not onboarding

There is no mandatory first-turn sequence. Act on the user's request and
resolve only what it needs. Reuse known identity and brand context.
Ask only for missing info.

1. **Identity.** The server knows who is signed in. Call
   `get_current_user` only when the user asks who they are signed in as.
   On JWT / 401, ask the user to reconnect the Omneky app in the host.
2. **Brand.** Reuse the `brand_id` already chosen in this conversation.
   If it is unknown and the request needs one, `list_brands` (pass
   `search` when the user named the brand):
   - **No brands.** Say this login has no brands yet. Do not invent a
     `brand_id`. Point them at the Omneky app (Ads Central) to create
     one.
   - **Several matches.** List each matching name and id and ask which
     one. Do not take the first row.
   - **One clear match.** Say that name and id, then keep it.
3. Stick to the chosen `brand_id`. Empty metrics are not a reason to
   switch brands.
4. `get_brand_details` when the next step needs logo, colors, or copy.
   Basic record only: `get_brand`.
5. `list_connector_statuses` when the user asks what is connected.
6. `health_check` only when diagnosing a connection problem. It does
   not return ads, credits, brands, or ROAS.

## Approvals

Ask once, concretely, before anything paid or live: what will happen,
for which brand, and that the server will report the cost. Reads,
lookups, and status checks need no approval. Destructive deletes keep
their own explicit confirmation (`omneky-launch-and-connect`).

## Hard rules shared with creative

- After a narrative card pick, pass that `narrative_id`. A bad or
  missing id is `narrative_unresolved`: re-fetch narratives and pick
  again. Do not turn that error into Generate Now.
- Generate Now is only a true omit of both narrative fields, and only
  when the user explicitly skips the pick (`omneky-product-video`).
- A hero spin or product animation is not a commercial. Do not route
  it to `generate_product_video`.
- `environment_setting` is an HTTPS image URL only.
- `generate_image_ad` uses `ad_concept` (never `prompt`) and a
  `gpt_ad_gen_id` (`<short-slug>-<uuid4>`). New id per new variant;
  see Ambiguous paid-submit recovery for retries. `edit_image` uses
  `images` (list of URL strings) and `prompt`.
- Generation poll bounds live in
  [creative-pricing-and-polling](references/creative-pricing-and-polling.md).
  Plan poll bounds live in `omneky-marketing-plan`. Do not
  silent-loop here.
- You decide whether to quote (`quote_creative_credits`) and whether
  to ask first; if you show a price, use the exact quoted total.
  Never guess. Pass
  `items[].expected_credits` on the paid tool when that field is
  listed; omit it if not. Do not pass `expected_credits` for a figure
  you did not get from a quote. `price_changed` means re-quote — do
  not retry with the old figure.

## Quote unavailable

Whole-call miss: `quote_creative_credits` missing, errors,
`quote_unavailable`, or every line is `not_quotable`
(`total_credits` omitted or null). The price is not available:
never treat a missing or 0 total as the price. You decide whether
to proceed; say the price was not available and report credits
actually charged afterward. Mixed batch (some lines quoted, some
`not_quotable`, e.g. a clone-video line off the 30/60 tier): show
the quoted totals and pass no `expected_credits` for the
`not_quotable` line.

## Ambiguous paid-submit recovery

This rule covers async paid submits (`generate_image_ad` and
`generate_product_video`). Sync edit and resize are charged on
each call.

### Rejected before acceptance

These responses happen before any charge. Fix the request and
resubmit only when the code is in this list:

- `schema_invalid`
- `invalid_argument`
- `price_changed` (re-run `quote_creative_credits`, get fresh
  approval; do **not** retry with the old `expected_credits`)
- `not_found_or_forbidden`
- `credit_insufficient` (nothing charged; upgrade or stop — do not
  retry until they have credits)
- `narrative_unresolved` (re-fetch and pick again; no job)
- `quote_unavailable` (price cannot be confirmed; do not invent one)

Mint a new submit id only after one of those recognized pre-accept
rejections or the user's OK.

### Credit outcome

Read `credits_charged` when the tool result includes it.

- `credits_charged: false` means this server did not deduct. Say that.
  Do not tell the user you cannot tell whether credits were deducted.
- `submission: not_started` with `credits_charged: false` means no job
  exists. Fix the request and resubmit only for a recognized
  pre-accept rejection (the list above, or this pair).
- `submission: unconfirmed` with `credits_charged: false` means credits
  were not charged, but a job might still have been queued. Check
  `get_generation_status` with the returned `job_id` and `kind=video`.
  If no job is found and generate_* tools for this job type appear
  on this session's `tools/list`, it is safe to retry once. If they
  do not, do not retry. Poll `get_generation_status` or
  `list_ad_instance_items` when listed, and tell the user generation
  isn't available on this connector. You will not be
  double charged because credits are only deducted after a confirmed
  `job_id`.
- `credits_charged: true` means the charge landed and `job_id` is the
  poll id.
- If `credits_charged` is absent, keep the rule below.

### Do not resubmit

Split image and video recovery. Do not reuse "the same id" for both.

- Image ads: a timeout, 5xx, or connection drop means do **not**
  mint a new id. Reuse the same `gpt_ad_gen_id`. Check
  `get_generation_status` with `kind=image` (bounds in
  [creative-pricing-and-polling](references/creative-pricing-and-polling.md)).
  A repeat of an already-charged image id returns
  `already_submitted` and the original job.
- Product video `submission: unconfirmed` (timeout / 5xx): there is
  no caller submission key. Check `get_generation_status` with the
  returned `job_id` and `kind=video`. If no job is found and
  generate_* tools for this job type appear on this session's
  `tools/list`, it is safe to retry once. If they do not, do not
  retry. Poll `get_generation_status` or `list_ad_instance_items`
  when listed, and tell the user generation isn't available on
  this connector. Credits deduct only after a confirmed `job_id`.
- Product video `submission: not_started`: no job exists. Fix the
  request and resubmit only for a recognized pre-accept rejection.
- `edit_image`, `resize_ad`, and `resize_image`: do **not**
  auto-retry. Check `get_credit_history` or the returned asset,
  or ask the user. A retry is a new charge.
- Any other timeout, 5xx, connection drop, or unrecognized error
  means do **not** resubmit. The request may already have been
  accepted.

An image transport retry reuses `gpt_ad_gen_id`. Product video
has no caller submission key — poll the returned `job_id`, and
retry once only if no job is found and generate_* tools for
this job type are on `tools/list`. If they are not, do not
retry; tell the user generation isn't available on this
connector. A new
image variant uses a new `gpt_ad_gen_id`. Never mint a new
`gpt_ad_gen_id` just because a call timed out or the connection
dropped.

## After a job or a failed check

Three states. Poll bounds live in
[creative-pricing-and-polling](references/creative-pricing-and-polling.md).
Acceptance gates live in
[creative-quality-gates](references/creative-quality-gates.md).
Never reuse a completed job id to repair it.

**Pending.** Still running. Same generation id. Never resubmit.

**Terminal failure.** Job failed. Explain. A new attempt is a new
paid generation: fresh approval and quote unless the tool says
refunded / not charged.

**Quality failure.** Job succeeded but a check failed. Show the
result. Offer a revision. New generation needs fresh approval.

## Failures

- Empty reporting → `check_reporting_data_available` first; empty is
  not zero. Do not switch brands to force a number. Performance depth:
  `omneky-analytics-and-catalogue`.
- `get_recommendations` or unscoped `get_ad_groups` timeout → narrow
  the query; do not retry the identical call this turn.
- Scrape `pending` → retry later, same `brand_id` + url.
- LinkedIn / TikTok 400 → location pre-call on the launch skill
  (`search_ad_targeting` / `get_tiktok_location_ids`). X Ads channel
  value is `twitter`.
- `needs_user_decision` → `request_user_decision`. Present the
  questions in chat. Never dump `clarification_needed` JSON. Never
  auto-retry.
- `credit_insufficient` → nothing started or was charged. Tell the user
  the shortfall (`required` vs `balance`) and offer: upgrade the plan,
  or stop. Hand off to `omneky-billing` only if they choose to upgrade.
  Never collect a PAN. Never invent a credit purchase tool.
- `price_changed` → the live quote differed. Nothing started or was
  charged. Re-run `quote_creative_credits`, get fresh approval, and
  never auto-retry with the old `expected_credits`. If that field is
  not on `tools/list`, omit it.
- A tool named in these skills is not available in this session: do
  not invent it. Say it is not available here; the user can do it in
  the Omneky app (Ads Central). Do not offer another app or connector.

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
