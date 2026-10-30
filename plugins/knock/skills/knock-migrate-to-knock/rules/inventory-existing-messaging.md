---
title: Inventory existing messaging
description: Find providers, templates, send sites, and preference systems in the codebase
tags:
  - migrate
  - discovery
  - inventory
category: knock-migrate-to-knock
last_updated: 2026-07-24
---

# Inventory existing messaging

Search the codebase systematically. Prefer evidence (paths, package names, env vars) over assumptions.

## What to look for

### Providers and SDKs

Check manifests (`package.json`, `requirements.txt`, `Gemfile`, `go.mod`) and imports for:

- Braze, Courier, Customer.io, Iterable, Novu, OneSignal, Pusher Beams
- SendGrid, Postmark, Resend, Mailgun, SES, Twilio, MessageBird
- Firebase / APNs / Expo push
- Slack Bolt / `@slack/web-api`, Microsoft Teams
- In-house `NotificationService`, `mailer`, `notifier` modules

Also scan env examples: `BRAZE_`, `COURIER_`, `SENDGRID_`, `POSTMARK_`, `TWILIO_`, `FCM_`, `APNS_`.

### Send call sites

Find where messages leave the app:

- SDK `send` / `trigger` / `notify` calls
- Job queues that render and send email/SMS/push
- Webhook handlers that fan out notifications
- Cron digests

Record: file path, channel, trigger condition, recipient selection, template location.

### Templates and content

- HTML/MJML/React Email/MJML folders
- Liquid / Handlebars / MJML partials
- Dashboard-only platforms (Braze/Courier): note that content may not live in git; inventory by campaign names referenced in code

### Users, preferences, multi-tenancy

- Preference center UI or `notification_settings` tables
- Unsubscribe / topic flags
- Org/workspace scoping on sends
- Locale / i18n files used for notifications

### In-app surfaces

- Notification bell / feed components
- Banners, modals, paywalls hardcoded in product UI (candidates for [guides](https://docs.knock.app/concepts/guides))

## Output: inventory table

Write the inventory into `knock-plan.md` under a `## Migration inventory` section — do not paste it into chat:

| ID | Current mechanism | Channel(s) | Trigger | Recipient logic | Template location | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| N1 | … | email | … | … | … | … |

Also list in the same section:

- Detected platform(s)
- Whether users are identified with a stable id today
- Whether preferences exist and where
- Estimated volume / criticality (transactional vs marketing) if visible

Chat stays to one status line (platforms + count of message types found).
