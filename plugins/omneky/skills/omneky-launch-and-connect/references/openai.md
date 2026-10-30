# OpenAI Ads launch rules

Read this file only when launching on a **connected** OpenAI Ads
account. Use the connected Omneky MCP server. Gate on `tools/list`.

No connected account → [managed.md](managed.md)
(`launch_omneky_managed_openai_ad`).

`openai_location_search` is optional — omit `campaign_spec.targeting`
to reach all eligible locations; otherwise paste
`campaign_spec_fragment` into `campaign_spec.targeting`.

- Daily budget floor is the figure `minimum_budget_for_objective`
  returns (do not invent a dollar floor)
- Image `chat_card` only
- Title 3–50 / body ≤100
- `destination_url` required
- New ad groups need `max_bid_dollars`

| Tool | Notes |
|---|---|
| `launch_openai_clicks_ad` | Connected OpenAI Ads. Location optional. |
| `launch_openai_impressions_ad` | Same location and creative rules; the tool bids on impressions (no `bidding_type` argument). |

Keep launches `PAUSED` unless the user explicitly says to go live.
Targeting stays on `campaign_spec.targeting`.
