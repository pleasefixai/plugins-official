---
name: omneky-launch-and-connect
description: >-
  Launch Omneky paid-media campaigns and connect missing ad
  accounts (Meta/Facebook, Google, TikTok, LinkedIn, Reddit,
  Pinterest, X/Twitter, OpenAI Ads). Use to launch, publish,
  pause/budget/retarget, or connect an ads account. Do
  not use for first-run onboarding (omneky-onboarding), agency
  cross-brand (omneky-agency), ROAS analytics or catalogue
  (omneky-analytics-and-catalogue), competitor analysis
  (omneky-competitor-analysis), A/B tests (omneky-ab-tests),
  weekly marketing plans (omneky-marketing-plan), AI creative
  generation, or credit balance (omneky-billing).
  Keywords: launch Meta sales ads, launch campaign, Meta ads,
  Facebook ads, Google PMax, TikTok ads, LinkedIn ads, connect
  ads, pause ad, budget, targeting, twitter, paused, preflight,
  waste pruner pause, update ad targeting, apply target CPA
  budget, Demand Gen, TikTok locations, Pinterest campaigns.
---

# Launch paid ads and connect accounts

Use the connected Omneky MCP server. Gate on this session's
`tools/list`. Default new launches to `PAUSED`.
The X Ads channel value is `twitter`; the OpenAI Ads channel value is
`openai`.

If launch tools aren't available on this session's `tools/list`,
say so and point the user to the Omneky app. Do not invent them.

Handoff fields:
[handoff-contract](references/handoff-contract.md).
Sourced ids (how to obtain / what to do if absent):
[preconditions](references/preconditions.md).
Acceptance gates:
[creative-quality-gates](references/creative-quality-gates.md).
Other intents:
[capability-registry](references/capability-registry.md).
Write for:
[marketer-persona](references/marketer-persona.md).

## Goal

Launch or mutate paid media after one explicit yes. Default `PAUSED`. Apply budget, pause waste, and retarget only on approval.

## Prerequisites

| Need | Check | If missing |
|---|---|---|
| Brand | `list_brands` | Ask which |
| Channel | `get_channel_connection_status` | `get_channel_connect_url` → `list_authorized_ad_accounts` → `link_ad_channel_account` when listed. If `link_ad_channel_account` is not on `tools/list`, say that capability isn't available on this connector. Do not invent a link. Or managed launch |
| Budget floor | `minimum_budget_for_objective` | Do not launch under the floor |
| Audience size | `reach_estimate` | Optional; estimate only |
| Targeting tokens | `search_ad_targeting` / `get_tiktok_location_ids` / `search_google_countries` | Required on LinkedIn / TikTok / Demand Gen |
| Creative URL | any finished HTTPS asset URL (prior generate or user-supplied) | No URL at all → Owning creative skill first |
| Credits | `get_account_credit_balance` | `omneky-billing` |

## Flow

One summary (channel, daily spend, audience, asset, `PAUSED`) then wait for a yes. After: what launched, status, spend at risk, confidence. Do not list tool names in that summary.

Require `approved_claims` from the prior handoff or the user (each
claim with its source). Require `source_evidence` only for
performance-informed or plan-driven launches. User-directed
launches do not need it. Accept a finished asset whose
`quality_result` records `accepted_exceptions`. Do not invent a
claim or a missing asset URL. Show the user a concise
plain-language summary, not the raw handoff.

## When to use

- Launch a campaign, publish an ad, pause, budget, or retarget
- Connect a disconnected Meta, Google, TikTok, LinkedIn, Reddit,
  Pinterest, X Ads, or OpenAI Ads account

## When not to use

- First-run setup / first ad today / run it for me → `omneky-onboarding`
- Cross-brand / all clients → `omneky-agency`
- ROAS, winning ads, or catalogue import (analytics skill)
- Weekly marketing plan create / revise / poll / approve
- Branded image ads or product video ads (`omneky-image-ads` /
  `omneky-product-video`)
- Credit balance or plan upgrade (`omneky-billing`)

## Channel rules

Read **only** the reference for the channel you are launching. Do not
load the other eight. Channel budgets, required fields, and targeting
live there — not in this file.

| Channel | Read | Tools |
|---|---|---|
| Meta / Facebook | [references/facebook.md](references/facebook.md) | `launch_facebook_sales_ad`, `launch_facebook_leads_ad`, `launch_facebook_awareness_ad`, `launch_facebook_traffic_ad`, `launch_facebook_video_views_ad` |
| Google | [references/google.md](references/google.md) | `launch_google_performance_max_ad`, `launch_google_demand_gen_ad` |
| LinkedIn | [references/linkedin.md](references/linkedin.md) | `launch_linkedin_brand_awareness_ad`, `launch_linkedin_website_visits_ad`, `launch_linkedin_conversions_ad`, `launch_linkedin_engagement_ad` |
| Reddit | [references/reddit.md](references/reddit.md) | `launch_reddit_awareness_ad`, `launch_reddit_traffic_ad`, `launch_reddit_conversions_ad`, `launch_reddit_leads_ad`, `launch_reddit_video_views_ad` |
| TikTok | [references/tiktok.md](references/tiktok.md) | `launch_tiktok_traffic_ad`, `launch_tiktok_leads_ad`, `launch_tiktok_video_views_ad`, `launch_tiktok_conversions_ad` |
| X Ads | [references/twitter.md](references/twitter.md) | `launch_twitter_awareness_ad`, `launch_twitter_traffic_ad`, `launch_twitter_engagements_ad`, `launch_twitter_followers_ad`, `launch_twitter_video_views_ad` |
| Pinterest | [references/pinterest.md](references/pinterest.md) | `launch_pinterest_awareness_ad`, `launch_pinterest_traffic_ad`, `launch_pinterest_sales_ad`, `launch_pinterest_leads_ad`, `launch_pinterest_video_views_ad` |
| OpenAI Ads | [references/openai.md](references/openai.md) | `launch_openai_clicks_ad`, `launch_openai_impressions_ad` (`openai_location_search` optional; details in that file) |
| Managed (no ad account) | [references/managed.md](references/managed.md) | `launch_omneky_managed_meta_ad`, `launch_omneky_managed_openai_ad` |

Every allowlisted `launch_*` tool is named above. Do not call a
wildcard or an unlisted sibling.

## Launch path

Pick one branch before any `launch_*` call.

**paused-campaign-from-winners.** Incoming handoff from analytics +
creative must include accepted `asset_url`s, `source_evidence`, and
`source_ad_ids`. Default `PAUSED`. One summary, one yes. Do not go
live unless they say so in that yes.

An A/B test with a recorded plan (hypothesis, metric, duration,
stop rule) is `omneky-ab-tests`. A budget-reallocation
**recommendation** is `omneky-analytics-and-catalogue`. Applying
`set_ad_budget` after that recommendation still needs one yes
here.

**waste-pruner (apply).** Incoming pause list from analytics.
One summary naming each entity. `set_ad_entity_status` only
after that yes.

**audience-targeting-apply.** Incoming tokens from
`search_ad_targeting`. `update_ad_targeting` only after a yes.

**target-cpa-budget-apply.** Incoming floor from
`minimum_budget_for_objective` / `reach_estimate`. `set_ad_budget`
only after a yes, at or above the floor.

### Managed launch

`launch_omneky_managed_meta_ad` or `launch_omneky_managed_openai_ad`
when the brand has no connected Meta / OpenAI Ads account, or the
user asks for managed. Read
[references/managed.md](references/managed.md). Skip Connect and the
disconnected-account preflight — these tools work without a linked
advertiser account. Still: budget floor, copy / CTA / hosted-landing
rules, credits, one summary, one yes, default `PAUSED`. Then Launch
checks.

### Self-managed launch

Every other `launch_*`. Full Preflight below. Disconnected →
Connect, do not launch.

## Preflight (self-managed)

Work through this checklist with tool calls before a self-managed
`launch_*` call. Reuse answers the user already gave; ask only for
what is still missing (usually copy, landing URL, budget, and
audience). Then show **one** launch summary — channel, tool, account,
campaign / ad set (new or existing), budget, audience, copy, CTA,
landing URL, creative, and status — and get one yes. Do not ask for
a separate confirmation per item. Do not call `launch_*` until that
yes. Budget, dates, and status in the call must equal the approval;
if any differ, stop and re-summarize.

Status: set `campaign_spec.status_on_launch` to `"PAUSED"` on
`launch_*` tools (top-level `status_on_launch` on
`launch_omneky_managed_*`). A non-paused launch needs an explicit yes to
go live in that same summary.

Hierarchy is Campaign → Ad Set (`ad_group`) → Ad. The creative is an
asset on the Ad (`ad_specs`), never on the campaign.

1. **Objective.** Name the channel and the exact `launch_*` tool from
   the table. Read that channel's reference. Do not guess a sibling
   objective.
2. **Connected account (self-managed only).**
   `get_channel_connection_status` (X Ads: `channel="twitter"`).
   Pinterest also: `get_pinterest_connection_status`. Disconnected →
   Connect below. Do not launch.
3. **Budget.** `minimum_budget_for_objective` with `brand_id`, channel,
   and objective. Do not set a daily or lifetime budget under that
   floor. `get_channel_budget` is allocated daily budget, not spend,
   not the floor, and not historical ROAS. A disconnected channel is a
   per-channel error, not an empty total.
4. **Targeting.** The channel pre-call in that reference. Do not launch
   LinkedIn or TikTok without it (the API returns 400).
5. **Copy, CTA, and landing URL.** Use what the user gave. Do not
   invent a destination. Meta leads also need `lead_gen_form_id` on
   the ad spec.
6. **Existing campaign or ad set.** `get_campaigns`, then
   `get_ad_groups` with `campaign_id` (unscoped lists can timeout).
   Add under an existing campaign: `campaign_spec={"id": "<campaign_id>"}`.
   Add into an existing ad set: `ad_group_spec={"id": "<ad_set_id>"}`
   and set `adset_id` on each ad spec.
7. **Audience size.** `reach_estimate` with `brand_id`, `channel`, and
   `targeting_fragments` when the user asks how large the audience is.
   That is an estimate, not live delivery or ROAS.
8. **Custom conversions.** `get_ad_custom_properties` when the launch needs
   a brand conversion event. Not a performance report.
9. **Credits.** Launch creates need available Omneky credits; the
   server checks this. `credit_insufficient` means the launch did
   **not** start. Do not retry it. Tell the user the shortfall and offer
   the choices: upgrade the plan or stop. Hand off to `omneky-billing`
   only if they choose to upgrade. Never collect a PAN. Never invent a
   credit purchase tool.

## Targeting pre-calls

Meta and Reddit take inline targeting (see those references). X Ads
uses `channel="twitter"`. Pinterest checks
`get_pinterest_connection_status` and uses inline countries. The three
lookups below are required before launch.

**TikTok.** Before any `launch_tiktok_*`: `get_tiktok_location_ids`
with `brand_id` and required `campaign_objective`. Put the returned
ids on the ad group as `location_ids`. Without them the API returns
400. Details: [references/tiktok.md](references/tiktok.md).

**LinkedIn.** Before any `launch_linkedin_*`: `search_ad_targeting`
with `brand_id`, `channel="linkedin"`, `types=["locations"]`. Copy a
hit whose value includes `urn:li:adTargetingFacet:locations` into
`targeting_criteria`. A new campaign group also needs `start_date`.
Details: [references/linkedin.md](references/linkedin.md).

**Google Demand Gen vs PMax.** Demand Gen is one image or video on
YouTube or Discover — `search_google_countries`, then
`targeting_fragments`. PMax is the full multi-placement asset suite
(no country lookup). Details: [references/google.md](references/google.md).

`register_creative_for_launch` is optional (Ad Central library). Pass
`asset_url` or `preview_storage_key` as the finished HTTPS URL
(`presigned_url` / `assets.url`); the server copies it. Launch itself
takes `ad_specs[].media_url`. Use `search_ad_targeting` for LinkedIn /
optional X Ads location lookup.

## Creative → launch (short)

Generation stays in the matching creative skill (`omneky-image-ads`,
`omneky-product-video`, `omneky-avatar-ugc`,
`omneky-voice-and-video-clone`, or `omneky-edit-and-resize`). This
skill starts once the user
has a finished Omneky ad and wants it on a paid-media channel.

1. The launch summary covers the creative URL too; one yes is enough.
2. Put the finished HTTPS URL (`presigned_url` / `resized_ad_url` /
   `assets.url`) on `ad_specs[].media_url` with `media_type`. Published
   copy fields (`headline`, `primary_text`, `cta`, `landing_url`) are
   mapped to the launcher names. Google Performance Max: `ad_specs: []`
   and put images / `link_url` / headlines (≥3) / descriptions (≥2) on
   `ad_group_spec`. Square and logo images are required and must not
   reuse the landscape ad image.
   `register_creative_for_launch` is optional (library). Pass
   `asset_url` or `preview_storage_key` as that same HTTPS URL if the
   user wants it saved. Do not stop for a missing storage key.
3. Run the matching Launch path (managed or self-managed Preflight),
   then the matching `launch_*` from the table. Keep the launch
   `PAUSED` unless the user explicitly says to go live. Then run
   Launch checks.

## Manage (short)

`get_campaigns` (each row is name with campaign id) /
`get_ad_groups` (pass `campaign_id`) / `get_ads`. A disconnected or
skipped channel returns an explicit error, not an empty-looking list.
`set_ad_entity_status` (pause or resume), `set_ad_budget`,
`update_ad_targeting`, `set_pinterest_entity_status`.

Before any of those mutate tools, show one summary and wait for an
explicit yes. The summary names the entity (name and id), the
channel, the current value, the new value, and that the change
affects live spend. One yes covers the batch; do not confirm each
item separately.

Name the user said, ids only: `get_campaign_ad_group_names`. Not a
status or budget list.

Pinterest lists: `get_pinterest_campaigns`, `get_pinterest_ad_groups`
(pass `campaign_id`), `get_pinterest_ads`. Pause or resume with
`set_pinterest_entity_status` (same one-summary / one-yes rule).

`needs_user_decision` → hand off to
`omneky-getting-started-and-failures` (`request_user_decision`). Do not dump raw
JSON.

**Deletes.** `delete_campaign`, `delete_ad_group`, and `delete_ads`
are irreversible. Prefer pause (`set_ad_entity_status`) when the user
only wants a stop.

1. Resolve ids first: `get_campaigns`, `get_ad_groups` (pass
   `campaign_id`), `get_ads`. Do not delete from a name alone.
2. In chat, name exactly what will be removed: channel, entity type,
   name, and id. Say it cannot be undone.
3. Wait for an explicit yes that repeats that entity (for example
   "yes, delete campaign 123"). A vague "ok", or a yes to a different
   question, is not confirmation. Do not call the delete until that
   yes. If they say no, stop.
4. Then call one tool:
   - `delete_campaign` — `brand_id`, `channel`, `campaign_id`
   - `delete_ad_group` — `brand_id`, `channel`, `ad_group_id`
   - `delete_ads` — `brand_id`, `channel`, `ad_ids` (list of ids)

## Connect (short)

Paid-media self-connect for the chosen brand. OAuth wire values:
`facebook`, `google`, `linkedin`, `tiktok`, `reddit`, `twitter`,
`pinterest`. X Ads is `twitter`, never `x`. OAuth channels never need a
token or password in chat — do not ask for one.

Call `link_ad_channel_account` only when it appears on this
session's `tools/list`. If it is not listed, say that capability
isn't available on this connector. Do not invent a link.

1. `get_channel_connect_url` with `channel` and `brand_id`. Omit
   `redirect_url` unless its host is `omneky.com`. Hand the user
   `connect_url` (or `browser_connect_url`). `next_action` is
   `open_connect_url`. They finish the provider consent screen.
2. **OAuth not finished.** If they have not completed consent, or
   `list_authorized_ad_accounts` is empty or errors, do not link and
   do not launch. Send the same URL again. Do not collect a token.
3. After they confirm consent: `list_authorized_ad_accounts` with
   `brand_id` and `channel`. Several accounts: ask which `id` / name.
   Do not pick silently.
4. Meta / Facebook pages: also `list_authorized_facebook_pages` with
   `brand_id`. When `link_ad_channel_account` is on `tools/list`, it
   needs `facebook_page_id` plus `channel_account_id` and
   `channel_account_name`. If `link_ad_channel_account` is not on
   `tools/list`, say that capability isn't available on this
   connector. Do not invent a link.
5. Other channels: when `link_ad_channel_account` is on `tools/list`,
   call it with `brand_id`, `channel`, `channel_account_id`, and
   `channel_account_name`. If it is not listed, say that capability
   isn't available on this connector. Do not invent a link.
6. Confirm with `list_connector_statuses` and
   `get_channel_connection_status`. Still disconnected: stop and say
   so. Do not launch.

**OpenAI Ads** has no OAuth URL. Status:
`get_openai_ads_connection_status` (or `get_channel_connection_status`
with `channel="openai"`). Connect: `connect_openai_ads` takes the
brand's OpenAI Ads `api_key`. Use it only when the user chooses to
connect that way and supplies the key; pass the key to that tool only,
never repeat it, and never ask for it unprompted (the user can also
connect it in the Omneky app). Launching on OpenAI Ads is supported:
connected accounts use `launch_openai_clicks_ad` /
`launch_openai_impressions_ad`; brands without an account can use
`launch_omneky_managed_openai_ad` (see [references/openai.md](references/openai.md)
and [references/managed.md](references/managed.md)).

**PostHog:** `connect_posthog` takes an `api_key`, `host`, and
`project_id`; same key rule as OpenAI Ads. Then
`get_posthog_connection_status` (host and project id, never the key).
`disconnect_posthog` only after an explicit yes. Drive:
`get_google_drive_connection_status`, then
`get_google_drive_connect_url` if it is disconnected.
`disconnect_google_drive` only after an explicit yes. No Pinterest or
X Ads disconnect tool on this surface.

X Ads pause is `set_ad_entity_status` at **campaign** level only.
Pinterest launches are supported (`launch_pinterest_*`).

Connected OpenAI Ads launches use `launch_openai_*`. OpenAI targeting
stays on `campaign_spec.targeting`. Unconnected Meta / OpenAI use
`launch_omneky_managed_*`. Connecting an account is a separate step
from launching.

## Launch checks

Observe the launch reply or one cheap get_* read-back. Request
arguments never prove saved campaign configuration.

Reply or read-back already shows the fact → say it plainly (e.g.
"done"). Do not hedge. Missing detail → **one** get_* call. If it
is still not confirmed, say so in one short plain sentence (e.g.
"I couldn't confirm the saved budget").

- Campaign / ad-set / ad ids — launch reply, then `get_campaigns` /
  `get_ad_groups` / `get_ads` (Pinterest: `get_pinterest_*`)
- Status equals the approval (`PAUSED` unless they said go live) —
  same reply or a get_* read-back, not request `status_on_launch`
- Budget and dates — created entity via get_*. Request args never
  prove the save
- Channel and `launch_*` tool — the tool that ran plus the entity's
  channel field
- Creative URL and copy on the created ad — `get_ads` (or
  launch-reply ad fields). Request `ad_specs` never prove the save

If a check fails: say which field differed. Do not claim live or
paused as requested. Do not silently relaunch.

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
