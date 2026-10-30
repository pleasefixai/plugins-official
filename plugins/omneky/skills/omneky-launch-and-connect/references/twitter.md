# X Ads launch rules

Read this file only when launching on X Ads. Use the connected
Omneky MCP server. Gate on `tools/list`.

Wire name is `twitter`, never `x`. Omit targeting = US. Optional
`search_ad_targeting` with `channel="twitter"`.

`bid_amount` is dollars, not micros, and must be omitted when
`bid_strategy` is `AUTO`. Headline ≤280 characters.

| Tool | Notes |
|---|---|
| `launch_twitter_awareness_ad` | `channel="twitter"`. |
| `launch_twitter_traffic_ad` | Same. |
| `launch_twitter_engagements_ad` | Same. |
| `launch_twitter_followers_ad` | Same. |
| `launch_twitter_video_views_ad` | Same. |

Pause with `set_ad_entity_status` at **campaign** level only.
Keep launches `PAUSED` unless the user explicitly says to go live.
