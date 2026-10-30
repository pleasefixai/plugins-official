# Omneky-managed launch rules

Read this file only for a managed launch (no connected Meta or
OpenAI Ads account, or the user asked for managed). Use the
connected Omneky MCP server. Gate on `tools/list`.

Skip Connect and the disconnected-account preflight. These tools
work without a linked advertiser account. Do not refuse because
`get_channel_connection_status` is disconnected.

Prepaid: `status=payment_required` means nothing launched. Tell the
user the amount the server reports. Share `checkout_url` only if they
choose to pay, then retry or `get_managed_launch_payment_status`.

| Tool | Notes |
|---|---|
| `launch_omneky_managed_meta_ad` | No connected Meta account. Objectives: traffic / video_views / awareness only. Do not pass a landing-page URL in ad specs. |
| `launch_omneky_managed_openai_ad` | No connected OpenAI Ads account. Same prepaid / hosted-landing-page rules. |

Top-level `status_on_launch`. Keep launches `PAUSED` unless the user
explicitly says to go live. Connecting an account is a separate step
from launching.
