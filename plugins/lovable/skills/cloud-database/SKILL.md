---
name: enable-lovable-cloud-database
description: Provision and inspect a Lovable Cloud Postgres database, and run SQL safely. Use when a project needs data, or when you need to read or fix rows directly.
---

# Lovable Cloud database

## When to use

- A project needs to store data, sign users in, or hold files.
- You need to read the current data, check a schema, or apply a one-off fix.

## What this touches

Lovable Cloud provisions a Postgres database with auth, storage, and edge functions. `query_database` runs with full permissions against the real database, so handle it like production.

## Provisioning

1. Call `get_database_status` to see whether a database already exists.
2. If none exists, call `enable_database`. It takes about 30 to 60 seconds. Wait, then re-check `get_database_status` instead of querying right away.

## Reading data

- Use `query_database` for inspection. Select only the columns you need and add a LIMIT while you explore.
- Summarize what you find back to the person, including row counts, so the state is clear.

## Changing data or schema

- For changes the app relies on (new tables, columns the UI reads), describe them to the Lovable agent with `send_message` so the generated code and the database move together. Editing schema underneath the app by hand leads to drift.
- Use `query_database` writes for genuine one-off fixes and reporting.
- Before any write or destructive statement, show the exact SQL and confirm it is wanted. Do not run DROP, DELETE, TRUNCATE, or ALTER speculatively.

## After changes

Report what ran and what it affected. If the schema changed, point the Lovable agent at it so the app keeps up.
