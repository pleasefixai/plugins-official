---
name: deploy-lovable-project
description: Publish a Lovable project and confirm the live deployment, then check basic traffic. Use when someone wants the app shipped or wants to see how a deployed app is doing.
---

# Deploy a Lovable project

## When to use

- The work is ready and someone wants it live.
- Someone wants to know how an already-deployed project is doing.

## Before you deploy

1. Confirm the project with `get_project` and look at the current state through `get_diff` or the `preview_url`.
2. Make sure the change someone asked for is actually in. A reply saying it is done is not enough; see it in the diff or the preview.
3. If it uses Lovable Cloud, check `get_database_status` so you are not shipping an app whose backend is missing.

## Deploy

1. Call `deploy_project`.
2. Share the resulting live URL and the `preview_url` so the deployed app can be opened.

## After deploy

- Use `get_project_analytics` for visitor counts over time and `get_project_analytics_trend` for live traffic when someone asks how it is doing.
- To branch off a deployed app for an experiment, use `remix_project` rather than risking the live one.
