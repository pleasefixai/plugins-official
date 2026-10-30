---
title: Testing and debugging Knock guides
description: A triage checklist and toolbar workflow for diagnosing why a Knock guide isn't rendering, plus best practices for testing targeting and engagement.
tags:
  - knock-in-app-ui
  - guides
  - debugging
  - testing
category: knock-in-app-ui
last_updated: 2026-04-23
---

# Testing and debugging Knock guides

Reference: https://docs.knock.app/in-app-ui/guides/debugging-guides

## How to respond when a user says "the guide isn't rendering"

Follow this order — do not skip ahead.

1. **Scan for obvious issues first** using only what the user has already shared. Highest-hit culprits:
   - Provider wiring: `KnockGuideProvider` not inside `KnockProvider`, wrong `channelId`, placeholder `user.id`, `readyToTarget` never true.
   - Guide still **Inactive** or **Archived** in the dashboard.
   - Environment mismatch between `pk_` key, `channelId`, and the dashboard view.
   - `useGuide` `type` / `key` doesn't match the message type key / guide key.

   If one jumps out, surface it. Otherwise do **not** go on a fishing expedition reading unrelated files.

2. **Otherwise, nudge the user to enable the guides toolbar before going deeper.** Append `?knock_guide_toolbar=true` to the URL of the page being tested (the app must be inside `KnockGuideProvider`). The toolbar reports whether the guide is active, whether this user is eligible, and which rule filtered it out — in seconds. Wait for its verdict before speculating further.

3. **Use the toolbar's verdict as a jump target into the triage checklist:** "not eligible" → section 2; "eligible but not rendering" → sections 3–4; "eligible, rendering, but engagement missing" → section 5.

Anti-pattern: dumping the full triage checklist at the user before the toolbar has been consulted.

## The guides toolbar

Requirements: `@knocklabs/react` v0.11.13+.

Enable via `?knock_guide_toolbar=true` on any URL inside `KnockGuideProvider`, or from the dashboard's guide channel → **Preview**.

Three viewing modes:

- **All guides** — every guide in the channel.
- **Active guides** — guides live in this environment.
- **Eligible guides** — guides this user qualifies for on this page.

Each row shows status badges (`Inactive`, `Archived`, `Not targeted`, `Not queried`, …) and eligibility indicators. The settings panel toggles sandbox engagement (so tests don't pollute analytics), bypasses throttling, and shows the target parameters the client sent. The **Focus** button forces a guide to render for inspection.

If the toolbar shows the guide as eligible but it still doesn't render, the bug is in your React code, not in Knock targeting.

## Triage checklist

### 1. Is the guide live in this environment?

- Status is **Active** (not Inactive or Archived) in the dashboard.
- You're looking at the right environment — guides and channel IDs are environment-scoped.
- `channelId` on `KnockGuideProvider` matches the channel the guide belongs to.

### 2. Is the user eligible?

- User matches the guide's **targeting rules** (audience, user properties, tenant properties).
- Current page matches the guide's **activation rules** — path patterns are exact unless wildcarded.
- User hasn't already archived this guide — unarchive in the dashboard to re-test.
- Runtime targeting data has the **correct type**. `"true"` (string) ≠ `true` (boolean) — most common targeting bug.

Ground truth: call the Guides API directly with the user's id. If the API returns the guide, the bug is client-side.

### 3. Is the provider configured correctly?

- `readyToTarget` becomes true before you expect the fetch (otherwise the guide is never evaluated).
- `user.id` matches the id your backend identified the user with — a mismatch means Knock evaluates against a user missing the expected properties.
- `listenForUpdates` is on — otherwise dashboard edits don't propagate until reload.

### 4. Is the component code correct?

- `type` / `key` passed to `useGuide` exactly matches the message type key / guide key.
- Guard `if (!step) return null` — a thrown error inside the component can look identical to "not rendering."
- `step.content.<field>` uses the right field names from the message type schema.
- Component is actually mounted on this route.

### 5. Is engagement tracking wired up?

Custom guide components **must** call `markAsSeen`, `markAsInteracted`, and `markAsArchived` themselves — pre-built components do it for you; headless ones don't. Dashboard shows zero engagement on a visibly-rendering guide → almost always this.

## Testing new guides before shipping

- [ ] **Page targeting.** Visit a matching page and a non-matching page; confirm with the toolbar.
- [ ] **User targeting.** Sign in as a qualifying user and a non-qualifying one.
- [ ] **Runtime data.** Test each branch if targeting uses client-provided values.
- [ ] **Engagement.** Fire `seen`, `interacted`, `archived` and confirm each in the dashboard.
- [ ] **Repeat cycle.** Unarchive and re-run to confirm reset works.
- [ ] **Real-time update.** Edit guide content in the dashboard live; confirm the app reflects it without a reload (`listenForUpdates` must be on).

## Gotchas not covered by the triage

- **Archive stickiness.** Once a user archives a guide, it's gone for that user until you unarchive them. Keep a designated test user whose archive state you reset between runs.
- **Throttling.** Guides can be throttled to avoid repeated shows. Bypass throttling in the toolbar settings during testing.
- **Websocket blocked.** Corporate networks and some ad blockers drop the WS. `listenForUpdates` silently no-ops — the initial fetch still works, but dashboard edits won't appear live.
