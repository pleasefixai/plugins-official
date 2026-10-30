---
name: inspect-dashboards-and-charts
description: List and inspect dashboards and charts available through Basedash. Use when the user wants to find, review, or understand existing dashboards or charts.
---

# Inspect dashboards and charts

1. Call `list_dashboards` or `list_charts` to discover items available to the authenticated user.
2. Call `get_dashboard` or `get_chart` when the user selects an item or asks for its details.
3. Use identifiers returned by the list tools rather than guessing them.
4. Report only information returned by the tools, and explain when no accessible items match.
5. Treat results as limited by the authenticated user's Basedash workspace permissions.
