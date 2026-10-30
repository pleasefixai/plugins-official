# LinkedIn launch rules

Read this file only when launching on LinkedIn. Use the connected
Omneky MCP server. Gate on `tools/list`.

Required before any `launch_linkedin_*` (the API returns 400 without
it):

1. `search_ad_targeting` with `brand_id`, `channel="linkedin"`,
   `types=["locations"]`, and the place the user named (`query`).
2. Copy a hit whose value includes
   `urn:li:adTargetingFacet:locations` into `targeting_criteria`.
   Do not invent a URN.
3. A new campaign group also needs `start_date` (`YYYY-MM-DD`).

| Tool | Notes |
|---|---|
| `launch_linkedin_brand_awareness_ad` | Location search + `start_date` rule. |
| `launch_linkedin_website_visits_ad` | Same. |
| `launch_linkedin_conversions_ad` | Same. |
| `launch_linkedin_engagement_ad` | Same. |

Keep launches `PAUSED` unless the user explicitly says to go live.
