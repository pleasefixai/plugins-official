---
name: discover-company-data
description: Discover the data sources available through Basedash. Use when the user asks what company data, databases, warehouses, or SaaS sources are available.
---

# Discover company data

1. Call `get_data_sources` before describing what company data is available.
2. Report only sources returned by the tool; do not infer sources that were not listed.
3. Explain that results are limited to sources the authenticated user can access in their Basedash workspace.
4. Use `ask_question` only if the user also asks for a metric, lookup, trend, or analysis.
