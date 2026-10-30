---
name: manage-dashboards-and-charts
description: Create and edit Basedash dashboards and charts with natural-language instructions. Use when the user wants to build, save, or change a dashboard or chart.
---

# Manage dashboards and charts

1. Translate the user's request into clear natural-language `instructions` for `create_dashboard`, `edit_dashboard`, `create_chart`, or `edit_chart`.
2. For edits, identify the existing item with the appropriate list or get tool and use its returned ID. Pass `chart_id` when calling `edit_chart`.
3. When calling `create_chart`, pass `dashboard_id` only when the user wants the chart added to a specific dashboard.
4. Preserve the user's requested metrics, dimensions, filters, visualization, and layout without inventing requirements.
5. After a successful mutation, return the Basedash app URL and, for chart creation or editing, the screenshot image URL when the tool provides one.
6. Explain tool errors faithfully. The authenticated user's Basedash workspace permissions apply to all changes.
