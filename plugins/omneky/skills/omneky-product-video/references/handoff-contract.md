# Creative handoff contract

Reference for analytics, catalogue, marketing-plan, creative, and
launch skills. It lists what each step passes to the next. Use only
values you observed from the connected Omneky MCP server or the
user. Never invent a field. Never ask the user for internal ids;
reuse what earlier calls returned.

These fields are internal and agent-facing. Do not display the
handoff as raw JSON to the user. Show a concise plain-language
summary only (brand, product if any, asset, quote or maximum,
quality outcome, and the hypothesis when this work is
performance-informed).

## Fields

| Field | Source | Meaning |
|---|---|---|
| `brand_id`, brand name | any step | The one chosen brand. Never silently switch. |
| `product_id` | catalogue | Catalogue product when the work is product-specific. Omit for brand-general work (`brand_id` only). Clone video always needs a catalogue `product_id`. |
| `source_evidence` | analytics / plan | Required only for performance-informed workflows (analytics-driven creative or plan-driven launches). Omit for plain edits, resizes, and user-directed launches. |
| `approved_claims` | user / source | Claims the asset may make, each with its source (product page, user text). Anything else is unapproved. |
| placement | creative | Aspect (`1:1`, `4:5`, `9:16`, `16:9`) and channel placement. |
| `asset_url` | creative | The finished HTTPS URL. |
| dimensions, `duration_s` | creative | Observed from the fetched file, not the request. |
| approval | user | What was approved (if the host asked): items, count, quoted `total_credits` if any, credits charged, spend cap if any, status on launch. |
| receipt | creative | `job_id` and `gpt_ad_gen_id` where they exist, `expected_credits` passed, charged credits observed (or "not shown"), generation status. |
| `quality_result` | creative | Gates passed (observed), failed, not observed, and `accepted_exceptions` (overridden BLOCKs / accepted WARNs). |
| `creative_brief` | creative | Structured brief (`angle`, `hook`, `benefit`, `composition`, `evidence`, `cta`, `brand_constraints`, `placement`). See the creative-brief reference. |
| `hypothesis` | creative | Performance-informed only: source ad, what stays constant, what changes, audience / placement, success metric. |
| `source_ad_ids` | analytics | Winning ad or creative ids the brief came from. Required with `hypothesis`. |
| `repair_log` | creative | Failures, cheapest repair used, quote / approval pointer, and re-check outcome. Empty when no repair ran. |

Brand-general omit applies to `generate_image_ad` / `generate_product_video` / `generate_avatar_video_ad`. Clone video (`generate_new_clone_video_ad`) always needs a catalogue `product_id`.

The connected Omneky MCP server has no separate quote id. The quote
reference is the `quote_creative_credits` reply and its
`items[].expected_credits`. Sync edit and resize tools have no job
id — mark `job_id` on the receipt only where they exist.

## How each skill checks

- Analytics → creative. State `source_evidence` with the window and
  sample size. Pass `brand_id`, and `product_id` when the work is
  product-specific, plus the winning concept, `source_ad_ids`, and
  one `hypothesis` per requested variant. Creative checks a
  product-specific `product_id` exists (`get_product_details`) and
  that every claim in the copy is in `approved_claims`.
  Brand-general work on `generate_image_ad`,
  `generate_product_video`, and `generate_avatar_video_ad` passes
  `brand_id` only — do not require a catalogue import. Clone video
  (`generate_new_clone_video_ad`) always needs a catalogue `product_id`.
- Plan → creative / launch. Pass the approved plan scope and
  `source_evidence` from `analyze_brand` / the approved plan.
  Creative never exceeds the approved cap. A quote above the cap
  needs a new approval.
- User-directed creative (no analytics or plan). Pass `brand_id`,
  `product_id` only if product-specific, and `approved_claims`.
  Clone video still always needs `product_id`. Omit
  `source_evidence`.
- Plain edit or resize. Pass `brand_id`, the asset URL, and
  `approved_claims` for any new wording. Omit `source_evidence`.
- Creative → launch. Launch requires `asset_url` (loads), placement
  equal to the ad format, generation status terminal success on an
  async job (sync edit / resize use the sync reply; they have no
  `job_id`), `quality_result` with no failed BLOCK except those
  recorded in `accepted_exceptions`, and approval still covering
  this launch. Plan-driven launches also need `source_evidence`.
  User-directed launches do not. Launch puts `asset_url` on
  `ad_specs[].media_url` with the right media type, defaults to
  `PAUSED`, and shows one summary that includes the creative URL
  and the budget. Budget, dates, and status in the call must equal
  that approval.
- After launch. Read back the created ad (`get_ads`) and compare the
  creative URL, copy, status, and budget with the approval. Name any
  field that differs; do not claim live or paused as requested.

Reject the handoff and say what is missing when: the asset URL does
not load, the dimensions were not observed, a video's duration was
not observed (stills may leave `duration_s` unset), an async job is
not in terminal success (sync edit / resize use the sync reply), a
BLOCK gate failed or was not observed and is not in
`accepted_exceptions`, the claims are not approved, or the approval
does not cover the spend. Do not reject a brand-general image,
product-video, or avatar asset for a missing `product_id`. Reject a
clone-video handoff that is missing `product_id`. Do not reject a
plain edit, resize, or user-directed launch for missing
`source_evidence`.

## Example payload (internal / agent-facing)

Placeholders only. Keep this payload internal. Do not display it
as raw JSON to the user. Show a concise plain-language summary
instead.

```
{
  "brand_id": 111,
  "brand_name": "Example Brand",
  "product_id": "prod-222",
  "source_evidence": {
    "metric": "roas",
    "window": {
      "start": "2026-09-28",
      "end": "2026-10-04",
      "kind": "calendar_week"
    },
    "channel": "meta",
    "ad_ids": ["ad-333", "ad-334"],
    "sample": {"spend": 1840.0, "purchases": 61}
  },
  "approved_claims": [
    {"text": "Free returns for 30 days", "source": "product page"}
  ],
  "placement": {"channel": "meta", "aspect_ratio": "4:5"},
  "asset_url": "https://example.invalid/asset.png",
  "observed": {"width": 1080, "height": 1350, "duration_s": null},
  "approval": {
    "items": [{"action": "image_ad", "count": 1}],
    "quoted_total_credits": "<from quote_creative_credits>",
    "launch_cap_note": "daily budget as shown in the launch summary",
    "status_on_launch": "PAUSED"
  },
  "receipt": {
    "gpt_ad_gen_id": "<from submit>",
    "job_id": "<where it exists>",
    "expected_credits": "<from items[].expected_credits>",
    "charged_credits": "<observed or not shown>",
    "generation_status": "completed"
  },
  "quality_result": {
    "passed": ["headline legible", "logo intact"],
    "failed": [],
    "not_observed": ["audio"],
    "accepted_exceptions": []
  },
  "creative_brief": {
    "angle": "comfort for all-day wear",
    "hook": "Walk further.",
    "placement": {"channel": "meta", "aspect_ratio": "4:5"}
  },
  "hypothesis": {
    "source_ad_ids": ["ad-333"],
    "stays_constant": "offer and product",
    "changes": "headline hook",
    "metric": "ctr"
  },
  "repair_log": []
}
```

## A/B test plan

Record on create. Reuse on measure. Internal / agent-facing.

| Field | Meaning |
|---|---|
| `primary_metric` | One metric (CTR or CVR). |
| `baseline_rate` | From `get_daily_metrics` history, or a stated assumption. |
| `mde` | Precommitted minimum detectable effect (absolute rate). |
| `alpha` | Default 0.05. |
| `power` | Default 0.8. |
| `n_per_arm` | Required sample per arm from the two-proportion formula. |
| `randomization_unit` | Ad, ad-set, or user. Platform ad-level splits are not true user randomization unless platform A/B is used. |
| `attribution_window` | Named window used for the metric. |
| `horizon` | Precommitted end date or sample cap. |

Formulas live with the A/B skill when that skill is present.

## Analytics interpretation rules

Apply in the analytics skill before any recommendation.

- Minimum evidence: state the sample next to every conclusion
  (spend, impressions, clicks, purchases). With a small sample say
  "too little data to conclude" and show the numbers. Starting
  point: fewer than about 1,000 impressions, 30 clicks, or 10
  conversions per ad is thin (suggestions, not hard rules). Say
  when a ranking rests on thin data. Do not call a difference a
  win without comparable sample sizes.
- Attribution differs by channel: each channel counts conversions
  with its own window and model, so cross-channel ROAS is not
  directly comparable. Compare within a channel, or label
  cross-channel comparison approximate. Do not sum
  `selected_conversion_metric_value` across channels.
- Aggregate ratios: compute ROAS, CTR, CPA, CPC, conversion rate
  from summed numerators over summed denominators for the group,
  never the mean of per-row ratios.
- Windows: say which window you used. "This week" means the
  calendar week to date; use the last 7 days only when the user
  asks or for movers (`period_days`). A winner list with no dates
  uses the last 30 days, stated. Name dates as inclusive
  `YYYY-MM-DD`.
- Missing data is not zero: an empty result after
  `check_reporting_data_available` is missing coverage. Never
  report zeros for it.
