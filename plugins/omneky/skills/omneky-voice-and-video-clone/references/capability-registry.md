# Capability registry

One routing table for this skill pack. Do not keep a second
copy of this table inside a skill. Each skill states what it owns
and links here for everything else.

Use the connected Omneky MCP server. Gate every named tool on this
session's `tools/list`. Missing tools → Omneky app. Do not invent a
tool or offer another app or connector.

Genre recipes that share a tool contract live inside the owning
skill. Native skills exist only when the execution contract
differs (first-run onboarding; agency multi-brand; competitor
analysis; A/B create / measure).

## Intent → skill

| User ask / preset | Owning skill | Finished deliverable |
|---|---|---|
| Sign-in, OAuth, unknown brand, unauthorized, timeout, `credit_insufficient`, `needs_user_decision` | `omneky-getting-started-and-failures` | Session context recovered, or a named next skill |
| Named preset menu / "what can you do" | `omneky-getting-started-and-failures` | Preset list with one-liners |
| Brand setup from a website, first ad today, managed run-it-for-me | `omneky-onboarding` | Brand + product + quoted first ad, `PAUSED` or managed |
| Winning ads, ROAS, CTR, movers, "which ads should I make more of" | `omneky-analytics-and-catalogue` | Ranked evidence + `source_evidence` (no render) |
| Weekly performance report (one brand) | `omneky-analytics-and-catalogue` | Windowed readout (coverage, winners, movers) |
| ROAS / CPA drop diagnosis | `omneky-analytics-and-catalogue` | Evidence memo (movers, breakdown, daily) |
| Waste-pruner / targeting / target-CPA evidence | `omneky-analytics-and-catalogue` then `omneky-launch-and-connect` | Recommendation; apply only after a yes |
| Budget reallocation recommendation (read-only) | `omneky-analytics-and-catalogue` then `omneky-launch-and-connect` | Recommendation; apply only after a yes |
| Fatigue refresh / top-ROAS variations (evidence first) | `omneky-analytics-and-catalogue` then the matching creative skill | Winner list + N hypotheses |
| List / import products, PDP, SKU, catalogue | `omneky-analytics-and-catalogue` | Catalogue record (`product_id`) |
| HubSpot attribution / ABM brief; raw Semrush / Ahrefs / GSC reads | `omneky-analytics-and-catalogue` | Connector read with join-limit caveats |
| Competitor analysis, positioning, messaging gaps, keyword / GSC angles, domain-rating | `omneky-competitor-analysis` | Cited brief feed (every claim has a source) |
| A/B test create or measure | `omneky-ab-tests` | Test plan, or a readout that may refuse a winner |
| Branded still, image ad, hero still, before/after, thumbnail still, seasonal kit | `omneky-image-ads` | Finished still(s) + brief + provenance |
| One hero to every channel size (generate then resize) | `omneky-image-ads` then `omneky-edit-and-resize` | Placement set |
| Several stills of one concept | `omneky-image-ads` (`generate_multiple_variations_ads` when listed) | Up to 3 stills, one concept |
| Product / launch / explainer / professional / faceless video | `omneky-product-video` | Finished video + narrative / job ids |
| Revise / re-pick a product-video story | `omneky-product-video` | New cards or a new generate |
| Avatar / UGC / founder / spokesperson / localized talking-head | `omneky-avatar-ugc` | Talking-head video |
| UGC review / unboxing / tutorial / website-demo | `omneky-avatar-ugc` | Genre video; claims only from `approved_claims` |
| Clone voice / speaker sample | `omneky-voice-and-video-clone` | New `voice_id` under cloned_voices |
| Clone a winning / library video onto our product | `omneky-voice-and-video-clone` | Cloned video (catalogue `product_id` required) |
| Edit a finished still, exact headline fix | `omneky-edit-and-resize` | Edited still |
| Resize / Reels / Stories / 1:1 / 4:5 / 9:16 / existing hero to all sizes | `omneky-edit-and-resize` | Placement still |
| Launch, pause, budget apply, targeting apply, connect an ad account | `omneky-launch-and-connect` | Campaign / ad in `PAUSED` unless they said go live |
| Paused campaign from winners | `omneky-analytics-and-catalogue` then `omneky-launch-and-connect` | `PAUSED` launch from winning assets |
| Weekly marketing plan / make me a plan | `omneky-marketing-plan` | Draft plan + preview checklist |
| Weekly cross-brand report / multi-brand rollout | `omneky-agency` | Per-client cards or per-brand confirmation (no silent switch) |
| How many ad credits / quote context / upgrade / credit-history audit | `omneky-billing` | Balance, Stripe URL, or dated ledger (never a PAN) |

## Negative routing (do not steal)

| If they asked for | Do not open |
|---|---|
| First-run setup / first ad today / run it for me | a later healthy analytics or creative skill |
| A render ("make the ad", "generate the still") | `omneky-analytics-and-catalogue` (evidence only) |
| ROAS / winners only (no generate) | any creative skill |
| One-brand weekly report | `omneky-agency` |
| Cross-brand / all clients | `omneky-analytics-and-catalogue` |
| Competitor positioning / messaging gaps / keyword angles | `omneky-analytics-and-catalogue` (raw connector reads only) |
| A/B test create or "which variant won" | `omneky-analytics-and-catalogue` or `omneky-launch-and-connect` |
| Product video / commercial / faceless product video | `omneky-image-ads` or `omneky-avatar-ugc` |
| Avatar / UGC talking-head / founder / localized | `omneky-product-video` or `omneky-image-ads` |
| Clone voice or clone a winning library video | `omneky-avatar-ugc` (new talking-head is not a clone) |
| Brand-new concept | `omneky-edit-and-resize` |
| Weekly plan create / revise / preview | `omneky-getting-started-and-failures` or analytics |
| Live spend / go-live / pause apply / budget apply | any creative skill (launch owns it, default `PAUSED`) |
| Credit balance / upgrade / credit-history audit | analytics or creative |
| Sign-in / unauthorized / empty brand | a healthy in-domain skill |

## Shared contracts (Layer 2)

Every skill already keeps its safety rules in its own `SKILL.md`.
Read the matching contract when the step needs it:

- Brief: [creative-brief](creative-brief.md)
- QA + cheapest repair: [media-qa-and-repair](media-qa-and-repair.md)
- Gates: [creative-quality-gates](creative-quality-gates.md)
- Quote / retry / polls / progress: [creative-pricing-and-polling](creative-pricing-and-polling.md)
- Handoff + provenance: [handoff-contract](handoff-contract.md)
- Sourced ids: [preconditions](preconditions.md)
- Declines: [capability-gaps](capability-gaps.md)
- How to write every reply: [marketer-persona](marketer-persona.md)

## Named presets (discovery)

Getting-started lists these with one-liners. Opening a preset still
routes through the owning skill above.

| Preset | One-liner |
|---|---|
| `brand-setup-from-website` | Analyse the site, import products, stay on that brand. |
| `first-ad-today` | URL → brief → quote → `PAUSED` launch. |
| `managed-run-it-for-me` | Omneky-managed Meta / OpenAI when they have no ad account. |
| `winners-this-week` | This week's top ROAS ads (calendar week to date). |
| `weekly-performance-report` | Coverage, winners, and movers for the stated window. |
| `roas-cpa-drop` | Movers + breakdown + daily; what to pause or scale. |
| `waste-pruner` | Underperformers; pause only after a yes. |
| `audience-targeting` | Breakdowns + `search_ad_targeting`; apply only after a yes. |
| `target-cpa-budget` | Floor from `minimum_budget_for_objective` / `reach_estimate`. |
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
| `hero-to-all-sizes` | One hero, then every remaining placement size. |
| `seasonal-promo-kit` | One promo brief across the placements they named. |
| `before-after-still` | Two-state still; both states from approved evidence. |
| `thumbnail-still` | One still for a placement thumbnail (not a YouTube pack). |
| `stills-of-one-concept` | Up to 3 stills of one concept when that tool is listed. |
| `product-video-story` | Pick a narrative card, then generate. |
| `product-launch-video` | Launch / explainer product video from catalogue stills. |
| `faceless-product-video` | Product / professional video with no talking head. |
| `generate-now-video` | Skip the card list only when they say so. |
| `founder-spokesperson` | Talking-head; custom face allowed; cloned voice optional. |
| `localized-ad-set` | One talking-head per locale via `list_voices`. |
| `clone-winning-format` | Clone a library video onto our product (not a public file). |
| `paused-campaign-from-winners` | Launch winners `PAUSED` after one yes. |
| `competitor-analysis` | Cited positioning, angles, and gaps. |
| `gsc-queries-to-ad-angles` | Search Console queries → cited ad angles. |
| `keyword-gaps` | Semrush / Ahrefs gaps, both sides fetched. |
| `domain-rating-backlinks` | Ahrefs rating + backlink overview (not Ad Library). |
| `hubspot-attribution` | Campaign/deal labels side by side; inferred, not attributed. |
| `abm-from-hubspot` | Cited firmographic lines into a creative brief. |
| `ab-test-create` | One hypothesis, one variable, `PAUSED`, precommitted plan. |
| `ab-test-measure` | z-test + CI + power; setup check every look; Invalid immediately on fail; INTERIM peek otherwise; SRM → Invalid only on a randomized planned split; auction imbalance is a caveat; refuse a thin winner. |
| `weekly-marketing-plan` | Goal → analyze → create → revise → preview; host runs steps. |
| `weekly-cross-brand-report` | Per-client cards; no silent brand switch. |
| `multi-brand-rollout` | One brand per yes; never silent-switch. |
| `credits-and-cost` | Balance then `quote_creative_credits`. |
| `upgrade-top-up` | `list_available_plans` → `start_plan_upgrade` or portal. |
| `credit-history-audit` | Ledger via `get_credit_history`. |

## Capability gaps (decline cleanly)

These asks have no matching public tool. Say the connector cannot
do that, name the missing capability, and offer the nearest real
flow when one exists. Do not substitute a different tool and call
it done. Full table:
[capability-gaps](capability-gaps.md).

| User ask | Decline | Nearest real flow | Server tool that would be needed |
|---|---|---|---|
| Comment / social inbox (reply to comments, DMs) | Yes | None | An inbox / comment-moderation tool |
| Landing-page builder | Yes | None | A landing-page / site-builder tool |
| Subtitles / caption burn-in on a video | Yes | None. Uncaptioned is not a captions failure | A subtitle / burn-in tool |
| Email / SMS campaigns | Yes | None | An email / SMS send tool |
| Organic social scheduling | Yes | Paid `launch_*` only | An organic scheduler |
| Meta Ad Library competitor ads | Yes | Cited Semrush / Ahrefs / GSC / `analyze_brand` | An Ad Library scrape tool |
| Virtual try-on / garment on a body | Yes | `ugc-product` talking-head with a catalogue still | A try-on / garment tool |
| Website or landing-page builder | Yes | None | A site-builder tool |
| Ordered independent edits from one supplied video | Yes | `stills-of-one-concept` or clone one winning library video | A video-variant / ad-multiplier tool |
| Motion / hero-spin / product animation | Yes | None. Do not send it to `generate_product_video` | A product-animation generate tool (not on this surface) |
| Trim / cut / color / `edit_video` | Yes | Still edit via `edit_image`. Video: new generate | An `edit_video` tool |
| Narrator burned onto an existing video | Yes | `clone_voice` for a new `voice_id`, or a new professional / product video with VO | A mux / burn-in-voice tool |
| YouTube title / description / chapters pack | Yes | Product-video narrative cards (title / hook / duration) | A YouTube-script packager |
| File upload / ingest bytes | Yes | Public HTTPS URL only | Held; no `ingest_media` |
