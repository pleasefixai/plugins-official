---
name: analyze-company-data
description: Use Basedash to answer questions about company metrics, trends, lookups, and analysis over connected data sources.
---

# Analyze company data

1. Call `ask_question` with the user's question.
2. When continuing an existing Basedash conversation, pass its `chat_id` so the analysis keeps the prior context.
3. If the user first needs to know what data is available, call `get_data_sources`.
4. Treat tool results as limited to sources the authenticated user can access in their Basedash workspace.
5. Report the returned result faithfully. Do not invent SQL, numbers, sources, or conclusions that the tool did not return.
6. If the user asks to save the result as a chart, call `create_chart` with clear natural-language instructions and include `dashboard_id` when they selected a dashboard.
