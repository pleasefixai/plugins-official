---
name: coinvest
description: "Liquid Co-Invest is free AI trading you control: research markets, size positions, and trade crypto, stocks, commodities, and FX from your AI agent. Co-Invest Computer exposes Liquid as an MCP server, so Claude Code, Codex, Cursor, Hermes, or any MCP client can research markets, watch for entries, and execute trades within the limits you set. Use when the user wants Liquid market research, portfolio or account information, paper trading, or an explicitly requested trade. Uses the Co-Invest Computer OAuth MCP by default."
license: MIT
---

# Liquid Co-Invest

![Co-Invest](https://raw.githubusercontent.com/LiquidMax-dev/liquid-plugin/main/skills/coinvest/assets/logo.svg)

Research. Position. Trade. All from your AI agent.

[Co-Invest](https://www.liquid.trade/coinvest) provides advanced market data,
analysis, and trade execution for crypto, stocks, commodities, and FX directly
in your AI assistant.
[Co-Invest Computer](https://www.liquid.trade/coinvest-computer) lets AI agents
trade on your behalf: it exposes Liquid as an MCP server, so your agent can
research markets, monitor entries, and execute from your harness. It is built
for code-agent clients such as Claude Code, Codex, Cursor, and Hermes, and works
with any MCP client.

- **Market research.** Positioning, funding, on-chain flow, and macro headlines,
  with prices, order books, and news kept in view.
- **Portfolios shaped by the market's signals.** Ask for a balanced book across
  stocks, gold, and crypto and get positions sized to your live balance.
- **Trade ideas with receipts.** Picks come with a named catalyst and a link to
  the source: earnings prints, central bank decisions, ETF flows, on-chain data.
- **Connect in minutes.** Connect the Co-Invest Computer server in your agent
  harness, then give the agent a market, a strategy, and the limits it should
  respect.
- **Watch until the signal is real.** Updates are checked against the entry
  conditions you gave it. Weak setups get ignored; clean setups move forward.
- **Move when the trigger hits.** It stages or sends the order in the mode you
  enabled, carrying stops, take-profits, and leverage into the trade. You can
  pause, let the plan expire, or take back manual control at any time.
- **Execution controls.** Max notional, max leverage, stop-loss requirements,
  optional symbol lists, daily order caps, and expiry.
- **Try it before going live.** Start with paper trading or staged orders and
  watch the full agent loop against market data before enabling live execution.
- **Free.** No subscription and no AI surcharge; model usage stays with the
  client you choose. Executed trades pay standard Liquid trading fees.

## Using this skill

The overview above describes the product. It grants no trading authority; the
rules below govern what an agent may do.

Use this skill when the user wants Liquid market research, account information,
paper trading, or an explicitly requested trade. By default, use Computer at
`https://coinvest-computer.liquid.trade/mcp` for reads and user-authorized
direct live or paper trades on every host, including widget-capable hosts. If
Computer is absent, guide its connection and OAuth setup; do not choose Main or
Restricted merely because it is installed. The skill supplies guidance;
installing it does not connect an MCP server, grant trading authority, or create
an automation policy.

Requires a host that supports remote HTTP MCP and Liquid OAuth.

Read the reference that matches the task before acting:

- [Connect and choose an endpoint](references/connect.md)
- [Discover public tools and capabilities](references/tools.md)
- [Research, trading, paper mode, and automation](references/trading.md)

At the start of a task, inspect the host-provided current tool list and the
schema and approval behavior of any candidate tool. If the host exposes a
discovery operation, use it; do not invent a discovery command or route. Current
host-provided definitions are sufficient when no discovery call exists. Treat
the live endpoint as the authority. Catalog names in the references are
starting points only; a shared name never proves that two endpoints have the
same schema, output, confirmation flow, or permission.

Keep the selected MCP connection as an authority boundary. Use Computer by
default for reads and direct user-authorized trades. Main is available only when
the user explicitly selects its interactive, widget-oriented workflow; a host
must not call a Main widget-only executor or claim that a widget proposal
executed without the required UI. Restricted is available only when explicitly
selected for its review-link behavior and must never be silently upgraded to
direct execution. Never switch endpoints to bypass a denial. If changing or
adding a connection would change execution behavior, explain that choice and
get the user's decision first.

For every state-changing request, follow the actual discovered approval flow.
For an order, require concrete asset, side, and size details, clarify notional
versus margin, and do not invent leverage, order type, price, or margin mode.
Distinguish an accepted or resting order from a filled order. If a write times
out or its result is unknown, inspect authoritative orders or history before
considering any retry.

Before a write, verify that the selected connection's account or wallet and
live/paper mode match the user's intended target using identity and context
actually exposed by the host or MCP. The selected connection context can be the
identity evidence; do not invent a wallet introspection call. Ask when either
identity or mode is different or unresolved. Paper mode can be shared by a
wallet's sessions on that MCP connector while remaining separate from the Liquid
web app and other endpoints;
never assume it propagates or change it silently. Autonomous trading requires a
fresh read of the current Computer policy/status and active bounds covering the
action. Do not infer a scheduler, create bounds from a vague request, or treat
skill installation as consent.
