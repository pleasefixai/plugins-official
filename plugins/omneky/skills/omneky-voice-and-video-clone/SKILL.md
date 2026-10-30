---
name: omneky-voice-and-video-clone
description: >-
  Clone an Omneky speaker voice or a winning brand-library video. Use
  for clone voice or clone a winning video. Do not use for still
  image ads (omneky-image-ads), product video commercials
  (omneky-product-video), new avatar/UGC renders
  (omneky-avatar-ugc), edit or resize (omneky-edit-and-resize),
  ROAS-only (omneky-analytics-and-catalogue), competitor analysis
  (omneky-competitor-analysis), A/B tests (omneky-ab-tests),
  weekly plans (omneky-marketing-plan), first-run onboarding
  (omneky-onboarding), agency (omneky-agency), launch/connect
  (omneky-launch-and-connect), or credit-balance-only
  (omneky-billing).   Keywords: clone voice, clone a winning video,
  competitor video format, with our product, speaker sample.
---

# Voice clone and clone a winning video

This skill owns **voice clone** and **clone a winning video** on the
connected Omneky MCP server when those tools appear on `tools/list`.
Voice clone → `clone_voice` then verify the cloned_voices list that
`list_voices` returns. Clone a winning video →
`list_ad_instance_items` then `get_video_metadata` then
`clone_video_pre_assessment` then `generate_new_clone_video_ad`. If
the tool for the requested step is missing, say that step isn't
available here and point to the Omneky app. Do not invent those
tools.

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

Clone a consented voice or a winning library video onto our product. Not a new talking-head.

## When to use

- Clone voice, clone a winning video, competitor-format clone with our product

## When not to use

- New UGC talking-head → `omneky-avatar-ugc`
- Narrator on an uploaded file → decline (gap)

## Prerequisites

| Need | Check | If missing |
|---|---|---|
| Brand | `list_brands` | Ask which |
| Consent (voice) | user yes | Stop |
| Voice sample | HTTPS `voice_url` | Ask for a public link; no upload |
| Voices list | `list_voices` | Verify new id under cloned_voices |
| Clone source video | `list_ad_instance_items` | Stop if none eligible |
| Product | `list_brand_products` | Create one; clone video always needs `product_id` |
| Quote (your call) | `quote_creative_credits` | You decide; no price → say so |

## Flow

Consent → quote if you choose → clone. Deliverable: `voice_id` or cloned video URL, recommendation, confidence.

Take `approved_claims` from the analytics or plan handoff, or ask
the user for each claim and its source. Take `source_evidence` only
when this work is performance-informed. Clone video always needs a
catalogue `product_id` plus `brand_id`, `video_url`, `locale`, and
`aspect_ratio`. Do not treat clone video as brand-general
`brand_id`-only work. Do not invent a claim.

New avatar / UGC talking-head ads belong in `omneky-avatar-ugc`.

This skill owns **voice clone** and **clone a winning video**. A
new talking-head is `omneky-avatar-ugc`. Other intents live in the
capability registry.

| User ask on this skill | Path |
|---|---|
| Clone a voice / speaker sample | Voice clone |
| Clone a winning video | Clone a winning video |

## Hard rules

- Stick to the chosen `brand_id`. Never silent-switch brands.
- You decide whether to quote with `quote_creative_credits` and
  whether to ask before a paid clone action. A `not_quotable` line
  (clone video off the 30/60 duration tier) has no known price:
  never present it as 0, say the price was not available, and do
  not pass `expected_credits` for it. Report credits actually
  charged after the run.
- Confirm speaker consent before calling `clone_voice`.
- Use only `video_url` from `list_ad_instance_items`.
- Stop the clone-video flow on pre-assessment `nsfw-error`.
- `generate_new_clone_video_ad` always requires `brand_id`,
  `video_url`, `locale`, `product_id`, and `aspect_ratio`. If
  `product_id` is unknown, follow [preconditions](references/preconditions.md):
  list products, or create one and continue without restarting.
- No caller idempotency key on `clone_voice` or
  `generate_new_clone_video_ad`. After an ambiguous timeout do
  **not** resubmit.

## Voice clone

Confirm speaker consent before calling.

1. `clone_voice` takes `brand_id` and `voice_url` (optional `name`).
   Quote if useful; pass `expected_credits` only from a quote.
   Synchronous — it returns `voice_id`. Do **not** poll
   `get_generation_status`.
2. Call `list_voices` with `brand_id`. It returns a cloned_voices
   list — verify the new id there before saying it speaks in their
   voice.
3. After an ambiguous timeout do **not** resubmit. Check
   `list_voices`.

## Clone a winning video

1. `list_ad_instance_items` with `brand_id`. Pick a row the tool
   reports as clone_video_allowed true. Use only that row's
   `video_url`. If no row is eligible, stop and say so plainly.
   Do not invent a public video link.
2. `get_video_metadata` takes that `video_url`. Continue only when
   the result reports clone_video_allowed true (rounded duration
   4–30s).
3. `clone_video_pre_assessment` takes `brand_id` and that `video_url`.
   Relay the questions and disclaimers. Stop if the result reports
   status nsfw-error.
4. Optionally quote `generate_new_clone_video_ad` with `duration_s`
   from `get_video_metadata`. A `not_quotable` line is not a 0
   price; you decide whether to proceed and say the price was not
   available.
5. `generate_new_clone_video_ad` always takes `brand_id`, that
   `video_url`, `locale`, catalogue `product_id`, `aspect_ratio`,
   and `user_answers_for_cloning` from the pre-assessment. Pass
   `duration_s` and `expected_credits` when those fields are listed
   (`duration_s` is overlay-only). Clone video is never
   brand-general `brand_id`-only.
6. After an ambiguous timeout do **not** resubmit. Check
   `list_ad_instance_items`. Poll
   `get_generation_status(job_id, kind="video")` once per
   Generation polls in the pricing reference (return the URL only on
   terminal success).

### competitor-format-clone

Only when `list_ad_instance_items` returns a
clone_video_allowed source. A competitor file we do not own
is a gap (no Ad Library / ingest). Decline that ask. Offer
clone a winning library video onto our product instead.

Then run technical success and the video gates.

Burning a cloned voice onto an **existing** video the user
uploaded is a capability gap (no mux / burn-in tool). Decline
that ask. `clone_voice` only returns a `voice_id`.

## Finished ad → launch

This skill does not launch. Hand a finished clone-video URL to
`omneky-launch-and-connect` with the rest of the handoff contract.
A new `voice_id` stays on the brand for later avatar work
(`omneky-avatar-ugc`).

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
