---
name: adspirer-retail-ads-optimization
description: "Find wasted retail ad spend and propose Amazon or Walmart bid, targeting and budget improvements with explicit approval and readback."
---

# Retail optimization

Load adspirer-retail-ads-tools plus platform and performance skills.
Amazon: use wasted-spend, targeting, placement, budget usage and recommendation operations. optimize_amazon_budget is a read-only plan, not proof of an applied change.
Walmart: use keyword/item performance, out-of-budget recommendations, catalog insights and item alerts; do not invent a Walmart waste-analysis operation.
Check sample size, attribution lag, margin, inventory and buybox eligibility before cutting spend. Zero-sales rows need separate handling from ACoS filters.
Propose the least disruptive justified action: keyword/ASIN exclusions, bids, placement adjustments, narrowed pauses or budget changes.
Show before/after values, total budget impact, account currency, evidence and uncertainty. Do not use universal pause thresholds or automatic percentage increases.
Get approval for exact writes and use confirm:true only when authorized. Prefer reversible pauses over deletion; explain archival effects.
Read back every changed resource. Inspect state before retrying timeouts or partial errors. Never claim continuous optimization without a real authorized scheduler.
