---
name: omneky-marketing-plan
description: >-
  Create, revise, poll, preview (exact credit quote + checklist), and
  track an Omneky marketing plan. This skill owns the weekly-plan
  loop. The host runs each listed step itself. Use when the user wants
  a weekly marketing plan, make me a plan, plan preview, or plan
  progress. Do not use for paid-media analysis or catalogue
  (omneky-analytics-and-catalogue), competitor analysis
  (omneky-competitor-analysis), A/B tests (omneky-ab-tests),
  first-run onboarding (omneky-onboarding), agency
  (omneky-agency), branded image/video creatives,
  launch/connect (omneky-launch-and-connect), or credits/plan
  upgrade (omneky-billing). Intent keywords: weekly marketing
  plan, make me a plan, marketing plan, plan preview, revise
  plan, approve plan.
---

# Omneky marketing plan

Use the connected Omneky MCP server. Gate on this session's `tools/list`.
If `analyze_brand` / `create_marketing_plan` / `get_marketing_plan` are
missing, say those tools are not available here and point the user to
the Omneky app. Do not invent them. Run only the tools that appear on
this session's `tools/list`.

This skill owns goal intake / create / revise / poll / preview /
approve. The host runs each listed plan step (that is execute).
Branded stills → `omneky-image-ads`. Product video →
`omneky-product-video`. Avatar / UGC → `omneky-avatar-ugc`.
Voice or video clone → `omneky-voice-and-video-clone`. Edit /
resize → `omneky-edit-and-resize`.

Handoff fields:
[handoff-contract](references/handoff-contract.md).
Sourced ids (how to obtain / what to do if absent):
[preconditions](references/preconditions.md).
Acceptance gates (for a later creative):
[creative-quality-gates](references/creative-quality-gates.md).
Other intents:
[capability-registry](references/capability-registry.md).
Write for:
[marketer-persona](references/marketer-persona.md).

## Goal

Author a weekly plan from a stated goal, preview the exact quote, get one yes, then host-run each listed step.

## Prerequisites

| Need | Check | If missing |
|---|---|---|
| Brand | `list_brands` | Ask which |
| Analysis | `analyze_brand` | Call it; draft only |
| Plan tools | `create_marketing_plan` / `get_marketing_plan` / `revise_marketing_plan` | Say plan tools are missing |
| Preview quote | `preview_marketing_plan_execution` | Do not run steps without this preview |

## Flow

Goal intake → analyze → create → revise → preview → one yes → host executes listed tools. Deliverable: plan id, checklist, quoted credits, step status, confidence.

When the plan will feed a later creative, collect `approved_claims`
from the user or the plan's cited sources, and pass
`source_evidence` from `analyze_brand` / the approved plan scope
when the next step is plan-driven creative or launch.
Do not invent a claim.

## When to use

- Weekly marketing plan / "make me a plan"
- Revise, preview, or mark plan-step progress

## When not to use

- Not paid-media analysis, ROAS, or catalogue import
- Not a standalone image-ad or product-video generate call
- Not live spend or go-live
- Not launch/connect or credit-balance / plan upgrade

## Intent keywords

weekly marketing plan, make me a plan, marketing plan, plan preview,
revise plan

## Goal intake

Ask once, only for what is missing, before `analyze_brand`:

- Outcome (what "good" looks like)
- Timeframe (default **7 days**)
- Channels they care about
- Constraints (keep launches `PAUSED`, brand claims they already
  approved)
- A credit or budget cap if they named one

Do not invent a cap. Do not start create until `brand_id` is
known.

## Loop

1. `analyze_brand` with `brand_id` (optional `website_url`). Draft
   `plan_id` / `analysis_id`, no steps. Uses Exa for evidence.
2. `create_marketing_plan` with `brand_id`, `plan_id`, and
   `analysis_id`. Omit `plan_body`; the server authors the plan. Default
   timeframe is **7 days**. Do not write `plan_body.steps`. Do not stop
   on `plan_body_required`. If the result is pending, follow Pending
   polls below, then read it with `get_marketing_plan`. Create is
   draft-only: no generation, launch, or credit deduct.
3. `revise_marketing_plan` with an `instruction` (or a server-authored
   `plan_body`) if the user wants changes. That starts a **pending
   revision**; poll `get_marketing_plan` until applied (same bounds).
   `plan_version` increments by 1 on apply, not at start. Pass
   `step_updates` or `completed_step_ids` to mark host-run steps done.
   Status-only mark-done does not start a pending revision.
4. `preview_marketing_plan_execution` is mandatory after create and
   after every applied revise. It is read-only and has no side effects.
   It returns the ordered checklist plus credit quotes from
   `quote_creative_credits`. Show the credit quote as the one
   approval. Re-preview after revise so the checklist matches.
5. **Approve.** One yes on **this** preview's checklist plus the
   exact quoted `credits.total_credits`. That yes is the execute
   gate. No yes → do not run steps.
6. **Execute.** Plans are data. Each step is
   `{tool, arguments, depends_on, status}`. `tool` is a name from
   this session's `tools/list`.
   After that yes, call each
   `step.tool` with `step.arguments` yourself.
   Then
   `revise_marketing_plan` to mark that step done. Read progress
   with `get_marketing_plan` (read-only; unrun steps show `pending`).
   `execute_marketing_plan` is not on this surface. Do not invent it.
   Leftover runs started outside this surface: poll
   `get_marketing_plan_run` or stop them with
   `cancel_marketing_plan_run`.

## Pending polls

Never silent-loop. Never start a second create or revise while one
may still be running. Reuse the same `plan_id`.

1. Tell the user the plan is being written (or the revision is
   applying).
2. Call `get_marketing_plan` every **10 seconds**, at most **6** times
   (~60s).
3. Still pending: "Still writing the plan."
4. After 6 pending reads: stop. Offer to check back. Do not resubmit
   create or revise.
5. When applied: run Plan-created checks, then preview.

Quoted cost is compared to its **approved** value. Request arguments
never prove a saved plan or preview.

Reply or a `get_marketing_plan` read-back already shows the fact →
say it plainly (e.g. "done"). Do not hedge. Missing detail → **one**
get. If it is still not confirmed, say so in one short plain sentence
(e.g. "I couldn't confirm the charge"). If a check fails: say which
field differed. Do not run steps on a stale preview.

## Plan-created checks

After create or an applied revise — before preview exists:

- Non-empty `plan_id` — observe create/revise or `get_marketing_plan`
- Non-empty steps — observe plan_body.steps on `get_marketing_plan`
- Selected step id + one-line summary match the request — observe
  those saved-plan fields, not the create arguments
- `plan_version` equals the applied version (revise +1 on apply) —
  observe `get_marketing_plan`

## Preview-approved checks

After `preview_marketing_plan_execution`, before the host runs steps.
User approved **this** preview:

- Ordered checklist tools are names from this session's `tools/list`
- Quoted cost equals the **approved** cost — observe preview
  `credits.total_credits` (or equivalent)

## Host-step checks

After each listed `step.tool` call:

- That step's `status` is `done` — observe `get_marketing_plan` after
  `revise_marketing_plan` with `step_updates` / `completed_step_ids`
- Unrun steps may stay `pending`
- Charge for that step reconciles with the **approved** quoted line
  when the tool is quotable

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
