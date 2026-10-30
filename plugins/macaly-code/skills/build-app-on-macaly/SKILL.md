---
name: build-app-on-macaly
description: Build and host a real web app on Macaly when the user asks for a new standalone app or website (e.g. "build a customer feedback dashboard", "build a landing page for X"), or wants changes to an app previously built on Macaly. Uses the Macaly Cloud MCP tools instead of scaffolding local files.
---

Macaly provides the git repo, cloud sandbox, build, hosting and publishing; you write
the code through the `macaly-cloud` MCP server's tools. Do NOT scaffold or write files
on the local filesystem for this work, and do not `npm create`/`vite`/`next` a local
project — the app lives in Macaly.

## The loop

1. `create_app({ name })` — creates an empty app and returns a `chatId` plus a
   **briefing** (stack, boundaries, conventions). **Read the briefing** — it is the
   contract. Apps are TanStack Start + Vite + Tailwind with Convex as the backend.
   (Pass `teamId` only if `create_app` says you belong to several teams; `list_teams`
   finds the id.)
2. `write_file({ chatId, path, content })` for each file — every call is its own git
   commit. Write full file contents (no partial edits). Keep `src/routes/__root.tsx`'s
   `<MacalyBridge>` if you touch it.
3. Typecheck after your last write with `bash`: run `.sandbox/check-errors` with
   `timeoutSeconds: 120`. On failures, `get_logs` (build | dev_server | deploy) has
   the real output.
4. Need a database, auth, payments, media, or search? `skill_info({ chatId, skill })`
   to read the guide, then **execute its commands with `bash`**. It runs inside the
   project sandbox, which has `$MACALY_API_TOKEN`/`$MACALY_BASE_URL`/`$MACALY_CHAT_ID`
   set and the skill scripts under `.macaly/skills/`, so the guide's commands run
   verbatim (e.g. the setup-convex-db script provisions Convex end-to-end).
5. Env vars live in the app's root `.env.local` — setup skills write it via `bash`;
   for a standalone change, `read_file` it and `write_file` the merged result,
   preserving lines you don't touch (especially `CONVEX_DEPLOYMENT`).
6. When the app is ready to show, `preview_app({ chatId })` — it returns a preview
   URL to share with the user.
7. Only when the user asks to go live: `publish_app({ chatId })`, then poll
   `get_deployment` until READY. The preview URL works before that.

## Reporting back

Give the user the preview URL (and the live URL after publish). Keep the local
working directory clean — nothing from a Macaly build belongs in local files.
