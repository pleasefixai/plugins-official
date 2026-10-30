---
title: Import users into Knock
description: Research the codebase, choose a stable user id, and prepare a bulk-identify script — do not run in production unless asked
tags:
  - setup
  - users
  - identify
  - production
category: knock-setup
last_updated: 2026-07-09
---

# Import users into Knock

Extension rule — **not required on the first setup pass**. Use when preparing for production, or when the user asks to import / sync users into Knock. Can sit on a later production checklist.

## Why this matters

Notification recipients must exist in Knock (or be identified inline at trigger time). For a real product, users need to live in Knock so workflows can address them by a stable id. See [Users in Knock](https://docs.knock.app/concepts/users) and [identifying recipients](https://docs.knock.app/managing-recipients/identifying-recipients).

Knock’s bulk path for an initial import is [bulk identify users](https://docs.knock.app/api-reference/users/bulk/identify) (`POST /v1/users/bulk/identify`, up to 1,000 users per request). Prefer your internal primary key as `id` — it cannot contain `/` or `#`, max 256 chars, and **cannot be changed later**.

## 1. Confirm the primary id (ask first)

Before researching or writing code, ask which field should be Knock’s primary user `id` for later identification. Put the question **last**, on its own line, and bolded.

Recommend the product’s durable internal user id (database primary key / UUID). Email is usually a bad primary id (it can change). Only use email or another field if the user explicitly chooses it.

**What should be the primary Knock user id — your internal user id, email, or something else?**

Do not continue until they answer.

## 2. Research the codebase

Map how users exist in this app:

- Where user records live (DB table/model, auth provider, CRM)
- How to list or page through users safely (ORM, API, export)
- Fields available for Knock: at least `id`; typically `email`, `name`; optionally `phone_number`, `avatar`, `timezone`, custom traits
- Existing env / secrets patterns (`.env`, `.env.local`, secret managers)
- Preferred language/runtime for one-off scripts (Node, Python, etc.)

Keep findings short. Prefer reusing existing data-access helpers over inventing a parallel query path.

## 3. Secret API key in an env var

Bulk identify needs a **secret** API key (`sk_*`) for the target Knock environment — not a public `pk_*` key. Create/copy it from the Knock dashboard (Developer → API keys for that environment).

Use env var name: `KNOCK_API_KEY`.

Offer a command that opens the dashboard and waits for the user to paste the key into `.env.local` (create the file if needed). Prefer running this automatically when the shell allows interactive input:

```bash
open "https://dashboard.knock.app/" && \
  printf "Paste your Knock secret API key (sk_…) for the target environment, then press Enter:\n" && \
  read -r KNOCK_API_KEY && \
  touch .env.local && \
  grep -q '^KNOCK_API_KEY=' .env.local 2>/dev/null \
    && sed -i.bak "s|^KNOCK_API_KEY=.*|KNOCK_API_KEY=${KNOCK_API_KEY}|" .env.local \
    || echo "KNOCK_API_KEY=${KNOCK_API_KEY}" >> .env.local && \
  echo "Saved KNOCK_API_KEY to .env.local"
```

If `open` is unavailable, print the dashboard URL and still run the `read` + write steps. Never commit `.env.local` or echo the key back in chat.

## 4. Write a prepare / bulk-identify script

Add a script that matches the repo’s conventions (language, package manager, lint style). It should:

1. Load `KNOCK_API_KEY` from the environment (fail clearly if missing).
2. Load users from the app’s real data source (reuse existing patterns).
3. Map each row to Knock’s identify shape: required `id` (the field they chose), plus `email` / `name` / other useful fields when present.
4. Call bulk identify in batches of **at most 1,000** users ([API reference](https://docs.knock.app/api-reference/users/bulk/identify)).
5. Default to a **dry-run** that prints batch counts and a sample payload **without** calling the API.
6. Only perform live API calls when an explicit flag is passed (e.g. `--execute`) **and** the user has asked to run it.
7. Target development first unless the user explicitly names production.

Example Node shape (adapt to the stack):

```js
// dry-run by default; pass --execute only when the user asks
import Knock from "@knocklabs/node";

const knock = new Knock({ apiKey: process.env.KNOCK_API_KEY });
const BATCH = 1000;

async function identifyBatch(users) {
  await knock.users.bulk.identify(users);
}
```

Also document the ongoing production pattern: identify on signup / profile update (API or inline identify on workflow trigger) so Knock stays in sync after the initial import — see [identifying recipients](https://docs.knock.app/managing-recipients/identifying-recipients).

## 5. Production safety

- **Do not run the import against production** unless the user explicitly asks to.
- Prefer dry-run → development execute → production execute (only on explicit request).
- Remind them users are **per environment**; a development import does not populate production ([Users FAQ](https://docs.knock.app/concepts/users)).
- After a successful import, suggest verifying a few users in the Knock dashboard under Users.

## Reference docs

- [Users concept](https://docs.knock.app/concepts/users)
- [Identifying recipients](https://docs.knock.app/managing-recipients/identifying-recipients)
- [Bulk identify users](https://docs.knock.app/api-reference/users/bulk/identify)
