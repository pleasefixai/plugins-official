# Trading and account actions

Research calls are read-only. For a state change, first identify the endpoint,
the live tool schema, its approval mode, and the account's current live/paper
state. For an order, require the user to specify the asset or prediction
outcome, side, size, and any material order choices. Clarify whether a dollar
amount is notional exposure or margin; do not calculate an unresolved choice
silently.

## Computer direct flow

Computer is the default path on every host. Use a direct executor only when
that server exposes it and its live schema and policy authorize the requested
action. Before a write, verify the selected account or wallet and live/paper
mode match the user's intended target using identity and context actually
exposed by the host or MCP. The selected connection context can establish the
identity; do not invent a wallet introspection call. Ask if identity or mode
differs or is unresolved. State the key values and follow the discovered
confirmation requirement. Preserve backend denials and account/signing
handoffs rather than trying another endpoint.

If autonomous execution is requested, read the current Computer policy/status
first, such as `automated_trading_status` when exposed. If no current policy
read is available, do not act autonomously. Proceed only when active
user-authorized bounds cover the action. Policy changes require their own
explicit request; do not create bounds or infer a scheduler.

## Order inputs and outcomes

Do not invent leverage, order type, limit price, time-in-force, stop/take-profit,
or margin mode. If the schema has a default, explain its material effect before
execution. An accepted, pending, resting, partial, or unknown result is not the
same as a filled or completed result. After an uncertain write, inspect
authoritative orders, history, or positions before any retry; if the first
outcome remains uncertain, do not resubmit.

## Main interactive flow

On Main, only after the user explicitly selects that endpoint, tools such as
`suggest_trade`, `modify_position`, and `close_positions_batch` can return an
interactive proposal or checklist. A proposal is not an execution. Use Main's
existing widget flow when the host supports it; otherwise stop and guide the
user to connect Computer for direct execution. Main's `execute_order` may be
widget-only while Computer's same-named tool accepts direct requests. Use the
contract of the selected connection; shared names do not establish parity.

## Paper mode

Read `paper_trading_status` on the endpoint that will perform the action. Paper
mode may be wallet-scoped and shared by other sessions on that MCP connector,
but it does not switch the Liquid web app or another MCP endpoint. Do not enable,
disable, or reset it without the user's explicit request, and make the mode
clear in every resulting trade update. Use an isolated account for testing and
read the mode back before placing a paper order. A paper request while the
selected endpoint is live is a clarification, not permission to toggle the
setting.

## Bounded automation

Installing this skill is not authorization for autonomous trading. Verify the
current Computer policy/status before each materially different action and
require active bounds covering it. Do not create or widen a policy from a vague
request, infer that a scheduler exists, or claim that ordinary Main tools
provide Computer automation.

Prediction-market writes use their own discovered tools and confirmation flow;
do not route them through perp execution. Funding, conversion, watchlists, and
referrals likewise require their own live tool contracts and approvals.
