---
name: omneky-analytics-and-catalogue
description: >-
  Call list_brand_products, identify_product_from_url, and
  get_product_details by name (list my products, import this
  product URL, SKU, PDP). Also winning ads, ROAS, CTR, weekly
  performance report, HubSpot, and read-only budget
  reallocation. Do not use for first-run onboarding
  (omneky-onboarding), agency cross-brand (omneky-agency),
  competitor positioning (omneky-competitor-analysis), A/B
  tests (omneky-ab-tests), weekly marketing plans
  (omneky-marketing-plan), generating creatives, launch
  (omneky-launch-and-connect), or credit balance
  (omneky-billing). Keywords: list my products, import this URL,
  catalogue, SKU, PDP, which ads should I make more of, winning
  ads, ROAS drop, CPA drop, CTR, weekly performance report,
  fatigue refresh, budget reallocation, waste pruner, audience
  targeting, target CPA, HubSpot attribution, ABM, Semrush,
  Ahrefs, GSC.
---

# Ad performance and product catalogue

The connected Omneky MCP server exposes the names below. Call them
**by those exact names** when they appear on this session's
`tools/list`. Metrics and reporting reads work without catalogue
tools. Catalogue names (`list_brand_products`, `get_product_details`,
`identify_product_from_url`, and the import / create / upsert tools)
are optional. If they are not listed, say that capability isn't
available on this connector. Do not invent a catalogue or claim
Omneky has no product list.

This skill is analysis and catalogue only. Competitor
positioning → `omneky-competitor-analysis`.
A/B tests → `omneky-ab-tests`.
Weekly plans → `omneky-marketing-plan`.
Image ads → `omneky-image-ads`. Product video →
`omneky-product-video`. Avatar / UGC → `omneky-avatar-ugc`.
Voice or video clone → `omneky-voice-and-video-clone`. Edit /
resize → `omneky-edit-and-resize`. Launch →
`omneky-launch-and-connect`. Credits → `omneky-billing`.

Handoff fields:
[handoff-contract](references/handoff-contract.md).
Sourced ids (how to obtain / what to do if absent):
[preconditions](references/preconditions.md).
Acceptance gates (for a later creative):
[creative-quality-gates](references/creative-quality-gates.md).
Structured brief (for a later creative):
[creative-brief](references/creative-brief.md).
Other intents:
[capability-registry](references/capability-registry.md).
Write for:
[marketer-persona](references/marketer-persona.md).

## Goal

Ranked evidence, catalogue records, and connector reads. No render. No spend mutation. Keep the weekly performance report.

## Prerequisites

| Need | Check | If missing |
|---|---|---|
| Brand | `list_brands` | Ask which; do not invent |
| Coverage | `check_reporting_data_available` | Say there is no imported data; do not report zeros |
| Winners / diagnosis | `get_performance_breakdown` / `get_daily_metrics` / `get_performance_movers` | Narrow the window |
| Product | `list_brand_products` when listed | Import via `identify_product_from_url` → scrape → finalize. If catalogue tools are not on `tools/list`, say that capability isn't available on this connector |
| HubSpot | `get_hubspot_connection_status` | Skip CRM joins; say disconnected |
| Semrush / Ahrefs / GSC | matching status tool | Skip that source |
| Budget apply | (read-only here) | `omneky-launch-and-connect` after a yes (`set_ad_budget` / `set_ad_entity_status`) |

## Flow

Lead with the answer (ROAS, CPA, CTR, spend, lift), one recommendation, and confidence. Recipes: winners, fatigue, weekly performance report, ROAS/CPA drop, waste pruner (evidence), targeting evidence, target-CPA plan, HubSpot attribution / ABM brief, catalogue import. Do not open a separate memo skill.

Collect `source_evidence` from the metric call you just ran: metric,
window (start and end dates, calendar or rolling), channel, ad or
creative ids, and sample size when handing a performance-informed
brief to creative or a plan-driven launch. Collect `approved_claims`
from the user or the product page / catalogue copy they pointed at;
each claim needs its source. Do not invent a claim. Plain
user-directed edits and launches do not need `source_evidence`.

## When to use

- "Which ads should I make more of?", winning ads, next batch brief
- ROAS, CTR, CPA, spend, movers, daily paid-media charts
- List products / SKUs, or import a product URL before an ad
  (only when those catalogue tools appear on `tools/list`)

## When not to use

- Competitor positioning / messaging gaps
  (`omneky-competitor-analysis`)
- A/B test create or "which variant won" (`omneky-ab-tests`)
- Weekly marketing plan create / revise / poll / approve
  (`omneky-marketing-plan`)
- Generating the image or video (hand off to `omneky-image-ads` or
  `omneky-product-video`)
- Launching or connecting campaigns (`omneky-launch-and-connect`)
- Credit balance or plan upgrade (`omneky-billing`)
- First-run setup / first ad today (`omneky-onboarding`)
- Cross-brand / all clients (`omneky-agency`)
- No product-delete tool

## Winning ads → next batch

Stay on the chosen brand for every call below. Empty rows are missing
coverage, not a reason to silent-switch brands.

1. Reuse the `brand_id` already chosen in this conversation. Unknown:
   `list_brands` (pass `search` when the user named the brand). Several
   matches: ask which one and wait. One clear match: say the name and
   id, then keep that `brand_id`.
2. Pick the date window before any metric call.
   - User named dates: use those inclusive `YYYY-MM-DD` days.
   - "This week" means the calendar week to date, not the last 7
     days. Use last 7 days only when the user says "last 7 days".
     Movers keep `period_days` (default 7) and do not take
     `date_range`. A winner list with no dates uses the last 30
     days. Always say which window you used.
   - This surface has no latest-date tool. Do not invent one.
3. `check_reporting_data_available`
   with that `brand_id`.
   Read which dates and channels actually have imported data.
   - Window or channel outside that coverage: say there is no imported
     data. Do not call a metric tool and report zeros. Narrow to a
     covered window, or stop.
   - Empty metrics after this check are missing data, not a zero ROAS,
     spend, or CTR.
4. Then, always passing that `brand_id` (it is optional in some
   schemas; send it anyway so results stay on the chosen brand):
   - Ranked winners: `get_performance_breakdown` with `dimension`
     (creative, campaign, ad, or channel), `date_range` as two inclusive
     dates `["YYYY-MM-DD", "YYYY-MM-DD"]`, `sort_metric` (the metric to
     rank by, such as `spend` or `roas`; the schema does not list
     values), `sort_order` (`desc` for winners), and
     `results_per_page` (10 is enough for a winner list). Pass
     `filters` as `[]` when not filtering. There is no `metrics`
     argument; set `include_all_metrics` to `true` when you need every
     column.
   - Day-by-day: `get_daily_metrics` with `date_range` (same shape) and
     `filters` as `[]` when not filtering. There is no `metrics`
     argument.
   - What changed vs the prior period: `get_performance_movers` with
     `dimension`, `metric`, `end_date` (last day of the current window,
     `YYYY-MM-DD`), and `period_days` (default 7). It builds the prior
     window. Do not send `date_range` to this tool.
   - Name the user said: `search_reporting_values` with `dimension` and
     `q` (the text). It returns labels, not metrics. Put the exact value
     in a later filter. Operators are `includes` or `excludes` only
     (`condition`, `dimension`, `value` as a list of strings). Do not
     invent `=`, `in`, or `gt`.
   - Current allocated daily budget (not spend, not historical ROAS):
     `get_channel_budget` with `channels`. Totals plus per-campaign
     `breakdown` / `basis` when the backend returns them. A disconnected
     or skipped channel is a per-channel error, not an empty total.
   - Fill any other required field from the tool's own schema and
     earlier results in this session. Do not ask the user for internal
     ids.
5. Never sum `selected_conversion_metric_value` across channels. That
   field is the brand's goal and it differs per channel (purchases on
   one channel, conversions on another). Group by channel, or use a
   named metric (`purchases`, clicks, spend, ROAS, CTR).
6. Minimum evidence (also in the handoff contract). State the
   sample next to every conclusion. Fewer than about 1,000
   impressions, 30 clicks, or 10 conversions per ad is thin — say
   "too little data to conclude" and show the numbers. Attribution
   differs by channel; do not mix attributed totals or sum
   `selected_conversion_metric_value` across channels. An aggregate
   ratio is summed numerators over summed denominators, never the
   mean of per-row ratios.
7. `get_recommendations` when the user asks what to try next. This is
   advice, not the metric table from steps 4–5.
   - Required: `brand_id`.
   - `start_date` and `end_date` are inclusive `YYYY-MM-DD`. Omit both
     for the last 30 days. A window longer than 30 days is capped at
     30. `metric` defaults to `spend`.
   - `status=timeout`: narrow the dates. Do not retry the identical
     call in this turn.
8. To **make** the next batch, hand the winning product or concept to
   `omneky-image-ads` or `omneky-product-video` with the handoff
   contract (brand, product, source evidence, approved claims,
   `source_ad_ids`, and one hypothesis per requested variant). This
   skill does not generate creatives. Launch is a later handoff. A
   weekly plan is `omneky-marketing-plan`, not a reconstructed
   generate/launch sequence here.

## Performance-to-creative flows

Evidence first, then a handoff. Do not invent ROAS. Do not generate
here. Each requested variant is one hypothesis: source ad, what
stays constant, what changes, audience / placement, success metric.

- **fatigue-refresh.** `get_performance_movers` on Meta (falling
  CTR or ROAS; state the window and sample). Pick up to 3 fatigued
  ads with enough evidence. Hand 3 replacement hypotheses to
  `omneky-image-ads` (or avatar/video when they asked for that
  format).
- **top-roas-variations.** `get_performance_breakdown` sorted by
  `roas`. Take the verified winners. Hand N distinct hypotheses
  (N = the count they asked for) to `omneky-image-ads`.
- **ugc-from-best-messaging.** From the same winner list, extract
  the winning line of copy into `approved_claims`. Hand that
  messaging to `omneky-avatar-ugc` (default testimonial, or the
  named UGC genre).
- **paused-campaign-from-winners.** After the creative skill
  returns accepted assets, hand `omneky-launch-and-connect` with
  those URLs. Launch stays `PAUSED` unless they explicitly say to
  go live.
- **weekly-performance-report.** Same coverage check, then
  `get_performance_breakdown` + `get_daily_metrics` +
  `get_performance_movers`. State the window. Thin samples stay
  "too little data to conclude." Do not declare an A/B winner
  here (`omneky-ab-tests`).
- **budget-reallocation.** Read `get_channel_budget` and the
  winner / mover tables. Recommend a move (from / to / amount /
  why). This skill is read-only. Applying `set_ad_budget` is
  `omneky-launch-and-connect` after one yes. Do not mutate spend
  here.

Thin samples stay suggestions: say "too little data to conclude"
and still show the numbers.

- **roas-cpa-drop-diagnosis.** Coverage first. Then
  `get_performance_movers` (falling ROAS or CPA),
  `get_performance_breakdown`, and `get_daily_metrics`. Explain
  with evidence only (window, sample, channel). Confidence is
  thin when samples are thin.
- **waste-pruner (evidence).** Rank by spend with weak CTR / ROAS
  on `get_performance_breakdown`. List pause candidates. Do not
  call `set_ad_entity_status` here — `omneky-launch-and-connect`
  after one yes per entity set.
- **audience-targeting-evidence.** Breakdowns by the dimensions
  they named. Token lookup is `search_ad_targeting`. Applying
  `update_ad_targeting` is launch, after a yes.
- **target-cpa-budget-plan.** `minimum_budget_for_objective` +
  `reach_estimate` + current `get_channel_budget`. Recommend a
  daily number at or above the floor. Applying it is launch.

## HubSpot (attribution caveats)

`get_hubspot_connection_status` first. Disconnected → skip.

Campaign-to-deal: `hubspot_search_deals` then `hubspot_get_deal`.
There is **no join key** from a paid `campaign_id` to a HubSpot
deal on this surface. Say that. You may place their named
campaign/deal labels side by side and label the pairing
**inferred, not attributed**. Do not claim paid-media ROAS from
HubSpot. Confidence = low unless they supplied the join.

ABM brief: `hubspot_search_companies` / `hubspot_get_company`
(industry, name). Hand cited firmographic lines as
`approved_claims` to a creative skill. Do not invent industry
stats.

## Call by name (catalogue)

Only when `list_brand_products` / `get_product_details` /
`identify_product_from_url` appear on this session's `tools/list`.
If they do not, say that capability isn't available on this
connector. Do not invent a catalogue.

| User ask | Tool |
|---|---|
| list my products / show SKUs / what's in the catalogue | `list_brand_products` |
| details / images for one product | `get_product_details` |
| import this product URL / paste a PDP | `identify_product_from_url` first, then scrape → finalize |

`list_brand_products` needs numeric `brand_id`. Then
`get_product_details` for images and copy used by a later ad. Do not
mention a second name for product details here.

## Import (short)

Only when the import tools appear on `tools/list`. If they do
not, say that capability isn't available on this connector.

Stay on the chosen numeric `brand_id`. Catalogue writes need one
confirmation of the fields being saved; reads need none.

1. `identify_product_from_url` with the pasted `url` before any scrape.
   - `is_single_product` false (listing, category, or home): do not
     scrape. Ask for one product page URL.
   - `true` or `null` (uncertain, often a JS-rendered page): you may
     scrape. On `null`, say the page was uncertain.
2. `scrape_product_from_url` with `brand_id` and that `url` (`locale`
   defaults to `en-us`). It captures the first product on the page only.
   - `status=pending`: retry **later** with the same `brand_id` and
     `url`. Do not tight-loop this turn. Do not start a second scrape.
   - `status=scraped`: show the fields and `scraped_image_urls`. The
     user confirms which images and any edits.
3. `finalize_scraped_product`. Required: `brand_id`, the scrape
   `product_id`, `image_urls` (at least one), `product_name`, and
   `product_description`. Zero images does not save. Do not finish a
   scrape with `upsert_brand_product` (the draft stays hidden). Use the
   **returned** catalogue `product_id` after this call.
4. No URL, hand-built: `create_product`. Required: `brand_id`,
   `product_name`, `product_description`. Confirm those fields first.
   `create_product` does not accept image or video bytes. Catalogue
   products cannot take uploaded media. If
   `list_brand_products` is empty and another tool needs a
   `product_id`, tell the user "I'll create a product you can reuse
   later", create it, and use the new id without making the user
   restart.
   Pass a public HTTPS image URL on the original creative
   call when that tool accepts one.
5. Edit a completed product: `upsert_brand_product` with `product_id`,
   and send the current `product_name` and `product_description` even
   when they are unchanged. Confirm first. URL only:
   `update_product_url` with `brand_id`, `product_id`, and `url`.
   Confirm the URL. There is no product-delete tool.
6. Hand off to `omneky-image-ads` or `omneky-product-video` for the
   ad. A product image ad sends
   **one** confirmed HTTPS image in `user_assets` (more only when the
   user asks). Quality drops with more than two.

## If a catalogue tool is not available

If this session cannot call `list_brand_products`,
`get_product_details`, `identify_product_from_url`, or the other
catalogue names, say that capability isn't available on this
connector. Do **not** invent a catalogue or claim Omneky has no
product list. The user can manage products in the Omneky app
(Ads Central).

## Connector reads

Connector reads stay available but are not the hero path. Check status
before a live read, and skip when disconnected:

- HubSpot: `get_hubspot_connection_status`, then
  `hubspot_search_contacts`, `hubspot_search_companies`, or
  `hubspot_search_deals` (page size 10, cap 100). One record after
  search: `hubspot_get_contact`, `hubspot_get_company`, or
  `hubspot_get_deal` by id. Skip when disconnected.
- Semrush: `get_semrush_connection_status`, then
  `get_semrush_domain_overview` (`domain`) or
  `get_semrush_keyword_overview` (`keyword`)
- Ahrefs: `ahrefs_connection_status`, then `ahrefs_domain_rating`
  (`target` is the domain).
  Organic keywords: `ahrefs_organic_keywords` (default `limit` 10;
  refuse `limit` greater than 50 — do not clamp). Backlinks:
  `ahrefs_backlinks_stats` is an overview only, not a full export.
- Search Console: `get_gsc_connection_status`, `gsc_list_sites`, then
  `gsc_query_analytics` (`site_url`, `start_date`, `end_date`)

These do not answer "which ads should I make more of."

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
