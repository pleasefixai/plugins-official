---
name: adspirer-retail-ads-amazon
description: "Manage Amazon Sponsored Products, Sponsored Brands and Sponsored Display using the Retail endpoint, with profile-aware research, reporting and approved changes."
---

# Amazon Ads

Adapted from the original Amazon platform skill. Load adspirer-retail-ads-tools; all Amazon operations use amazon_ads_read or amazon_ads_write, not the main hub's amazon_ads router.
Use profile_id as a string. Profiles identify a marketplace/account pair; list_amazon_profiles before choosing. Confirm currency rather than assuming USD.

## Build and manage

- Sponsored Products: create_amazon_sp_campaign can build campaign, ad group, products and targeting in one operation. Do not duplicate its child resources.
- AUTO can discover demand; MANUAL supports keywords, product targets or both. Combined keyword/product targeting goes into separate ad groups; use the current schema.
- Use ASINs for vendors or SKUs for sellers as required. check_amazon_product_eligibility before building.
- Sponsored Brands: create_amazon_sb_campaign requires appropriate Brand Registry access. Resolve brand_entity_id from list_amazon_brands; do not confuse it with brandId. Asset requirements vary by product collection/video format.
- Sponsored Display: create_amazon_sd_campaign is present in live discovery even though the top-level router summary mentions only Products/Brands. A campaign and optional ad group are not a complete ad: targets, ads and creative must be completed and verified.
- All new campaigns explicitly use state PAUSED. Resume only after a separately approved review.

Use dedicated tools first. For amazon_unified_api, verify resource, verb, ad_product and nested fields against current documentation/schema. Its prose and field descriptions can conflict; stop to resolve ambiguity instead of guessing. Do not use it to evade errors or permission checks.

## Reports and profitability

get_amazon_campaign_performance, get_amazon_report, get_amazon_search_terms and product/placement/targeting reports are routed reads.
Warehouse reports may lag or be unavailable; report absence, do not repeatedly poll.
ACoS = spend / attributed sales; ROAS = attributed sales / spend. Zero sales makes ACoS undefined, not zero.
Break-even ACoS requires a user-confirmed contribution margin after relevant fees/costs, not simply gross markup.
Use attribution windows, comparable dates and actual currency. Ad-attributed sales are not total store revenue or incremental profit.
