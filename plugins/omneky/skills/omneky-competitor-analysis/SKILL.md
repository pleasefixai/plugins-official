---
name: omneky-competitor-analysis
description: >-
  Analyze competitors and brand positioning with Omneky. Use for
  competitor analysis, positioning, messaging angles, messaging
  gaps, or a competitive brief that cites Semrush, Ahrefs, GSC,
  analyze_brand, or a scraped PDP. Every claim must cite its
  evidence source. Do not use for ROAS / winning-ads tables
  (omneky-analytics-and-catalogue), A/B tests (omneky-ab-tests),
  first-run onboarding (omneky-onboarding), agency
  (omneky-agency), weekly marketing plans
  (omneky-marketing-plan), generating creatives,
  launch/connect (omneky-launch-and-connect), or credit balance
  (omneky-billing). Keywords: competitor analysis, positioning,
  messaging angles, messaging gaps, competitive brief, GSC
  queries, keyword gaps, domain rating, backlinks, Semrush
  competitor, Ahrefs competitor.
---

# Competitor analysis

Use the connected Omneky MCP server. Gate every named tool on this
session's `tools/list`. If the tool for a requested step is missing,
say so and point to the Omneky app. Do not invent a tool or offer
another app or connector.

This skill owns **positioning, messaging angles, and gaps** that
feed a later creative brief. Paid-media ROAS tables stay in
`omneky-analytics-and-catalogue`. Weekly plans stay in
`omneky-marketing-plan`.

Handoff fields:
[handoff-contract](references/handoff-contract.md).
Sourced ids:
[preconditions](references/preconditions.md).
Acceptance gates (for a later creative):
[creative-quality-gates](references/creative-quality-gates.md).
Structured brief (output of this skill):
[creative-brief](references/creative-brief.md).
Other intents:
[capability-registry](references/capability-registry.md).
Write for:
[marketer-persona](references/marketer-persona.md).

## Goal

Cite positioning, keyword/query gaps, and domain-rating/backlink checks that feed a creative brief.

## When to use

- Competitor analysis, positioning, messaging gaps, GSC top queries as ad angles, Semrush/Ahrefs keyword gaps, domain rating / backlinks

## When not to use

- Paid ROAS tables → `omneky-analytics-and-catalogue`
- Meta Ad Library competitor ads → decline (gap)

## Prerequisites

| Need | Check | If missing |
|---|---|---|
| Brand | `list_brands` | Ask which |
| Analysis | `analyze_brand` | Call it |
| Semrush | `get_semrush_connection_status` | Skip Semrush |
| Ahrefs | `ahrefs_connection_status` | Skip Ahrefs |
| GSC | `get_gsc_connection_status` | Skip GSC |
| PDP copy | `identify_product_from_url` | Ask for one product URL |

## Flow

Status-gate each connector. Cite every claim. Lead with the
angles worth testing, then the gaps, then confidence per
source. Skip a disconnected source; do not ask them to reconnect
unless they want that source.

## Hard rules

- Stick to the chosen `brand_id`. Never silent-switch brands.
- Every claim cites `source` (tool name + entity + date or window).
  No source → do not write the claim.
- Gate Semrush / Ahrefs / GSC on that connector's status tool.
  Disconnected → skip that source and say so. Do not invent ranks
  or keywords.
- Reads need no approval. This skill does not generate or launch.
- Do not ask the user for internal ids.

## Path

1. Reuse the chosen `brand_id`. Unknown: `list_brands` (pass
   `search` when they named it). Several matches: ask which one.
2. `get_brand_details` when you need the brand site, name, or copy.
3. `analyze_brand` with `brand_id` (optional `website_url`, optional
   `product_id`). Draft only — no plan steps. Cite it as
   `analyze_brand`.
4. Own-site organic (each gated on status):
   - Semrush: `get_semrush_connection_status`, then
     `get_semrush_domain_overview` (`domain`) and/or
     `get_semrush_keyword_overview` (`keyword`).
   - Ahrefs: `ahrefs_connection_status`, then `ahrefs_domain_rating`
     (`target`), `ahrefs_organic_keywords` (default `limit` 10;
     refuse `limit` greater than 50), `ahrefs_backlinks_stats`
     (overview only).
   - Search Console: `get_gsc_connection_status`, `gsc_list_sites`,
     then `gsc_query_analytics` (`site_url`, `start_date`,
     `end_date`).
5. Competitor or own PDP they pasted: `identify_product_from_url`
   first. Listing/category → do not scrape; ask for one product
   URL. Then `scrape_product_from_url` when they want page copy
   cited. Finalize only if they asked to save the product
   (`omneky-analytics-and-catalogue`).
6. Write the brief feed. Each line is `{claim, source}`. Group as:
   - Positioning (who they are vs the cited competitor set)
   - Messaging angles (hooks / benefits that appear in the sources)
   - Gaps (what the sources do not support — say "not in sources",
     never invent a gap stat)

### gsc-queries-to-ad-angles

`get_gsc_connection_status` → `gsc_list_sites` →
`gsc_query_analytics`. Each query becomes an angle only when
the row exists. Cite the query + dates.

### keyword-gaps

Semrush `get_semrush_keyword_overview` / domain overview and
Ahrefs `ahrefs_organic_keywords` (limit ≤ 50). A gap is "in
their list, not in ours" only when both sides were fetched.
Otherwise say which side is missing.

### domain-rating-backlinks

`ahrefs_domain_rating` + `ahrefs_backlinks_stats` (overview
only). Not a full export. Not Meta Ad Library ads (gap).

Hand `approved_claims` and those angles to `omneky-image-ads`,
`omneky-product-video`, or `omneky-avatar-ugc` when they ask to
make the ad. Do not generate here.

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
