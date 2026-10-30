---
name: adspirer-search-campaigns
description: Plan and create user-approved paused Google Ads or Microsoft Advertising campaigns from research.
---

# Plan, approve, build paused

Load adspirer-search-mcp. Confirm provider/account, geography, language, objective, landing
page, conversion setup, budget amount/currency, and bid strategy. Read current account state.
Discover actual platform read and write operations before constructing payloads.
Present ad groups, keyword match types, negatives, copy, budgets, and measurement assumptions.
Get explicit approval for the concrete plan before any creation or update.
Set the newly created campaign to paused using the exact schema. If paused creation cannot
be established, stop before creating it. Never enable it as part of routine setup.
Read back campaign status, budget, account, and created resources; report IDs and any
partial failures. Do not blindly retry creations or claim a plan was executed.
Launching later needs separate explicit approval. Never promise conversions or profitability.
