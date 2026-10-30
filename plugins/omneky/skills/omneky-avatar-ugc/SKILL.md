---
name: omneky-avatar-ugc
description: >-
  Create Omneky avatar and UGC talking-head video ads, including
  ugc-review (truthful claims only), ugc-unboxing (reveal arc),
  ugc-tutorial (demonstrable steps), and ugc-website-demo (accurate
  UI evidence). Use for an avatar video or talking-head ad. Do not
  use for still image ads (omneky-image-ads), product video
  commercials (omneky-product-video), voice or video clone
  (omneky-voice-and-video-clone), edit or resize
  (omneky-edit-and-resize), ROAS-only
  (omneky-analytics-and-catalogue), competitor analysis
  (omneky-competitor-analysis), A/B tests (omneky-ab-tests),
  weekly plans (omneky-marketing-plan), first-run onboarding
  (omneky-onboarding), agency (omneky-agency), launch/connect
  (omneky-launch-and-connect), or credit-balance-only
  (omneky-billing). Keywords: avatar video, UGC talking-head,
  talking-head ad, founder video, spokesperson, localized ad
  set, ugc-product, ugc-review, ugc-unboxing, ugc-tutorial,
  ugc-website-demo, testimonial avatar.
---

# Avatar and UGC talking-head ads

This skill owns **avatar / UGC talking-head ads** on the connected
Omneky MCP server when `list_avatar_filters`, `search_avatars`,
`list_voices`, and `generate_avatar_video_ad` appear on
`tools/list`. If the tool for the requested step is missing, say
that step isn't available here and point to the Omneky app. Do not
invent those tools.

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

Ship a talking-head: founder/spokesperson, localized voice, or a UGC genre. Custom faces allowed. Voice clone is a sibling skill.

## When to use

- Avatar / UGC / founder / spokesperson / localized talking-head / ugc-product / review / unboxing / tutorial / website-demo

## When not to use

- Clone a winning video → `omneky-voice-and-video-clone`
- Faceless product video → `omneky-product-video`
- Virtual try-on → decline (gap)

## Prerequisites

| Need | Check | If missing |
|---|---|---|
| Brand | `list_brands` | Ask which |
| Avatars | `list_avatar_filters` + `search_avatars` | Custom HTTPS face allowed |
| Voices / locale | `list_voices` | Omit `voice_id`, or `clone_voice` after consent in `omneky-voice-and-video-clone` |
| Product still | `get_product_details` | Omit `product_image_url`; quote `AVATAR_WITHOUT_PRODUCT_IMAGE` |
| Quote (your call) | `quote_creative_credits` | You decide; no price → say so |
| Generate | `generate_avatar_video_ad` | Say avatar video is not on this connector |

## Flow

Brief → quote if you choose → generate. Localized: pick `voice_id` from `list_voices` per language. Founder: custom face + a cloned voice when they asked. Deliverable: URL, spoken line, claims sources, confidence.

Take `approved_claims` from the analytics or plan handoff, or ask
the user for each claim and its source (including the approved
spoken line). Take `source_evidence` only when this work is
performance-informed. Product-specific avatar ads pass `product_id`;
brand-general work passes `brand_id` only. Do not invent a claim.

Voice cloning requires speaker consent. Custom face: not gated.
Custom faces are allowed as shipped. Do not refuse them. A
voice-clone request belongs in `omneky-voice-and-video-clone`.
Stock and custom portraits both work here.

This skill owns **avatar / UGC talking-head ads**, including the
genre recipes below. Clone voice or clone a winning video is
`omneky-voice-and-video-clone`. Other intents live in the
capability registry.

## Hard rules

- Stick to the chosen `brand_id`. Never silent-switch brands.
- You decide whether to quote with `quote_creative_credits` and
  whether to ask before a paid avatar action. Pass
  `expected_credits` only from a quote. Report credits actually
  charged after the run.
- Only pass URLs / portraits from `list_ad_instance_items` /
  `search_avatars` / the user's own brand assets. Do not invent a
  public video or portrait URL.
- `generate_avatar_video_ad` has no caller idempotency key. After an
  ambiguous timeout do **not** resubmit. Check
  `list_ad_instance_items`.
- Fill a structured brief before you generate.
- After render: inspect, then cheapest repair. There is no in-place
  audio edit — a wrong spoken line is a new generate (paid again). Never silently report success. Never resubmit a
  charged job blindly.
- Narrate long video jobs per Generation polls (queued / rendering
  / still rendering). Do not invent a pipeline stage the server
  did not report.

## Avatar video ad

1. `list_avatar_filters` when you need valid filter values.
2. `search_avatars` with `brand_id`, then `list_voices` with `brand_id`.
3. `generate_avatar_video_ad` takes `avatar_url` or `person_image_url`
   (a portrait from `search_avatars` or the user's brand assets). Custom
   faces are allowed. Pass `voice_id` from `list_voices` when the user
   wants a voice.
4. `generate_avatar_video_ad` takes `user_prompt` as the spoken line —
   keep it within about 30 seconds or Brief rejects it and no job starts.
5. If there is no product image, omit `product_image_url` and quote
   the `AVATAR_WITHOUT_PRODUCT_IMAGE` line — do not require a
   product image. When a still is available, pass it and quote the
   with-product line if you quote.
6. Check once with `get_generation_status(job_id, kind="video")`
   per Generation polls in the pricing reference (return the URL
   only on terminal success). State results plainly.

Then run technical success and the video gates.

## UGC genre recipes

Same tools as Avatar video ad. The execution contract is the
spoken line, the visual beats, and the QA bar. Pick the matching
recipe; do not open a second skill.

Write `user_prompt` from the brief. Keep it within about 30
seconds. Hook in the first 2 s unless a later reveal is recorded
as an accepted exception.

### ugc-product

A talking-head with the catalogue product in frame.

- Pass `product_id` and a product still when one exists
  (`product_image_url`). Quote the with-product line.
- Claims stay inside `approved_claims`. Product match is BLOCK.
- This is not a virtual try-on. A try-on / garment-on-body ask
  is a capability gap — decline it. Do not fake a fit.

### ugc-review (strict truthfulness)

A person on camera reviews the product.

- Every spoken and on-screen claim is in `approved_claims` with a
  source. No invented ratings, "best", medical, or savings lines.
- If a requested claim has no source, stop and ask. Do not generate.
- Product match is BLOCK. Identity stays one person.

### ugc-unboxing (reveal arc)

Hands or the speaker open or reveal the product.

- Beat 1 (0–2 s): hook without spoiling the product unless the
  approved concept shows it immediately.
- Beat 2: the reveal. Product visible by this beat, or record a
  later-reveal exception before you generate.
- Beat 3: one approved benefit + CTA.
- Do not show a different SKU than `product_id`.

### ugc-tutorial (demonstrable steps)

The speaker **does** the steps, not only talks about them.

- List 3–5 demonstrable steps in the brief. Each step is visible
  (hands, product, or result), not voiceover-only.
- Step order is the spoken order. Skip a step you cannot show;
  do not fake it.
- Claims stay inside `approved_claims`.

### ugc-website-demo (accurate UI evidence)

A talking-head plus a real product or site UI.

- UI evidence is a real HTTPS image or a catalogue / brand asset
  URL. Do not invent screens, metrics, or dashboard numbers.
- If you have no fetchable UI capture, say so and offer
  ugc-tutorial or a brand-general talking-head instead.
- Any on-screen figure is an `approved_claims` line.

### founder-spokesperson

Custom face allowed. A cloned `voice_id` from
`omneky-voice-and-video-clone` after speaker consent when they
asked for their voice. Claims stay inside `approved_claims`.

### localized-ad-set

`list_voices` per locale. One generate per language after one
batch quote and yes. Do not invent a translation of a regulated
claim.

### Testimonial avatar

Default talking-head: one approved line, one person, and a
product still when one exists. Custom faces are allowed. Voice
cloning still requires speaker consent in
`omneky-voice-and-video-clone`.

## Finished ad → launch

This skill does not launch. Hand off to `omneky-launch-and-connect`
with the video HTTPS URL on `ad_specs[].media_url` and the rest of
the handoff contract.

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
