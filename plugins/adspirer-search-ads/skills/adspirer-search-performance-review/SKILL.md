---
name: adspirer-search-performance-review
description: Read-only Google Ads reporting and Microsoft account inspection, scorecards, conversion checks, and evidence-backed recommendations.
---

# Performance review

Adapted from adspirer-performance-review. Load adspirer-search-mcp. This skill never changes campaigns.
Check get_connections_status and select the intended account before reading data.

## Sources

Google: get_campaign_performance if advertised, plus discovered google_ads_read reports. Microsoft: discover bing_ads_read operations; the inspected catalog is inspection-oriented, not equivalent performance reporting.
Use raw_data only if the actual schema accepts it; do not assume widget rendering.

## Trust the numbers

Confirm dates, timezone, currency, conversion definition, and attribution window. Distinguish
partial days, conversion lag, missing permissions, and tracking failures from real declines.
Run audit_conversion_tracking where relevant and supported. A tracking gap limits affected
conversion claims; it does not automatically invalidate independently measured spend.
Do not combine incompatible currencies or double-count cross-platform attributed conversions.

## Scorecard and interpretation

Show spend, pacing, conversions, CPA, ROAS when revenue exists, CTR/CPC, and comparison with
an equivalent prior window. Compute blended CPA from comparable totals, not average platform CPAs.
Lead with the largest supported problem and opportunity, with evidence and caveats.
Discover available anomaly tools, but treat their explanations as hypotheses unless supported.
Recommend actions; hand approved changes to adspirer-search-optimize.

## Repeating reviews

Offer a host schedule only when supported and authorized, explaining quota usage.
This endpoint does not imply access to a server-side monitoring router. Do not claim that a
report is scheduled until an actual scheduler confirms it. No fabricated figures or trends.
