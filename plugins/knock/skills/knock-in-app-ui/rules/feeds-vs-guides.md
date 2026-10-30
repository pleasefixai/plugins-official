---
title: Choosing between Knock feeds and guides
description: When to use feeds versus guides for Knock in-app UI, and how the two systems differ in data model, targeting, and rendering.
tags:
  - knock-in-app-ui
  - feeds
  - guides
  - architecture
category: knock-in-app-ui
last_updated: 2026-04-22
---

# Choosing between Knock feeds and guides

Knock's in-app UI has two products: **feeds** and **guides**. They solve different problems and use different data models. Pick the wrong one and you will fight the SDK. Pick the right one and the heavy lifting is already done.

Reference: https://docs.knock.app/in-app-ui/feeds-vs-guides

## The core difference

- **Feeds** are *pre-generated*. Workflows and broadcasts write messages into a per-user feed ahead of time. The UI renders a chronological list.
- **Guides** are *evaluated at render time*. Targeting and activation rules are checked when the client fetches, and the server returns only guides the user is currently eligible for.

If the mental model is "inbox of things that happened," you want feeds. If the mental model is "is this user in a state where we should show this UI right now," you want guides.

## When to use feeds

Pick feeds for:

- Notification centers, inboxes, bell menus
- Chronological lists of per-user events
- Anywhere you need read/unread/seen/archived status and badge counts
- Lists that should support filtering and aggregate counts

Feeds ship with pre-built React, React Native, iOS, and Android components, plus a headless path for custom UIs.

Reference: https://docs.knock.app/in-app-ui/feeds/overview

## When to use guides

Pick guides for:

- Announcements, banners, modals, tooltips, inline cards
- Upgrade prompts, paywalls, onboarding steps
- Outage notifications and feature announcements
- Any UI whose visibility depends on user attributes, audience membership, or the current page
- Any content a non-engineering team should be able to change without a deploy

Guides evaluate **targeting rules** (who) and **activation rules** (where in the app) every time the client fetches. Content lives in the dashboard, keyed by a **message type** schema your engineering team defines once.

Reference: https://docs.knock.app/in-app-ui/guides/overview

## Quick decision table

| Question | Feeds | Guides |
| --- | --- | --- |
| Is it a list of past events? | ✅ | ❌ |
| Does it depend on the current route or runtime state? | ❌ | ✅ |
| Do non-engineers need to change copy without shipping code? | Maybe | ✅ |
| Do you need read/seen/archived status per message? | ✅ | Partial (engagement tracking only) |
| Is it a modal, banner, tooltip, or inline card? | ❌ | ✅ |
| Is it a notification center? | ✅ | ❌ |

## Common mistakes

- Trying to build a notification center out of guides. Guides are not designed for pagination and chronological history.
- Trying to build a page-targeted modal out of feed items. Feeds have no concept of activation rules.
- Assuming guides carry the same read/unread semantics as feed items. Guides have `seen`, `interacted`, and `archived` engagement events; they are not a drop-in replacement for feed status.

When a product surface needs both a notification bell *and* a targeted onboarding modal, use both products side by side — wrap the app in `KnockProvider` once, then render whichever provider you need for each surface.
