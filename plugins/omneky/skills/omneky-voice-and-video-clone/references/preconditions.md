# Sourced inputs — how to obtain them, what to do if absent

Use this table whenever a tool argument comes from another tool.
Confirm each named tool appears on this session's `tools/list` before
calling it. Do not invent a tool or an id. Skills stay on the
connected Omneky MCP server.

Skills stay on the connected Omneky MCP server.

Omneky cannot receive file uploads. No tool accepts bytes or
base64. Host photo attachments only work where a creative tool
accepts an HTTPS URL. If the host has no fetchable URL, ask the
user for a public link. Catalogue products cannot take uploaded
media.

| tool | required input | how to obtain it | what to do if absent |
|---|---|---|---|
| any tool taking `brand_id` | `brand_id` | `list_brands` (then `get_brand_details` for name / logo) | Call `list_brands` and ask the user to choose. Do not guess. |
| any listed tool taking `product_id` | `product_id` | `list_brand_products` for this `brand_id`; `get_product_details` for imagery | Call `list_brand_products` and ask the user to choose one. If there are none, tell the user "I'll create a product you can reuse later", then call `create_product` (or `upsert_brand_product` without `product_id`) with the name, description, and any product page URL they already gave (optionally ask for the product website). Use the new id in the original request without making the user restart. Catalogue products cannot take uploaded media — pass a public HTTPS image URL on the original creative call when that tool accepts one. |
| `create_product` / `upsert_brand_product` without `product_id` | `brand_id`, `product_name`, `product_description` | User (and optional `product_url`) | Ask for a name and short description. Optionally ask for the product website. Do not send file bytes or base64. Catalogue products cannot take uploaded media. |
| `identify_product_from_url` → `scrape_product_from_url` → `finalize_scraped_product` | product page URL | User-supplied HTTPS PDP | If they have no URL, use `create_product` instead. Skip scrape on listing/category pages. `finalize_scraped_product.image_urls` must be a subset of that scrape's HTTPS `scraped_image_urls`. |
| `get_generation_status` | `job_id` | The queued-render result the user already has | Ask the user for the job_id they were given. Do not invent a job_id. |
| `start_plan_upgrade` | `stripe_price_lookup_key` | `list_available_plans` | Call `list_available_plans` and use a returned lookup key. Not a dollar amount. |
| `link_ad_channel_account` | ad account id | `list_authorized_ad_accounts` after `get_channel_connect_url` | Only when `link_ad_channel_account` is on `tools/list`. Connect the channel, list authorized accounts, then link. If it is not listed, say that capability isn't available on this connector. Do not invent an id or a link. |
| `launch_*` `campaign_spec.id` | campaign id | `get_campaigns` (same brand + channel) | Omit `id` to create a new campaign. If they named one you do not have, call `get_campaigns` and ask them to pick. |
| `launch_*` `ad_group_spec.id` / `ad_specs[].adset_id` | ad set / ad group id | `get_ad_groups` (prefer `campaign_id` scope) | Omit `id` to create a new ad set. If they named one you do not have, call `get_ad_groups` and ask them to pick. |
| `launch_*` `ad_specs[].media_url` | finished ad HTTPS URL | Any finished-ad HTTPS URL the user already has (prior generate or user-supplied) | If they have a URL, use it. If they have no URL at all, open the owning creative skill. Confirm before launch. |
| `register_creative_for_launch` | `asset_url` / `preview_storage_key` | Finished-ad HTTPS URL | Ask for an HTTPS URL or reuse one already in this conversation. |
| `search_ad_targeting` / `search_google_countries` / `get_tiktok_location_ids` | location / audience tokens | Those search tools | Call the matching search tool before a new LinkedIn / Google Demand Gen / TikTok launch. Do not invent URNs or location ids. |

Creative / clone inputs (only when those tools appear on `tools/list`):

| tool | required input | how to obtain it | what to do if absent |
|---|---|---|---|
| `generate_new_clone_video_ad` and every tool taking `product_id` | `product_id` | `list_brand_products` for this `brand_id`; `get_product_details` for imagery | Same recovery as the shared `product_id` row. Catalogue products cannot take uploaded media — pass a public HTTPS image URL on the original creative call when that tool accepts one. |
| `generate_avatar_video_ad` | `avatar_url` or `person_image_url` | `search_avatars` `portrait_url`, or the user's brand asset | Call `search_avatars`, or ask for an HTTPS portrait. Custom faces are allowed. Do not invent a URL. |
| `generate_avatar_video_ad` | `voice_id` (optional) | `list_voices` (stock or `cloned_voices`) | Call `list_voices` and ask the user to choose. To create a voice after speaker consent, call `clone_voice` then pick the new id from `cloned_voices`. Omit to leave voice off the trigger. |
| `generate_avatar_video_ad` | `product_image_url` (optional) | `get_product_details` / catalogue still, or a public HTTPS URL | Omit when there is no product image — do not require one. Quote the `AVATAR_WITHOUT_PRODUCT_IMAGE` line. A host photo attachment works only when this tool can fetch an HTTPS URL; if the host has no fetchable URL, ask the user for a public link. |
| `generate_new_clone_video_ad` / `clone_video_pre_assessment` / `get_video_metadata` | `video_url` | `list_ad_instance_items` video_url only, and only when that row reports clone_video_allowed true | If no eligible source video exists, stop and say so plainly. Do not invent a public video link. |
| `edit_image` | `images` (HTTPS URL list) | Prior generate / edit result, or a public HTTPS URL | Ask the user for an HTTPS image or reuse one already in this conversation. Do not invent a URL. A host photo attachment works only when this tool can fetch an HTTPS URL; if the host has no fetchable URL, ask the user for a public link. |
| `resize_ad` | `ad_url` | Prior generate / edit `presigned_url` | Ask the user for an HTTPS image or reuse one already in this conversation. Do not invent a URL. |
| `resize_image` | `image_url` | Same as `resize_ad` | Ask the user for an HTTPS image or reuse one already in this conversation. Do not invent a URL. |
| `generate_image_ad` | `gpt_ad_gen_id` | Mint `<slug>-<uuid4>` | Mint a fresh key per new variant. Reuse only to recover that exact submit. |
| `get_generation_status` | `job_id` | The generate / trigger result that queued the render | Ask the user for the job_id they were given, or check `list_ad_instance_items`. Do not invent a job_id. |
| `fetch_product_video_narratives` | `product_image_urls` | `get_product_details` or a public HTTPS URL | Ask for 1–3 HTTPS product images. Do not invent URLs. A host photo attachment works only when this tool can fetch an HTTPS URL; if the host has no fetchable URL, ask the user for a public link. |
| `generate_product_video` | `narrative_id` | A card from `fetch_product_video_narratives` | Re-fetch and let the user pick again (`narrative_unresolved` means no job). Omit `narrative_id` only for Generate Now. |
| `clone_voice` | `voice_url` | User HTTPS audio sample | Ask for an HTTPS audio URL. Confirm speaker consent. Do not invent a URL. Omneky cannot receive file uploads; if the host has no fetchable URL, ask the user for a public link. |
| `launch_*` `ad_specs[].creative_id` | library creative id | `register_creative_for_launch` or `list_ad_instance_items` | Launch with `ad_specs[].media_url` instead. Do not invent a creative id. |

Unknown or foreign `product_id` returns the same
`not_found_or_forbidden` envelope (it does not say whether another
account owns the id). Follow `next_action`: list or create, then retry
the original tool.
