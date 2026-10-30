---
name: adspirer-retail-ads-performance
description: "Review Amazon and Walmart spend, attributed sales, ACoS, ROAS, item performance and budget pacing without changing campaigns."
---

# Read-only performance review

Load adspirer-retail-ads-tools and confirm account, marketplace, dates, timezone, currency, ad product and attribution window.
Amazon campaign/product/search-term/placement reports and Walmart keyword/item/ad-group/page-type/platform/video reports serve different scopes. Do not assume report parity.
Distinguish near-real-time Walmart stats from historical warehouse reports. Missing/stale data is not zero performance.
Use filters and bounded limits, not exhaustive billed pagination. Report whether displayed rows are a subset and whether summary totals cover the full filtered set.
Show spend, attributed sales, orders, ROAS, ACoS, CTR/CPC and pacing only where available. Compute ratios from comparable totals, not averages of row ratios.
Do not sum incompatible currencies or attribution windows, double-count overlapping reports, or present ad-attributed sales as incremental revenue.
Check stock, buybox and eligibility before attributing poor conversion solely to ads.
Lead with supported findings and uncertainties. Hand proposed actions to adspirer-retail-ads-optimization; this skill never changes resources.
