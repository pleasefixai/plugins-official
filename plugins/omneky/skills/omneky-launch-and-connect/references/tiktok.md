# TikTok launch rules

Read this file only when launching on TikTok. Use the connected
Omneky MCP server. Gate on `tools/list`.

Required before any `launch_tiktok_*` (the API returns 400 without
it):

1. `get_tiktok_location_ids` with `brand_id` and required
   `campaign_objective` (`TRAFFIC`, `LEADS`, `VIDEO_VIEWS`, or
   `CONVERSIONS` — match the `launch_tiktok_*` you are about to call).
2. Put the returned ids on the ad group as `location_ids`. Do not
   invent ids.
3. `ad_group_spec.name` maps to `adgroup_name`.

| Tool | Notes |
|---|---|
| `launch_tiktok_traffic_ad` | Location pre-call required. |
| `launch_tiktok_leads_ad` | Same. |
| `launch_tiktok_video_views_ad` | Same. |
| `launch_tiktok_conversions_ad` | Same. |

Keep launches `PAUSED` unless the user explicitly says to go live.
