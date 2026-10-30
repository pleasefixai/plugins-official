---
name: adspirer-retail-ads-walmart
description: "Manage Walmart Connect advertising, keyword and item performance, catalog insights, placements and approved campaign or asset changes."
---

# Walmart Connect

Adapted from the existing Walmart skill, corrected against authenticated Retail discovery.
Load adspirer-retail-ads-tools. Use walmart_ads_read/walmart_ads_write with action=list_tools then schema lookup and execute.
advertiser_id is a string; list_walmart_advertisers resolves connected accounts. A 1P supplier and 3P seller are different advertisers.
Budgets and bids are decimal USD. Inspect current minimums and account eligibility rather than applying Amazon rules.

## Campaign lifecycle

create_walmart_campaign currently documents Sponsored Products creation with auto/manual targeting, FIXED/DYNAMIC/TROAS strategies and daily/both budgets. Explicitly set status paused, even though a generated schema example says enabled.
Build campaign → ad group → ad items and relevant keywords using discovered IDs. SP allows multiple ad groups; do not assume that for SB.
The server also exposes SB assets, SV media and review management, but discovery does not establish a general SB/SV campaign-creation API. Do not promise end-to-end creation of those campaign types through create_walmart_campaign.
Use existing eligible SB/SV campaigns for supported asset/review work. Inspect proposal status and profile approval prerequisites before submitting reviews.
Video workflow is upload_walmart_video → authorized upload to its returned URL → complete_walmart_video_upload → attach_walmart_video. Do not log or commit signed URLs. Uploading is not moderation approval or live delivery.
Get explicit approval before submitting assets/reviews or changing campaign state.

## Measurement and retail readiness

- walmart_stats is today's near-real-time delivery/spend view, not historical attributed-sales reporting.
- get_walmart_keyword_performance is the bid/negative decision surface.
- get_walmart_search_term_performance is described as impression-share/rank. Despite generic spend filters in its signature, do not invent query-level sales; use actual returned columns and pair with keyword performance.
- Historical item, ad-group, platform, page-type and video reports use warehouse data. Preserve one attribution_window (3d, 14d or 30d) per comparison.
- Catalog insights and item alerts reveal inventory, buybox, price and eligibility issues. A buybox price gap is a factual difference, not proof a price cut is profitable.
- Search trends are ranked organic demand signals, not exact search volume or paid CPC.
No changes to product prices or inventory are promised by these read tools.
