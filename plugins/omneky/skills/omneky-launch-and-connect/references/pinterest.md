# Pinterest launch rules

Read this file only when launching on Pinterest. Use the connected
Omneky MCP server. Gate on `tools/list`.

1. `get_pinterest_connection_status` first. Disconnected → connect;
   do not launch.
2. Inline targeting `{"countries": ["US"], "age_min": 25, "age_max": 55}`.
3. Pin `title` ≤100 characters.
4. `destination_url` (or `link_urls`) required.

| Tool | Notes |
|---|---|
| `launch_pinterest_awareness_ad` | Connection check, countries, title, destination. |
| `launch_pinterest_traffic_ad` | Same. |
| `launch_pinterest_sales_ad` | Same. |
| `launch_pinterest_leads_ad` | Same. |
| `launch_pinterest_video_views_ad` | Same. |

Lists: `get_pinterest_campaigns`, `get_pinterest_ad_groups` (pass
`campaign_id`), `get_pinterest_ads`. Pause or resume with
`set_pinterest_entity_status`. Keep launches `PAUSED` unless the user
explicitly says to go live.
