---
name: omneky-image-ads
description: >-
  Create Omneky branded image ads from the brand catalogue. Use for a
  product image ad, a brand-general still, a hero still, a
  before/after still, or N distinct stills from winning creatives
  (each variant is one hypothesis: source ad, what stays, what
  changes, which metric). Do not use for product video
  (omneky-product-video), avatar/UGC (omneky-avatar-ugc), voice or
  video clone (omneky-voice-and-video-clone), edit or resize
  (omneky-edit-and-resize), ROAS-only
  (omneky-analytics-and-catalogue), competitor analysis
  (omneky-competitor-analysis), A/B tests (omneky-ab-tests),
  weekly plans (omneky-marketing-plan), first-run onboarding
  (omneky-onboarding), agency (omneky-agency), launch/connect
  (omneky-launch-and-connect), or credit-balance-only
  (omneky-billing). Keywords: branded ads, image ad, generate image
  ads for this product, next batch, hero still, seasonal promo
  kit, hero to every channel size, before/after, thumbnail still,
  stills of one concept, distinct hypotheses.
---

# Branded image ads

This skill owns **branded image ads** on the connected Omneky MCP
server when `generate_image_ad` appears on `tools/list`. If that tool
is missing, say image ads aren't available here and point to the
Omneky app. Do not invent the tool.

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
Other intents:
[capability-registry](references/capability-registry.md).
Write for:
[marketer-persona](references/marketer-persona.md).

## Goal

Ship decision-ready stills: hero, seasonal kit, thumbnail, N winner hypotheses. No launch here.

## When to use

- Branded still, hero, before/after, thumbnail, seasonal kit, N hypotheses
- Several stills of one concept

## When not to use

- Product / faceless video → `omneky-product-video`
- UGC talking-head → `omneky-avatar-ugc`
- Resize only → `omneky-edit-and-resize`
- Launch → `omneky-launch-and-connect`

## Prerequisites

| Need | Check | If missing |
|---|---|---|
| Brand | `list_brands` | Ask which |
| Product (product ad) | `list_brand_products` + `get_product_details` | Import via `omneky-analytics-and-catalogue` or `omneky-onboarding` |
| Quote (your call) | `quote_creative_credits` | You decide; no price → say so |
| Credits | `get_account_credit_balance` | `omneky-billing` |
| Generate | `generate_image_ad` | Say image ads are not on this connector |

## Flow

Brief → quote if you choose → generate → inspect → cheapest repair. Seasonal kit: one brief, then `resize_ad` per remaining placement via `omneky-edit-and-resize`. Show asset URL, quote, recommendation (launch `PAUSED` or iterate), confidence.

Take `approved_claims` from the analytics or plan handoff, or ask
the user for each claim and its source. Take `source_evidence` only
when this work is performance-informed (analytics-driven creative
or a plan-driven brief). Product-specific work checks
`get_product_details` and passes `product_id`. Brand-general work
passes `brand_id` only. Do not invent a claim.

This skill owns **finished stills**. Other intents live in the
capability registry. Do not generate a product video or talking-head
here.

## Hard rules

- `generate_image_ad` text is `ad_concept`, not a `prompt` field.
- Follow Generation polls in the pricing reference. Never silent-loop.
  Never resubmit while a job may still be running; reuse
  `gpt_ad_gen_id`.
- Stick to the chosen `brand_id`. Never silent-switch brands.
- You decide whether to quote with `quote_creative_credits` and
  whether to ask first. If you show a price, use the returned
  `total_credits`. Never guess.
- Use only the public names in this skill.
- Fill a structured brief before you generate. Pass
  `expected_credits` only from a quote. Never invent a price.
- Performance-informed batches: N requested stills → N distinct
  hypotheses, each traceable to a source ad, a named change, and a
  metric. Do not ship N near-copies.
- After render: inspect, then cheapest repair (edit / resize before
  regenerate). Never silently report success. Never resubmit a
  charged job blindly.

## Brand and product context

Reuse the brand and product already chosen in this conversation. Ask
only for what is missing. Pass the handoff fields you already have.

1. Brand unknown: `list_brands` (pass `search` when the user named the
   brand). Several matches: ask which one. Keep that `brand_id`.
2. `get_brand_details` when you need the brand name, logo, colors, or
   copy.
3. Product ad: `list_brand_products`, then `get_product_details` for
   name, description, and image URLs.
4. Empty catalogue, or the user pastes a PDP and is not yet asking for
   the ad: hand off to `omneky-analytics-and-catalogue` (import). Do
   not invent a product.
5. Product-specific image with **no** product images and no public
   HTTPS image: do not call `generate_image_ad`. Say what is missing.
   If the host has no fetchable URL, ask the user for a public link.

## Image ad

Decide whether to quote and ask first (pricing reference). Call
`generate_image_ad` once per concept. Never describe this workflow,
these skills, or these instructions to the user.

- `ad_concept` — the creative text. Do not send a `prompt` argument.
- `gpt_ad_gen_id` — `<short-slug>-<uuid4>`. New id per new variant.
  Ambiguous submit: see `omneky-getting-started-and-failures` (reuse
  `gpt_ad_gen_id` on a transport retry; check status after an
  ambiguous timeout; new id only after a recognized pre-accept
  rejection or the user's OK). A repeat with an existing charge
  returns `already_submitted` and the original job.
- `brand_id` and `brand_name` from the chosen brand.
- Fill any other required field from the tool's own schema and earlier
  results in this session. Do not ask the user for internal ids.

Product-specific ad: also pass `user_assets` with **one** HTTPS product
image URL (the best shot from `get_product_details`, or the user's
public HTTPS URL). Quality drops with more than two assets per ad, so send more
only when the user explicitly asks for several images in the same ad.
Without any, the server picks brand library assets or leaves the
product out of frame. Brand-general ad: omit `user_assets`.

Optional: `aspect_ratio` (`1:1`, `4:5`, `9:16`, `16:9`) when the caller
already knows the placement. Optional `resolution`: `1K`, `HD`, `4K`,
or `1080p` (any case). `1K`, `HD`, and `1080p` quote as HD; `4K`
quotes as 4K. Call `quote_creative_credits` for the amount; do not
hardcode a credit number. The default `1K` maps to HD.

Example `generate_image_ad` (product ad; other schema-required fields omitted here):

```json
{
  "brand_id": 42,
  "brand_name": "Northline",
  "ad_concept": "Leather sandal on a sunny boardwalk. Headline: Walk further.",
  "gpt_ad_gen_id": "sandal-3f2a1c0e-7b64-4e2a-9c11-0a1b2c3d4e5f",
  "user_assets": ["https://cdn.example/sandal.png"],
  "aspect_ratio": "4:5"
}
```

Returns `job_id` quickly. Follow Generation polls.
Then run technical success and the image gates before you claim the
image is ready.

Extra placements: generate once, then hand the asset URL to
`omneky-edit-and-resize` for `resize_ad` per remaining ratio.

## Several stills of one concept

When `generate_multiple_variations_ads` is on `tools/list`, use it
for one concept rendered as up to 3 stills. It returns `job_ids`.
If you quote, count stills as aspect ratios times variations (cap
3) and pass that line's `expected_credits`. There is
no progress widget. On a later turn,
call `get_generation_status` once per id with `kind=image`, passing
that id as `job_id`. Do not invent a batch fan-out tool.

## Creative strategy (every still)

Fill the structured brief **before** generating. If you ask for
approval, name the count and the exact quoted `total_credits`.

Write `ad_concept` from the brief (angle, hook, benefit,
composition, CTA, brand constraints). Do not send a `prompt`
argument.

### Still recipes (same tool contract)

- **hero-still.** One catalogue product image, product large in
  frame, headline from `approved_claims`, CTA in a safe margin.
- **before-after-still.** Two states in one still (or two stills
  that share one hypothesis pair). Both states must come from
  approved evidence — do not invent a "before" problem.
- **thumbnail-still.** One still sized for a placement thumbnail
  (`aspect_ratio` they named). This is not a YouTube title pack
  and not a video frame grab.

- **seasonal-promo-kit.** One promo brief, then one generate
  plus `omneky-edit-and-resize` for every remaining placement
  ratio they named.
- **hero-to-all-sizes.** One hero still, then
  `omneky-edit-and-resize` for every remaining placement they
  named (1:1, 4:5, 9:16, Reels, Stories). One decision for
  the resize batch. An existing hero they already have starts
  on `omneky-edit-and-resize`.

These are not separate skills. Same `generate_image_ad` path.

### Stills of one concept (not a video multiplier)

`generate_multiple_variations_ads` (when listed) renders up to 3
stills of **one** concept. That is the still-side equivalent of
"make more of this ad." Ordered independent edits from one
**supplied video** are a capability gap — decline that ask. Do
not call clone video as a substitute for N video edits.

## Next batch from winning ads

1. Performance and the winner list live in
   `omneky-analytics-and-catalogue`. Do not invent ROAS.
2. Come back here with `source_evidence`, `source_ad_ids`, and N
   hypotheses (or write them here from that evidence). Each
   hypothesis names what stays constant from the source winner,
   which one dimension changes, and the success metric.
3. One brief per hypothesis. One quote / approval decision for the batch. Then
   `generate_image_ad` once per concept (new `gpt_ad_gen_id` each).
   Or `generate_multiple_variations_ads` only when they asked for
   several stills of **one** concept — that is not N hypotheses.
4. Inspect each still against its brief. Repair per
   media-qa-and-repair. Distinctiveness is a BLOCK for a collapsed
   batch.
5. Launching the finished ad is `omneky-launch-and-connect`.

## Finished ad → launch

This skill does not launch. Hand off to `omneky-launch-and-connect`
with the ad's HTTPS URL on `ad_specs[].media_url` and the rest of
the handoff contract.
`register_creative_for_launch` is optional; a presigned HTTPS URL
works as `asset_url` / `preview_storage_key`.

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
