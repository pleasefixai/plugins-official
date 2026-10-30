---
title: Knock plan file
description: Write all plan detail to knock-plan.md; keep chat minimal
tags:
  - strategy
  - output
  - plan
category: knock-product-messaging-strategy
last_updated: 2026-07-29
---

# Knock plan file

All detailed plan output from messaging strategy (and related skills) goes in **`knock-plan.md`** at the repo root (create or update; do not invent a different path unless the user names one). Chat is only for must-know status and confirmation questions.

Shared across `knock-product-messaging-strategy`, `knock-lifecycle-opportunities`, `knock-migrate-to-knock`, and `knock-setup` handoffs. Update the same file — do not create a second plan. Preserve sections another skill already filled.

## Chat contract (hard)

In chat, do **not** paste full workflow briefs, checklists, or long rationale.

Allowed chat content:

1. One short status line (what you wrote / updated and how many items)
2. Optional one-line risk or blocker (only if it blocks progress)
3. The bold confirmation question as the **last line**

Example chat after drafting:

Wrote `knock-plan.md` with 6 recommendations (4 build-ready, 2 deferred).

**Which items should we build next?**

Example after user confirms:

Updated `knock-plan.md` handoff: confirmed 1–4, 6; skipped 5.

**Hand off to knock-setup to build these in Knock development?**

## File structure

Write (or update) `knock-plan.md` using this skeleton. Preserve sections other skills already filled.

```markdown
# Knock plan

## Product context
- **Product.** …
- **Personas / roles.** …
- **Key objects / tenants.** …

## Preference taxonomy
- Categories and defaults (brief)

## Signals found
| Stage | Signal | Evidence (path) | Recipient | Existing message? |
| --- | --- | --- | --- | --- |
| … | … | … | … | … |

## Recommendations

### 1. [Name]
- **Status.** proposed | confirmed | skipped | deferred | blocked
- **Moment type.** … (or lifecycle stage)
- **Trigger / eligibility.** …
- **Recipient.** …
- **Intended action.** …
- **Channels.** primary → escalation (conditions)
- **Stop condition.** …
- **Frequency / batching.** …
- **Preference category.** … (or transactional exemption)
- **Success metric.** …
- **Fatigue risk.** low | medium | high — why
- **Knock shape.** workflow | guide | both — brief notes
- **Trigger data.** required payload / user properties
- **Evidence in code.** paths / models / events (when from lifecycle scan)
- **Notes.** …

### 2. [Name]
…

## Deferred / blocked
| Name | Reason |
| --- | --- |
| … | … |

## Audit (only when auditing)
| Existing item | Score (Keep/Fix/Merge/Kill) | Notes |
| --- | --- | --- |
| … | … | … |

## Migration inventory (only when migrating; see knock-migrate-to-knock)
| ID | Current mechanism | Channel(s) | Trigger | Recipient logic | Template location | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| … | … | … | … | … | … | … |

## Migration plan (only when migrating; see knock-migrate-to-knock)
- Summary, resource order, phases, code changes, risks

## Setup handoff
- **plan.** knock-plan.md
- **confirmed.** …
- **skipped.** …
- **deferred / blocked.** …
```

Number recommendations as an ordered list (`1.`, `2.`, … — never unnumbered bullets) so the user can answer with indexes (e.g. "build 1–4, skip 5"). Keep the same numbering any time you list recommended workflows in chat.

## Update rules

1. After each major step, update the file — do not accumulate a long chat draft then dump once.
2. When the user confirms or skips, update **Status** on each item and refresh **Setup handoff**.
3. When applying Knock shapes (`apply-in-knock.md`), enrich the matching recommendation sections in the file; keep chat to a one-line "updated Knock shapes in knock-plan.md".
4. Downstream skills (`knock-setup`) should read `knock-plan.md` for detail; chat handoff only needs the confirmed/skipped/deferred lists plus a pointer to the file.
