---
name: add-infrastructure
description: Add infrastructure primitives (databases, Pub/Sub, cron jobs, caching, object storage, secrets) to an Encore service. Use when the user wants to add a database, queue, cache, storage bucket, cron job, or secret.
---

# Add Infrastructure to an Encore Service

## When to use

- User wants to add a database, pub/sub topic, cron job, cache, object storage bucket, or secret
- User mentions needing background jobs, message queues, or scheduled tasks

## Instructions

1. Use the MCP server (`get_services`, `get_databases`, `get_pubsub`) to understand existing infrastructure before adding new resources.

2. Declare infrastructure at the module level, not inside functions. Infrastructure declarations are static.

3. For databases:
   - Use `new SQLDatabase("name", { migrations: "./migrations" })`
   - Create migration files in the service's `migrations/` directory
   - Migration files must be numbered: `1_create_tables.up.sql`, `2_add_index.up.sql`

4. For Pub/Sub:
   - Define a typed `Topic` with a delivery guarantee
   - Create `Subscription` handlers in the consuming service
   - The topic and subscription can be in different services

5. For cron jobs:
   - Use `new CronJob("name", { every: "1h", endpoint: fn })` or `new CronJob("name", { schedule: "0 * * * *", endpoint: fn })`
   - The endpoint must be an existing API endpoint in the same service
   - `every` takes duration strings: `"1h"`, `"30m"`, `"2h"`. `schedule` takes cron expressions.

6. For caching:
   - Create a `CacheCluster`, then define `CacheKeyspace` instances with typed keys and values
   - Always set a `defaultExpiry`

7. For object storage:
   - Use `new Bucket("name", { versioned: false })`

8. For secrets:
   - Use `secret("SecretName")` from `encore.dev/config`
   - Tell the user to set values with `encore secret set --dev SecretName`

## Key rule

All infrastructure is declared in code. Never create Terraform files, Docker Compose files, or YAML configuration. Encore provisions everything automatically.
