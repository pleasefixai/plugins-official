---
title: Implement a Knock data source
description: Connect a CDP or custom HTTP source, identify users, map events to workflows, and verify with Knock MCP
tags:
  - setup
  - sources
  - identify
  - mcp
category: knock-setup
last_updated: 2026-07-09
---

# Implement a Knock data source

Use this rule when the chosen implementation path is a Knock **source**. Prefer the Knock agent MCP over hand-editing dashboard JSON.

**Knock can ingest events from any system that can send an HTTP POST** (your app, a webhook provider, a CDP, an internal service). Use a [custom HTTP source](https://docs.knock.app/integrations/sources/custom) whenever there is no better fit. Prebuilt providers (Segment, RudderStack, Stripe, Clerk, PostHog, and others) are conveniences with defaults and verification — **not an exhaustive allowlist**. If a product or webhook is not named in this rule or in the docs list you have open, it is still supported via custom HTTP (or via a prebuilt provider the Knock agent can discover). Ask the Knock agent which preconfigured providers exist before assuming custom-only.

Docs overview: [Sources in Knock](https://docs.knock.app/integrations/sources/overview).

## What good looks like

A solid source setup does all of the following in the **development** environment first:

1. **Source exists** for the right integration path (prebuilt provider when available, otherwise custom HTTP).
2. **Identify user is configured** so recipients exist in Knock before (or as) workflows run.
3. **Each built workflow has a trigger mapping** from a real inbound event type to that workflow, with recipients and useful `data` paths.
4. **External system points at Knock's ingestion URL** for this environment.
5. **Verified with real or test traffic** via source event/action logs (not `test_workflow`).

## Choose a source path

Prefer this order:

1. **Prebuilt provider** — if the Knock agent / Platform → Sources offers one for the system already in use (CDP, Stripe, Clerk, etc.). Defaults and signing are easier; docs exist per provider under [integrations/sources](https://docs.knock.app/integrations/sources/overview#available-sources). The links in Reference docs below are **examples only**.
2. **Custom HTTP** — default for anything else: your app’s central event emitter, an unsupported webhook vendor, or a one-off internal service. Any JSON POST works; configure the event-type path (default `body.type`), optional verification, and preprocess as needed. See [custom source](https://docs.knock.app/integrations/sources/custom).
3. **Reverse ETL** (Hightouch, Census, etc.) — mainly for syncing users/objects/tenants, not the primary path for triggering the workflows from this setup skill.

Configure sources under **Platform → Sources** in the dashboard; mappings are **per environment**.

## Identify user (required)

Workflows need a known recipient. For every source you set up, ensure identification is covered in at least one of these ways:

1. **`users_identify` mapping** on identify/signup/profile events (preferred default) — map `user_id`, plus `email` / `name` when present.
2. **Same event as the trigger** — add both identify and trigger-workflow mappings on that event type when the payload has profile fields. Knock runs identify **before** workflow trigger when multiple mappings share an event ([execution order](https://docs.knock.app/integrations/sources/overview#execution-order-for-multiple-mappings)).
3. **Inline recipient object** on the trigger — `recipients` maps to a full user object (`id` + traits), not just an id string.

Do **not** leave triggers mapped only to a bare user id unless you have confirmed users are already identified another way.

## Map events to the workflows you built

For each confirmed workflow:

- Choose the inbound **event type** that should fire it (from the product’s real events, or CDP `track` names).
- Add a **trigger workflow** mapping: recipients path + optional data/actor/tenant paths from the payload.
- Prefer one clear event → one workflow unless the product genuinely needs fan-out.

Field mappings use dot-notation paths into the payload (custom sources: paths under `body.*`; preprocess outputs under `preprocess.*`). See [custom source field mapping](https://docs.knock.app/integrations/sources/custom#field-mapping).

After trigger mappings change, the affected workflows may need a **commit** in that environment before the trigger is live — confirm with the agent/status output.

## Use Knock agent MCP (efficient prompts)

Do the setup through Knock MCP — call `start_knock_agent` (then poll with `get_knock_agent` until done). Pass a **single, complete prompt** so the agent can create the source, identify mappings, and workflow triggers without a long back-and-forth.

**Create / connect a source + wire workflows** (adapt names):

```text
In the development environment, set up a Knock source for [system or provider name].

Requirements:
1. List available preconfigured providers first. Use a prebuilt provider when one matches; otherwise create a custom HTTP source (any HTTP POST JSON webhook is supported).
2. Ensure Identify user is configured (users_identify on identify/signup events, or same-event identify + trigger). Do not leave workflow triggers with bare user ids unless users are already identified.
3. Add trigger-workflow mappings for these workflows and events:
   - [event_name] → workflow `[workflow_key]` (recipients: [path], data: [path if any])
   - …
4. Return the environment ingestion endpoint URL and exact next steps to point [our CDP destination / webhook settings / HTTP client] at Knock.
5. List any workflows that still need committing for triggers to be active.
6. Tell me how to verify with a test event and source logs.
```

**Follow-ups** (reuse `session_id` from the first run):

```text
Inspect source `[key]`: confirm identify mappings exist, list trigger mappings for our workflows, and fix any missing identify coverage.
```

```text
After I send a test `[event_name]`, check source logs (include actions) and confirm the workflow ran for the expected recipient.
```

Keep each MCP prompt self-contained: environment, provider, workflow keys, event names, and identify requirement.

## Wire the external system

After the agent returns the **ingestion URL** for this environment, point the upstream system at it with an HTTP POST of JSON:

- **Prebuilt provider** — follow that provider’s Knock docs / agent instructions (destination URL, signing secret, which events to forward).
- **Custom HTTP / anything else** — POST JSON to the URL; set the event-type path to match your payload; enable verification before production. See [custom source](https://docs.knock.app/integrations/sources/custom).

## How to test

Source-triggered workflows **cannot** be validated with Knock’s workflow test runner. Verify like this:

1. Send a real or synthetic event through the provider (or POST to the custom endpoint).
2. In Knock: **Platform → Sources → [source] → Logs** — confirm the event arrived.
3. Check **action logs** on that event — identify user and/or trigger workflow should appear.
4. Open the workflow’s run / messages for the recipient if a trigger action ran.
5. If the event arrived but no action ran: check event-type path, mapping event name, recipient path, and whether identify left a usable user.

Via MCP, ask the Knock agent to inspect source logs (with actions) for the event name after you send traffic.

## Checklist before moving on

- [ ] Source created in development
- [ ] Identify user mapping (or equivalent) in place
- [ ] Each built workflow has an active trigger mapping from a real event
- [ ] External system configured with the ingestion URL
- [ ] At least one test event shows expected actions in source logs
- [ ] Workflows committed if the agent reported triggers still pending commit

## Reference docs

- [Sources overview](https://docs.knock.app/integrations/sources/overview) — categories, full available-sources list, actions, mapping, execution order, idempotency, debugging
- [Custom HTTP source](https://docs.knock.app/integrations/sources/custom) — **universal path** for any HTTP JSON webhook; event-type path, scripts, field mapping, testing
- Example prebuilt providers (not exhaustive — see overview for the current list, or ask the Knock agent): [Segment](https://docs.knock.app/integrations/sources/segment), [RudderStack](https://docs.knock.app/integrations/sources/rudderstack)
