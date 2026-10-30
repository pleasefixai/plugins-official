# Structured creative brief

Shared contract for image ads, product video, and avatar / UGC. Fill
this brief **before** you quote or generate. Gate every named tool on
this session's `tools/list`. Do not invent a tool, a claim, or a
price.

These fields are internal and agent-facing. Show the user a concise
plain-language summary (angle, what stays, what changes, placement,
and the success metric). Do not dump this as raw JSON.

## Required fields

| Field | Meaning |
|---|---|
| `angle` | The one idea the asset sells. One sentence. |
| `hook` | First thing the viewer sees or hears (still: headline; video: first 2 s). |
| `benefit` | What the viewer gets. Must come from `approved_claims` or the product page. |
| `composition` | Subject, crop, background, and text hierarchy (headline / support / CTA). |
| `evidence` | Why this brief exists: user request, or `source_evidence` from analytics. |
| `cta` | The call to action, if any. Skip when the brief has none. |
| `brand_constraints` | Logo, colors, and claims that must stay true to the chosen `brand_id`. |
| `placement` | Channel plus aspect (`1:1`, `4:5`, `9:16`, `16:9`) and any safe-zone note. |
| `hypothesis` | Required for every performance-informed variant. See below. |

Skip a field only when it does not apply (brand-general work has no
product benefit; an uncaptioned still has no spoken hook). A skipped
field is not a failure.

## Hypothesis (performance-informed variants)

When the user asks for N ads from winners, write **N distinct
hypotheses**. Each variant is one brief. Do not make N near-copies
of the same winner.

Each hypothesis states:

1. **Source.** The winning ad or creative id from
   `get_performance_breakdown` / `get_performance_movers` (never
   invented). Include the window and sample from `source_evidence`.
2. **What stays constant.** The winning angle, offer, product, or
   proof that the next asset keeps.
3. **What changes.** Exactly one primary dimension: hook, benefit
   wording, composition, placement, identity (avatar vs still), or
   CTA. Name it.
4. **Audience / placement.** Who sees it and where (feed, Stories,
   Reels, search).
5. **Success metric.** The one number you will judge (CTR, ROAS,
   CPC, hook-through). Do not invent a lift endpoint.

If the winner sample is thin (handoff contract: fewer than about
1,000 impressions, 30 clicks, or 10 conversions), say so on the
brief and treat the variant as exploratory.

## How to fill

1. Brand and product from the conversation. Product-specific work
   reads `get_product_details` and passes `product_id`. Brand-general
   work passes `brand_id` only.
2. Claims: take `approved_claims` from the analytics or plan handoff,
   or ask the user for each claim and its source. Do not invent a
   claim.
3. Performance-informed work: take `source_evidence` from the metric
   call you just ran. User-directed work omits it.
4. Placement: use the aspect the user named, or the channel default
   from the launch skill. Extra placements are a later resize, not
   N extra hypotheses.
5. Fill every brief in the batch before generating. If you quote or
   ask, do it once for the batch.

## After the render

Inspect with [creative-quality-gates.md](creative-quality-gates.md).
Repair with [media-qa-and-repair.md](media-qa-and-repair.md). Pass
the brief, hypothesis, and `repair_log` on the handoff contract.
