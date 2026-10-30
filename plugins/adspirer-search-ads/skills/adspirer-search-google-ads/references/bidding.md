# Google Ads bid strategies

Adapted from Adspirer's existing Google Ads guidance. Choose a strategy for the user's
objective, reliable measurement, budget, available history, and campaign eligibility.
There is no universal requirement to start on clicks or collect a fixed number of conversions
before considering Smart Bidding. Requirements and recommendations vary by strategy and campaign.

## Decision framework

| Objective | Strategies to evaluate | Evidence to check |
| --- | --- | --- |
| Traffic | Maximize clicks or supported manual CPC | Click quality, cost controls, and whether traffic is the actual goal |
| Leads or purchases | Maximize conversions; target CPA where appropriate | Correct primary conversion actions, lag, recent CPA, and feasible budget |
| Conversion value | Maximize conversion value; target ROAS where appropriate | Reliable value reporting, value distribution, and current eligibility |
| Search visibility | Target impression share where supported | Business reason for visibility and acceptable cost |

A new campaign may benefit from account-level signals; low campaign history alone is not
proof that Smart Bidding cannot work. Conversely, eligibility does not guarantee results.
Do not promise a CPA or ROAS target will be achieved.

## Before recommending a change

1. Inspect current bidding, budget, primary conversion goals, values, and tracking quality.
2. Use a representative window accounting for conversion lag, seasonality, and recent changes.
3. Check the strategy's current Google requirements and the connector's live schema.
4. Explain alternatives, uncertainty, and the tradeoff between volume, efficiency, and control.
5. Obtain approval for the specific account, campaign, strategy, target, and budget.

Aggressive targets can constrain delivery. Base proposals on evidence rather than the user's
desired outcome alone. Avoid changing several major settings together without a reason.
Learning and evaluation time depend on conversion cycles and the change; do not prescribe
a universal seven-day period or fixed percentage adjustment.

Discover the relevant read and write operations before executing. Names such as
`list_conversion_actions` and `update_bid_strategy` are discovery candidates, not guaranteed
top-level tools. Verify account currency and units, apply only approved changes, and read back.
Changing bids or targets does not authorize enabling a paused campaign.

## Sources

- [Google: About Smart Bidding](https://support.google.com/google-ads/answer/7065882)
- [Google: About Maximize conversions](https://support.google.com/google-ads/answer/7381968)
- [Google: About Maximize conversion value](https://support.google.com/google-ads/answer/7684216)
