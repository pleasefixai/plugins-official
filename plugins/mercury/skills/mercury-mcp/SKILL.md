---
name: mercury-mcp
description: "Use whenever the user asks about their Mercury bank accounts, balances, transactions, spend, cards, statements, recipients, or cashflow. Covers how to use the Mercury MCP tools correctly: complete pagination, date anchoring with getCurrentDate, postedStart/postedEnd filtering, the debit-sign convention, and masking account numbers. The other Mercury skills build on this one."
metadata:
  version: "1.0.0"
  category: shared
  tools: [getCurrentDate, getAccounts, getAccount, listTransactions, getTransactionById, listCategories, getAccountStatements, getCashflowSummary]
  requires: []
---

# Mercury MCP

Answer questions about the user's Mercury account with the **Mercury MCP server** (`https://mcp.mercury.com/mcp`). Authentication is the server's OAuth flow, handled by the MCP client; skills never see or handle credentials. If a tool call fails with an authorization error, tell the user to reconnect the Mercury MCP server and stop; do not retry.

Tool names below are the bare names (`listTransactions`). In Claude Code they appear with a plugin prefix, such as `listTransactions`; the part after the last `__` is the name used here.

If the Mercury tools are not in your tool list, stop and tell the user to enable the `mercury` plugin (or connect the Mercury connector) before continuing.

## When to use this skill

Any question about the user's own Mercury data: "what's our balance", "what did we pay Vendor X", "list last week's card charges", "which statements are available", "how much came in this quarter". For a categorized spend report use `mercury-analyze-spend`; for unusual-activity checks use `mercury-detect-anomaly`; for a General Ledger reconciliation workpaper use `mercury-cash-reconciliation`. Those skills assume the rules below.

## Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| `getCurrentDate` | Today's date | Always call first; see *Anchor dates* |
| `getAccounts` | List accounts with balances | |
| `getAccount` | One account by `accountId` | |
| `listTransactions` | Transactions across accounts | Paginated; see *Fetch everything* and *Dates* |
| `getTransactionById` | One transaction by `transactionId` | |
| `listCategories` | Custom expense categories | Distinct from `mercuryCategory`, which Mercury assigns |
| `getAccountStatements` | Statement metadata for an account | Statement PDFs are not available through MCP |
| `getCashflowSummary` | Monthly cash in / cash out / net | Server-side aggregation; returns integer cents with `outgoingCents` negative |

The production server is read-only. Skills in this plugin never modify Mercury data; if a user asks for a write (categorizing, adding a note, attaching a receipt), say it isn't available here and point them to the Mercury dashboard.

## Fetch everything before you aggregate

Never answer questions that need full data ("total spend", "all transactions", "most/least") from a partial result.

`listTransactions` is paginated:

1. Call with `limit: 300` and your filters.
2. If the response contains `page.nextPage`, call again with the same filters plus `start_after: <page.nextPage>`.
3. Repeat until `page.nextPage` is absent, then merge all pages.

If any response contains `Result too long`, discard it and re-call with `limit` halved. Never analyze truncated data. If completing the fetch would take more than a handful of calls, narrow the date range or add `accountId`, `categoryId`, or `status` filters rather than accepting truncation.

There is no field projection, so filter server-side as tightly as the question allows, then reduce the JSON programmatically rather than reasoning over raw rows.

## Anchor dates against today

LLMs hallucinate dates. Before computing any window, call `getCurrentDate` and derive every start/end relative to it. Never hardcode today.

## Dates on transactions

- Use `postedStart` / `postedEnd`, not `start` / `end`. The `start`/`end` pair filters on `createdAt`, which for card charges is the authorization date, one or more days before the `postedAt` the user sees in the dashboard. Results include `postedAt` only; `createdAt` is not returned.
- The one exception is reconciliation, where items created in the period but not yet posted are the point; `mercury-cash-reconciliation` documents its own filter.
- Pass `status: ["sent"]` so pending transactions, whose final amount may still shift, are excluded from totals unless the user asks for them.

## Debit sign + amount formatting

- Mercury **debits (outgoing spend) are negative**; credits are positive. Use `abs(amount)` when summing spend or comparing against a receipt total.
- Amounts are decimals: `10.00` = $10.00. Preserve full precision; only round when displaying. `getCashflowSummary` is the exception: integer cents, with `outgoingCents` already negative.
- Display amounts with `$` and two decimals (e.g. `$1,234.56`).
- Compute totals programmatically (Python, JavaScript, or jq). Never do financial arithmetic in your head.

## Never echo raw card or account numbers

Responses may include full account or card numbers. When showing data back to the user, mask everything except the last 4 (`****4821`).
