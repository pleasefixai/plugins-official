# Meta / Facebook launch rules

Read this file only when launching on Meta / Facebook. Use the
connected Omneky MCP server. Gate on `tools/list`.

Inline targeting. No lookup tool. Example shape:
`{"countries": ["US"], "age_min": 25, "age_max": 55}`.

| Tool | Notes |
|---|---|
| `launch_facebook_sales_ad` | Inline targeting. |
| `launch_facebook_leads_ad` | Same targeting. Set `lead_gen_form_id` on ad specs for native forms. |
| `launch_facebook_awareness_ad` | Same targeting. |
| `launch_facebook_traffic_ad` | Same targeting. |
| `launch_facebook_video_views_ad` | Same targeting. |

Keep `campaign_spec.status_on_launch` `"PAUSED"` unless the user
explicitly says to go live.
