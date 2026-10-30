---
title: Setting up the Knock guide providers in a React app
description: How to configure KnockProvider and KnockGuideProvider for rendering guides in React, including required props, where to source each value, and common pitfalls. React-specific, guides-only.
tags:
  - knock-in-app-ui
  - guides
  - react
  - setup
category: knock-in-app-ui
last_updated: 2026-04-23
---

# Setting up the Knock guide providers in a React app

> **Scope:** this rule is React-specific and guides-only. It assumes `@knocklabs/react`. `KnockProvider` is shared with Knock's other in-app products (e.g., feeds), so the `KnockProvider` section below applies regardless of which product you're setting up; `KnockGuideProvider` and everything after it is specific to guides. This skill does not cover feed setup — for that, see https://docs.knock.app/in-app-ui/feeds/overview. For non-React frameworks, stop and ask the user how they'd like to proceed rather than adapting these instructions.

To render guides in a React app you need two nested providers from `@knocklabs/react`: `KnockProvider` at the outer layer (authenticates the user with Knock) and `KnockGuideProvider` inside it (fetches guides for the active guide channel).

References:
- https://docs.knock.app/in-app-ui/guides/render-guides
- https://docs.knock.app/in-app-ui/react/headless/guide

## Install

```bash
npm install @knocklabs/react
```

## Confirm the target Knock environment before running any CLI commands

Knock is environment-scoped: the public API key, the "active" state of each guide, and most CLI operations all differ between environments (typically `development` and `production`, sometimes `staging` or custom slugs). **Before running any `knock` command, confirm with the user which environment they're setting guides up for.** The CLI defaults to `development`, but most real integrations target `production` — do not assume, ask.

**Step 0 — Verify the CLI is authenticated.** The Knock CLI persists a user session locally, but a fresh machine (or a teammate who hasn't used the CLI before) will have none. Run `knock whoami` first:

```bash
knock whoami
```

If it errors (e.g., "not authenticated," "no user session"), run `knock login` and pause until the user finishes the browser flow — the command opens a browser tab and waits for the OAuth callback before persisting the session. Only continue to Step 1 once `knock whoami` returns the expected account. Don't try to auto-discover environments or channels before this check passes; every subsequent command will fail with an auth error and send you into a debugging loop.

**Step 1 — List available environments:**

```bash
knock environment list
```

Present the slugs to the user and ask which one this setup is for. Remember their choice as `<env-slug>` for the rest of the session.

**Step 2 — Pass `--environment <env-slug>` on every subsequent Knock CLI command that is environment-scoped** (guide list, guide push, guide activate, message-type get, etc.). Do not rely on the CLI's default. Example:

```bash
knock guide list --environment <env-slug> --json
```

Note: `knock channel list` is **account-scoped** and does not accept `--environment` — passing the flag will error. Channels are defined at the account level; only per-environment guide/activation state is environment-scoped.

This single choice drives:

- Which `pk_...` public API key the user should paste (each environment has its own — see **Where to get `apiKey`**)
- Which environment subsequent guide pushes, activations, and promotions target

If the user changes environments later (e.g., promoting from dev to prod), re-run the environment-scoped discovery commands with the new `--environment` slug and update the `.env` values that are environment-specific (the `pk_` API key; the `channelId` stays the same across envs since channels are account-scoped).

See the `knock-cli` skill for broader CLI setup and authentication.

## The minimal working setup

```tsx
import { KnockProvider, KnockGuideProvider } from "@knocklabs/react";

const MyApplication = () => {
  const currentUser = useCurrentUser();

  return (
    <KnockProvider
      apiKey={process.env.NEXT_PUBLIC_KNOCK_API_KEY}
      user={{ id: currentUser.id }}
    >
      <KnockGuideProvider
        channelId={process.env.NEXT_PUBLIC_KNOCK_GUIDE_CHANNEL_ID}
        readyToTarget
        listenForUpdates
      >
        {/* Your app components */}
      </KnockGuideProvider>
    </KnockProvider>
  );
};
```

Place these as high in the tree as possible — typically inside your auth boundary and above any route that renders a guide. Do not mount them per-route; guide fetches and websocket connections should live for the session.

## `KnockProvider` props

| Prop | Required | Purpose |
| --- | --- | --- |
| `apiKey` | Yes | Your Knock **public** API key. |
| `user` | Yes | An object identifying the signed-in user. At minimum `{ id }`. |

### Where to get `apiKey`

- Knock dashboard → **Platform → API keys**. Each environment has its own `pk_...` key — switch to the environment the user chose earlier (see "Confirm the target Knock environment") using the environment selector at the top of the dashboard, then copy the public key from that environment's tab. Remind the user explicitly: "copy the public key from the `<env-slug>` environment, not from `<other-env>`" — picking the wrong environment's key silently breaks guide rendering against the right env.
- Use the **public** key (prefixed `pk_`), never a secret key, in client code.
- Store it as an env var. Conventionally `NEXT_PUBLIC_KNOCK_API_KEY` (Next.js) or `VITE_KNOCK_API_KEY` (Vite). The `NEXT_PUBLIC_` / `VITE_` prefix is required so the bundler exposes it to the browser.
- If the user is wiring up both dev and prod at once, use the development `pk_` key locally and the production `pk_` key in your production build, gated by your normal env-per-stage config.

> Unlike `channelId`, the public API key is **not** discoverable from the Knock CLI — the CLI authenticates with a service token, not the public API key. You do need the user to paste this. If the value isn't already present in the project's `.env`, ask for it — but ask only for the API key, and be explicit about which environment's key (e.g., "paste your production `pk_...` key"). Do not bundle this ask with `channelId`; always try the CLI for `channelId` first (see below).

### Where to get `user`

- The `user.id` must match the `id` you use when identifying the user from your backend via Knock's identify API. If those two values drift, the user Knock targets is not the user sitting in front of your app.
- Pull it from your existing auth context (Clerk, Auth0, your own session hook, etc.). Do not hard-code it.
- Do not render `KnockProvider` until the user is loaded. If you pass an empty or placeholder id, guides will be fetched for the wrong user and you will spend an afternoon debugging it.

Production apps should also sign the user with a **user token** for authenticated Knock requests. Add it via the `userToken` prop once you enable enhanced security mode in the Knock dashboard. Generate the token on your backend; never mint it in the browser.

## `KnockGuideProvider` props

| Prop | Required | Default | Purpose |
| --- | --- | --- | --- |
| `channelId` | Yes | — | The UUID of the Knock guide channel this app should read from. This is **not** the channel key (e.g., `knock-guide`). |
| `readyToTarget` | Yes | — | Tells the provider your app is ready to evaluate targeting. Pass `false` until all data needed for targeting (e.g., current route, feature flags, plan tier) is loaded; otherwise guides may be evaluated against stale or missing context. |
| `listenForUpdates` | No | `true` | Opens a websocket so the client re-evaluates guides in real time when content or targeting changes in the dashboard. Leave on unless you have a specific reason to disable it. |
| `targetParams` | No | `{}` | Arbitrary per-render data passed to the server for targeting (e.g., current route, computed flags). See **Passing runtime targeting data** below. |
| `colorMode` | No | `"light"` | `"light"` or `"dark"` — surfaces a theme hint to components that honor it. |
| `trackLocationFromWindow` | No | `true` | When true, the client sends the current URL so path-based activation rules work out of the box. |

### Where to get `channelId`

The prop takes the guide channel's **UUID**, not its key. Knock channels are account-scoped (one channel, one UUID, same across environments), so you typically only discover this once per project.

**Prerequisite:** the user has already chosen a Knock environment (see "Confirm the target Knock environment"). Pass that slug as `--environment <env-slug>` on every CLI command below.

**Procedure — always do step 1 first. Do not ask the user to choose a sourcing strategy or to paste a UUID until step 1 has actually been attempted and failed.** Prompting the user upfront wastes their time and risks a typo; the CLI is the canonical source and, for the default guide channel, it's a one-liner.

**Step 1 — Attempt CLI discovery (default channel key `knock-guide`).** Every Knock account ships with a default guide channel whose key is `knock-guide` and whose `type` is `in_app_guide`. Channels are account-scoped, so this command does **not** take `--environment`:

```bash
# Requires the Knock CLI authenticated to the right account.
# See the knock-cli skill for install/auth.
knock channel list --json | jq -r '.[] | select(.key == "knock-guide") | .id'
```

If this prints a UUID, **use it directly** — write it to `.env` as `NEXT_PUBLIC_KNOCK_GUIDE_CHANNEL_ID` (Next.js) or `VITE_KNOCK_GUIDE_CHANNEL_ID` (Vite) and move on. Do not ask the user to confirm, re-paste, or choose a strategy. The channel ID is not a secret, and for the default channel it is stable — human confirmation adds no value.

**Step 2 — If step 1 prints nothing, try discovery by channel type.** This catches the rare case of a non-default guide channel key:

```bash
knock channel list --json | jq -r '.[] | select(.type == "in_app_guide")'
```

If exactly one `in_app_guide` channel is returned, use its `id`. If multiple are returned, show the user the list (`id`, `key`, `name` for each) and ask which one the app should point at — that is a real ambiguity only the user can resolve.

**Step 3 — Only if both steps above fail, ask the user.** The CLI can fail for legitimate reasons: not installed, not authenticated, pointed at the wrong account, wrong environment slug, or no network. In that case, pause and ask the user to paste the UUID from either:

- **Knock dashboard** → **Settings → Integrations → Channels** → the in-app **guide** channel → channel ID (UUID) on the detail page, or
- **Management API** → `GET /v1/channels` returns `Channel[]`, each with `id`, `key`, and `type`.

Never guess, never substitute the channel key, and never leave a placeholder in `.env`. A wrong or missing `channelId` causes silent rendering failure that is painful to trace back from the UI.

Things to know:

- The channel ID is **not** a secret, but it should still live in an env var so you don't recompile code if it ever changes.
- A wrong channel ID is a very common reason "the guide isn't showing up." Double-check that the UUID you use actually belongs to a channel with `type: in_app_guide`.
- Do not pass the channel key (e.g., `knock-guide`) to `channelId`. The SDK path is `/guides/{channelId}` and expects a UUID.

### When to delay `readyToTarget`

Set `readyToTarget={false}` while you are loading data that your guide targeting depends on, then flip it to `true` once the data is ready:

```tsx
const { plan, isLoading } = useUserPlan();

<KnockGuideProvider
  channelId={process.env.NEXT_PUBLIC_KNOCK_GUIDE_CHANNEL_ID}
  readyToTarget={!isLoading}
  listenForUpdates
>
  {children}
</KnockGuideProvider>
```

If you forget this, guides that target on `plan == "pro"` may silently not match on first render.

## Passing runtime targeting data

Guides can target against arbitrary per-request data you pass at render time (for example, the current route or a computed flag). Pass it via the `targetParams` prop on `KnockGuideProvider`:

```tsx
<KnockGuideProvider
  channelId={import.meta.env.VITE_KNOCK_GUIDE_CHANNEL_ID}
  readyToTarget={!isLoading}
  targetParams={{ plan: user.plan, route: location.pathname }}
>
  {children}
</KnockGuideProvider>
```

Keep the *shape* of this data stable across environments; `"true"` (string) and `true` (boolean) are different values to Knock's rule engine and are the most common cause of "my targeting rule works in dev but not in prod."

## Checklist before moving on to rendering

- [ ] Target Knock environment (`development` / `production` / …) confirmed with the user before running any CLI commands.
- [ ] `KnockProvider` wraps everything that could render a guide.
- [ ] `apiKey` is the public `pk_` key for the chosen environment.
- [ ] `user.id` matches the id you use on the server when identifying users.
- [ ] `KnockGuideProvider` is inside `KnockProvider`.
- [ ] `channelId` is the UUID of the `in_app_guide` channel (not its key). Discovered via `knock channel list --json` (account-scoped — no `--environment` flag).
- [ ] `readyToTarget` is gated on any async data your targeting rules depend on.
- [ ] `listenForUpdates` is on (it is by default).
