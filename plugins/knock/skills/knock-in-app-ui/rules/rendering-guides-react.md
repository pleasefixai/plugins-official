---
title: Rendering guides in React with useGuide and useGuides
description: How to build a Knock guide component with the React hooks, including typed content, single vs multiple guides, and engagement tracking. React-specific.
tags:
  - knock-in-app-ui
  - guides
  - react
  - hooks
category: knock-in-app-ui
last_updated: 2026-04-23
---

# Rendering guides in React with useGuide and useGuides

> **Scope:** this rule is React-specific and assumes `@knocklabs/react`. This skill does not yet have rendering guidance for other frameworks — if the user is on Vue, Svelte, plain JS, etc., stop and ask rather than adapting these instructions.

Once providers are in place (see `setup-guide-providers-react.md`), rendering a guide is just a React component that calls `useGuide` or `useGuides`, reads `content`, and reports engagement back to Knock.

References:
- https://docs.knock.app/in-app-ui/guides/render-guides
- https://docs.knock.app/in-app-ui/react/headless/guide

## First guide: discover real guides via CLI before writing code

When finishing a first-time setup (providers just wired up), the goal is the shortest path to the user actually seeing a guide render. **Do not scaffold a component against a placeholder `type` string like `"changelog-card"`** — that component renders nothing until a matching guide is created in the dashboard, and it leaves the user with a broken "first guide" experience. Instead, use the Knock CLI to find a real guide that already exists in the chosen environment, then build the component against its actual values.

Use the same `<env-slug>` confirmed during provider setup (see `setup-guide-providers-react.md` → "Confirm the target Knock environment") for every CLI command below.

**Step 1 — List guides in the chosen environment:**

```bash
knock guide list --environment <env-slug> --json
```

Each entry includes the guide's `key`, `name`, `channel_key`, and `steps[]`. Each step has a `schema_key` (the message type key the hook filters on when called with `{ type }`) and a `schema_variant_key`.

**Step 2 — Pick a guide to render, or create a test one if the environment is empty.**

- **If `knock guide list` returned one or more guides:** show the user the list (`key`, `name`, each step's `schema_key`) and ask which one to use as the first working example. Skip to step 3.

- **If `knock guide list` returned nothing:** do not stop and wait for the user to go create something in the dashboard. Offer to create a test guide on the fly so they reach a rendering state quickly. The default guide channel (`knock-guide`) and the built-in system message types (`card`, `banner`, `modal`) ship with every Knock account, so no upstream setup is required.

  1. Ask which built-in message type the test guide should use: **`card`** (inline, least intrusive — good default), **`banner`** (top/bottom bar), or **`modal`** (blocking overlay). If the user has no preference, default to `card`.

  2. Pull the chosen message type's schema to see its variants and required fields:

     ```bash
     knock message-type get <card|banner|modal> --environment <env-slug> --json
     ```

     Pick the simplest variant (typically `default`) and plan to fill every required field with **obvious placeholder** content so the user can tell it's a scaffold they should edit — e.g., `title: "Hello from Knock"`, `body: "This is a test guide. Edit me in the Knock dashboard."`, CTA text `"Got it"` with action `"#"`. Placeholder-sounding copy is intentional; polished copy on a demo guide looks like real content and invites confusion.

  3. Scaffold the guide with the **Knock CLI** non-interactively by passing every required value as a flag — do **not** let the command drop into its interactive prompts:

     ```bash
     knock guide new \
       --environment <env-slug> \
       --key hello-knock-guide \
       --name "Hello Knock Guide" \
       --message-type <card|banner|modal> \
       --force
     ```

     Use a clearly test-ish `--key` / `--name` like `hello-knock-guide` so the guide is easy to find and delete later. `--message-type` is the built-in chosen in step 1 (`card`, `banner`, or `modal`). `--force` skips the "create this directory?" confirmation. The command writes the scaffold to `./guides/<guide-key>/` (or the project's configured guides directory). Edit the generated files to fill in the message type's required fields with placeholder content and confirm `channel_key` matches the guide channel the app is pointing at (the default is `knock-guide`; cross-check against the `channelId` picked during provider setup). Leave targeting at the default "All users" and omit activation rules so it renders on any page. Push **and publish** it with `knock guide push <guide-key> --environment <env-slug> --commit --commit-message "scaffold test guide"`. The `--commit` flag is required — without it the guide is uploaded but not published, so the guide API (and therefore `useGuide`) will not return it. After the push succeeds, **delete the local scaffold directory** (`rm -rf ./guides/<guide-key>`) — the guide now lives in Knock and the local files are scaffolding artifacts, not source-of-truth.

  4. **Activate** the new guide in the chosen environment with `knock guide activate <guide-key> --environment <env-slug> --status true` (add `--force` to skip the confirmation prompt). Rendering requires an active guide — a created-but-inactive guide will silently not appear and send you back to debugging.

  5. Re-run `knock guide list --environment <env-slug> --json` to confirm the new guide appears, then continue to step 3 with its `key`.

**Step 3 — Choose `{ key }` vs `{ type }` for the hook.**

- Use `{ key }` (the guide's unique key) for a first-render smoke test. It targets exactly one guide and avoids ambiguity if several guides share the same message type.
- Use `{ type }` (the step's `schema_key`) when the surface should render *any* current or future guide of that message type — typical for long-lived slots like a banner or modal container.

For the initial setup, default to `{ key }`. It maps one-to-one with what the user just picked from the list.

**Step 4 — Pull the message type schema so the content is typed.** The step's `schema_key` names the message type; fetch its schema and mirror it in the component's TypeScript generic so `step.content.<field>` is type-checked:

```bash
knock message-type get <schema_key> --environment <env-slug> --json
```

Use the variant's fields (e.g., `title`, `body`, CTA fields) to define the type passed to `useGuide<T>` — see the minimal example below for the pattern.

**Step 5 — Build the component** with the real `key` (or `type`), the typed content, and engagement wired up (`markAsSeen`, `markAsInteracted`, `markAsArchived`). Drop it into a stable location in the app tree (not inside a `Suspense` boundary that remounts).

**Step 6 — Flag what still needs the user.** After the component compiles, some things cannot be automated — call these out explicitly rather than letting the user discover them by absence:

- `pk_...` public API key from **Platform → API keys** for the chosen environment, pasted into `.env` (not discoverable via CLI).
- The chosen guide must be **active** in this environment (dashboard toggle).
- The current user and current route must match the guide's targeting and activation rules. The defaults ("All users", no page rules) are usually permissive enough for the first render.
- Restart the dev server if `.env` was just edited.

If nothing renders after all of the above, go to `debugging-guides.md` and work the triage checklist.

## Pick the right hook

| Hook | Returns | Use for |
| --- | --- | --- |
| `useGuide({ type })` | A single `step` — the next eligible guide of that message type | Banners, modals, tooltips, paywalls — any surface that shows at most one thing at a time |
| `useGuide({ key })` | A single `step` — a specific guide by its unique key | Rendering one specific guide by id |
| `useGuides({ type })` | An array of `guides` | Lists (e.g., changelog cards in a sidebar) |

Guides surfaced by `useGuide` are filtered by eligibility, throttled, and ordered server-side — if the hook returns nothing, that is usually the correct answer, not a bug. See `debugging-guides.md` for how to verify.

## Single guide: minimal example

```tsx
import { useEffect } from "react";
import { useGuide } from "@knocklabs/react";

type ChangelogCardAttrs = {
  title: string;
  body: string;
};

export const ChangelogCard = () => {
  const { step } = useGuide<ChangelogCardAttrs>({ type: "changelog-card" });

  useEffect(() => {
    if (step) step.markAsSeen();
  }, [step]);

  if (!step) return null;

  return (
    <div onClick={() => step.markAsInteracted()}>
      <h3>{step.content.title}</h3>
      <p>{step.content.body}</p>
      <button
        onClick={(e) => {
          e.stopPropagation();
          step.markAsArchived();
        }}
      >
        Dismiss
      </button>
    </div>
  );
};
```

Key points:

- Always guard on `if (!step) return null` before rendering — the user may not be eligible.
- The generic on `useGuide<T>` types `step.content`. Define the type to match the fields in the Knock **message type** so the compiler catches drift.
- `markAsSeen` in a `useEffect` keyed on `step` is the idiomatic place to record the impression. Guard with `if (step)` because `useEffect` still runs when the hook returns nothing.
- `markAsInteracted` goes on the primary action (the card click, the CTA, whatever counts as "they engaged").
- `markAsArchived` removes the guide for this user so it will not be returned again — use it for dismiss buttons.

## Multiple guides: list example

```tsx
import { useGuides } from "@knocklabs/react";

const ChangelogList = () => {
  const { guides } = useGuides({ type: "sidebar-changelog-card" });

  return (
    <div>
      {guides.map((guide) => (
        <div key={guide.key}>
          <h3>{guide.steps[0].content.title}</h3>
          <p>{guide.steps[0].content.body}</p>
        </div>
      ))}
    </div>
  );
};
```

When you render a list, you own the engagement tracking per item. A common pattern is an intersection observer that calls `guide.steps[0].markAsSeen()` the first time each card scrolls into view.

## Advanced: `useGuideContext`

```tsx
import { useGuideContext } from "@knocklabs/react";

const { client: guideClient } = useGuideContext();
```

Reach for this when you need to manually refetch, inspect state, or do something the hooks do not expose. Most components should not need it.

## Matching the component to the dashboard

A guide component is a contract between code and the dashboard:

1. **Message type** in the dashboard defines the content schema (`title`, `body`, `cta_text`, etc.).
2. The TypeScript type on `useGuide<T>` mirrors that schema.
3. The `type` string passed to the hook matches the message type's key.

If a field is renamed in the dashboard, the type and the render code both need to update. Keep the type definition near the component so reviewers see both at once.

## Shipping a new guide component: workflow

1. Decide the UX (banner / modal / card / tooltip) and where it renders.
2. In the Knock dashboard, create or reuse a **message type** whose schema matches what the UI needs (`title`, `body`, `cta_text`, `cta_url`, etc.). If the UI needs structured data the message type doesn't have, add fields first.
3. Build the React component. Call `useGuide` (or `useGuides`) with the message type key as `type`. Type the content generic to the message type schema.
4. Wire engagement: `markAsSeen` on mount, `markAsInteracted` on the primary action, `markAsArchived` on dismiss.
5. Create a guide in the dashboard using that message type. Set targeting and activation rules.
6. Test with the guides toolbar (see `debugging-guides.md`).

## Common pitfalls

- **Forgetting the `if (!step) return null` guard.** Causes a crash on any user who isn't eligible.
- **Calling `markAsSeen` unconditionally on render.** Use `useEffect` keyed on `step` so it fires once per fetched guide, not every render.
- **Mismatched `type` string.** The string passed to `useGuide` must match the message type key exactly, including case.
- **Treating `markAsArchived` like `markAsInteracted`.** `markAsArchived` removes the guide from future fetches for this user. Use it for dismissal, not for "the user clicked the card."
- **Rendering inside `Suspense` boundaries that unmount on refetch.** Causes `markAsSeen` to fire repeatedly. Mount guide components in a stable part of the tree.
