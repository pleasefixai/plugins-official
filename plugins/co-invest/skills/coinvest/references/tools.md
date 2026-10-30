# Public tool discovery

Inspect the host-provided current tool list, schemas, and approval metadata as
the source of truth. If the host exposes a discovery operation, use it; do not
invent a discovery command or route. The names below
are known public catalog starting points; use one only when the connected server
actually exposes it. Do not copy or print raw schemas, internal guidance,
private descriptions, or credentials; user-requested account results may be
summarized.

## Computer default path

By default, inspect Computer's discovered direct executors and reads on every
host. Look for direct trade and position tools
such as `execute_order`, `execute_orders_batch`,
`execute_tpsl`, `close_position`, `cancel_order`, and `update_leverage`; account
reads such as `get_portfolio` and `view_open_orders`; setup via `enable_trading`;
and paper controls including `paper_trading_status`, `enable_paper_trading`,
`disable_paper_trading`, and `reset_paper_account`. It may also expose
`automated_trading_status`, `enable_automated_trading`,
`disable_automated_trading`, `market_picks`, `upcoming_earnings`, and
`show_portfolio_chart`.

Computer research starting points include `analyze_market`,
`analyze_markets_batch`, `get_positioning_pulse`, `search_markets`, `get_news`,
`get_technical_indicators`, `show_market_overview`, `show_orderbook`,
`show_chart`, and `plan_portfolio`. Use their text or structured results;
a tool name containing "show" or "chart" does not itself require widget UI.

These are discovery starting points, not a Computer parity claim. Use a name
only when the connected Computer server exposes its current schema and approval
behavior. Read `automated_trading_status` immediately before any autonomous
action when exposed; if no current policy/status is available, do not act
autonomously. Require current bounds that cover the action.

## Main optional catalog

Main can provide broader interactive research, account, prediction, funding,
watchlist, referral, and proposal tools only when the user explicitly selects
Main. Its text reads remain usable; its widget actions require host UI support.
Research names include `analyze_market`, `analyze_markets_batch`,
`get_positioning_pulse`, `search_markets`, `get_news`, `read_link`,
`show_market_overview`, `show_orderbook`, `show_chart`,
`get_technical_indicators`, `search_prediction_markets`,
`show_prediction_orderbook`, `leaderboard_data`, and `leaderboard_rank`.
Do not treat Main's widget-only execution tools as direct Computer tools or use
Main as an implicit fallback when Computer is absent.

Use the minimum read calls needed on any endpoint. Do not treat stale
conversation data as a current price, balance, position, or order status when
the user asks for a refresh.

## Account and preferences

Computer's core account reads include `get_portfolio`, `view_open_orders`, and
`paper_trading_status`. Broader discovered account tools may include
`get_transaction_history`, `get_position_history`, `view_prediction_positions`,
`view_prediction_orders`, and `get_staking`.

`get_position_history`, when exposed, reconstructs the wallet's recent
perpetual position lifecycles from a bounded window of recent fills: side,
entry and exit prices, size, gross realized PnL (before fees and funding),
fees in their own tokens, and optional constituent fills. It follows the
current live or paper mode. It is recent history, not an all-time ledger:
report the coverage it states, and when it marks a lifecycle `unknown` or its
entry incomplete, say so rather than inventing an opening or a close. It
returns closed lifecycles by default; ask for `open` or `all` explicitly, and
treat an `open` result as open at the last observed fill, not as the current
position. Its `symbol` filter is the exact, case-sensitive source coin,
including any venue prefix such as `xyz:BTC`. Use `get_portfolio` for current
positions and, where offered, `get_transaction_history` for deposits,
withdrawals, transfers, and individual transaction rows.

`edit_watchlist`, `refer`, and `help` cover preferences, referrals, and the
server's own capability help. Funding and conversion names may include
`show_deposit`, `generate_deposit_address`, `create_onramp_session`, and
`convert_balances`; follow their live schemas and approval behavior.

## Proposals, execution, and positions

The optional Main interactive catalog may expose `suggest_trade`,
`suggest_trades_batch`, `plan_portfolio`, `modify_position`,
`close_positions_batch`, and `update_leverage`. Direct order and position names
such as `execute_order`, `execute_orders_batch`, `execute_tpsl`,
`close_position`, and `cancel_order` are endpoint- and policy-dependent. They
are never a promise that Main exposes direct writes; use Computer by default for
direct workflows.

Prediction writes are a separate domain and may include
`execute_prediction_order`, `close_prediction_position`, and
`cancel_prediction_order`. Do not route prediction orders through ordinary perp
tools. Do not promise withdrawals, scheduling, or managed copy-trading unless
the live discovery and policy explicitly expose them.

Proposal widgets, direct Computer executors, and restricted review links are
different contracts even when a tool name overlaps. Read
[trading guidance](trading.md) before using any state-changing tool.
