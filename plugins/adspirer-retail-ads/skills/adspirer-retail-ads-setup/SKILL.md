---
name: adspirer-retail-ads-setup
description: "Connect Amazon Ads and Walmart Connect accounts and optionally establish an approved retail brand workspace."
---

# Account setup

Load adspirer-retail-ads-tools. Let the user finish browser OAuth; never request credentials in chat.
Call get_connections_status, then use list_amazon_profiles or list_walmart_advertisers through the read routers when needed.
Resolve the intended profile/advertiser, marketplace and currency. Do not activate accounts without approval.
Direct connection questions to https://adspirer.ai/connections and current official docs. Walmart account connection can require granting Adspirer partner access and verifying an advertiser ID; do not describe every ad-platform connection as OAuth.

## Optional workspace

Do not require setup for a simple question. Read only user-designated brand/product files; never recursively ingest unrelated files or secrets.
With explicit permission, create or update BRAND.md and STRATEGY.md while preserving existing content. Ask before appending to unrelated files.
Record products/ASINs/SKUs/item IDs, voice and substantiated claims, margin assumptions, marketplace, inventory constraints, goals, approved budget and attribution conventions.
Keep observed spend separate from authorized future spend. Use actual read-only performance snapshots; mark missing data.
Create a private decision log only on request, never credentials or raw personal data.
Finish with connections, evidence, gaps and actual files saved, then resume the original request.
