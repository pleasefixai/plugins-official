---
name: create-service
description: Create a new Encore service with API endpoints, database, and infrastructure. Use when the user wants to add a new service, create endpoints, or scaffold a new part of their backend.
---

# Create an Encore Service

## When to use

- User wants to create a new service or microservice
- User wants to add API endpoints
- User wants to scaffold a new backend feature

## Instructions

1. Create a new directory for the service at the project root.

2. Add `encore.service.ts` (TypeScript) or a Go package file:

**TypeScript:**
```typescript
import { Service } from "encore.dev/service";
export default new Service("service-name");
```

3. Add API endpoints in a separate file. Use typed request/response interfaces.

4. If the service needs a database, declare it with `SQLDatabase` and create a `migrations/` directory with numbered SQL migration files (e.g., `1_create_tables.up.sql`).

5. If the service needs to communicate asynchronously, use `Topic` and `Subscription` from `encore.dev/pubsub`.

6. Use the MCP server to inspect existing services (`get_services`) before creating new ones to follow existing patterns.

7. After creating files, tell the user to run `encore run` to start the app with the new service.

## Checklist

- [ ] Service definition file exists (`encore.service.ts`)
- [ ] API endpoints use `api()` from `encore.dev/api` with typed request/response
- [ ] Database migrations are numbered SQL files in `migrations/`
- [ ] Secrets use `secret()` from `encore.dev/config`, not environment variables
- [ ] Service name is lowercase, no special characters
