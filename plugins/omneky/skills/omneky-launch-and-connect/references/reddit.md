# Reddit launch rules

Read this file only when launching on Reddit. Use the connected
Omneky MCP server. Gate on `tools/list`.

Inline targeting. Example shape:
`{"geolocations": ["US"], "communities": [...]}`.

`bid_value` is micros (dollars × 1,000,000). Convert the user's
dollar bid; do not invent a bid they did not approve.

| Tool | Notes |
|---|---|
| `launch_reddit_awareness_ad` | Inline targeting + micros `bid_value`. |
| `launch_reddit_traffic_ad` | Same. |
| `launch_reddit_conversions_ad` | Same. |
| `launch_reddit_leads_ad` | Same. |
| `launch_reddit_video_views_ad` | Same. |

Keep launches `PAUSED` unless the user explicitly says to go live.
