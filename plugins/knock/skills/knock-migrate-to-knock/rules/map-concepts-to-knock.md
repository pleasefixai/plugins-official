---
title: Map concepts to Knock
description: Translate existing messaging platform and custom code concepts into Knock primitives
tags:
  - migrate
  - mapping
  - concepts
category: knock-migrate-to-knock
last_updated: 2026-07-23
---

# Map concepts to Knock

Use the platform-specific tutorials when they apply:

- [Migrate from Braze](https://docs.knock.app/tutorials/migrate-from-braze)
- [Migrate from Courier](https://docs.knock.app/tutorials/migrate-from-courier)

For everything else, use this generic map and link Knock concept docs in the plan.

## Generic mapping table

| Current concept | Knock concept | Docs |
| --- | --- | --- |
| ESP / SMS / push provider config | [Channels](https://docs.knock.app/concepts/channels) | https://docs.knock.app/integrations/overview |
| Campaign, Canvas, Automation, notification definition | [Workflow](https://docs.knock.app/concepts/workflows) | https://docs.knock.app/concepts/workflows |
| API trigger / send call | [Trigger workflow](https://docs.knock.app/send-notifications/triggering-workflows) | https://docs.knock.app/send-notifications/triggering-workflows |
| Recipient profile | [User](https://docs.knock.app/concepts/users) | https://docs.knock.app/concepts/users |
| Content blocks / layouts | [Partials](https://docs.knock.app/template-editor/partials), email layouts | https://docs.knock.app/template-editor/overview |
| Topics / subscription categories | Workflow [categories](https://docs.knock.app/concepts/workflows#workflow-categories) + [preferences](https://docs.knock.app/preferences/overview) | https://docs.knock.app/preferences/overview |
| Lists (entity followers) | [Subscriptions](https://docs.knock.app/concepts/subscriptions) on [objects](https://docs.knock.app/concepts/objects) | https://docs.knock.app/concepts/subscriptions |
| Marketing / lifecycle segments | [Audiences](https://docs.knock.app/concepts/audiences) (can [trigger workflows on entry](https://docs.knock.app/send-notifications/triggering-workflows/audiences)) | https://docs.knock.app/concepts/audiences |
| Workspace / account branding | [Tenants](https://docs.knock.app/multi-tenancy/overview) | https://docs.knock.app/multi-tenancy/overview |
| Locale strings for notifications | [Translations](https://docs.knock.app/template-editor/translations) | https://docs.knock.app/template-editor/translations |
| CDP events | [Sources](https://docs.knock.app/integrations/sources/overview) | https://docs.knock.app/integrations/sources/overview |
| In-app bell / inbox | [Feeds](https://docs.knock.app/in-app-ui/overview) | https://docs.knock.app/in-app-ui/feeds-vs-guides |
| Hardcoded banners / paywalls | [Guides](https://docs.knock.app/concepts/guides) | https://docs.knock.app/concepts/guides |
| Liquid / Handlebars templates | Knock [Liquid](https://docs.knock.app/template-editor/reference-liquid-helpers) templates | — |

## Platform notes

### Braze

Follow the Braze tutorial mapping: campaigns/Canvases → workflows, Content Blocks → partials, custom attributes → user properties, attribute-based "tenants" → Knock tenants where appropriate.

### Courier

Follow the Courier tutorial: Automations + templates → workflows, Lists → subscriptions, Brands/tenants → Knock tenants, Topics / Preference Sections → workflow categories powering preferences.

### Customer.io / Iterable / similar

Treat campaigns/journeys as workflows, people as users, attributes as user properties, subscription topics as workflow categories for preferences. Prefer API-triggered transactional flows first.

### Direct ESP / custom mailer

Each distinct message type (password reset, invite, receipt) → one workflow with an email channel step. Shared header/footer → partials + email layout. Replace direct provider SDK calls with Knock trigger calls after workflows exist.

### Slack / Teams ops alerts

Map to chat channel steps on workflows. Keep recipient logic (channel vs user) explicit in the plan.

## Per-item mapping output

For each inventory row, fill:

```markdown
### [ID] [Name]
- **Today.** …
- **Knock shape.** workflow | guide | feed message | preference-only
- **Channels.** …
- **Trigger.** event / API / audience / schedule
- **Data to pass.** …
- **Preferences.** category or transactional exemption
- **Docs.** links
- **Migration risk.** low | medium | high — why
```
