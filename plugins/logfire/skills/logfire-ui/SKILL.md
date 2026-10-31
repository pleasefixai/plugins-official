---
name: logfire-ui
description: Open or return Logfire project pages, live views, trace links, and Explore pages without querying telemetry first. Use this skill when the user asks to "open in Logfire", "show in the live view", "open Explore", "open the UI", "use the browser", "give me a link", or asks for a Logfire GUI/browser/live-view presentation of a project, time range, service, span, trace, log, or filter. If "show" or "view" wording is ambiguous, ask whether the user wants a UI view or query analysis.
---

# Open Logfire UI

Use this skill for direct Logfire UI, browser, live-view, link, and Explore-page requests.

## User-Facing Progress

Keep progress updates quiet. Do not narrate why this skill was selected, restate routing rules, quote local instructions, explain token scope, or announce routine helper calls. If an update is needed, use one short sentence focused on the action, such as "Opening Logfire with the error filter."

After opening Logfire, do not run or narrate an extra page-state check unless the browser appears stuck, asks for login, or the user explicitly asked you to verify the page.

## Browser Targeting

Return the clean Logfire URL for the user to open.

Do not use `agent-browser`, `chrome-devtools`, `mcp__chrome_devtools__*`, `mcp__playwright__*`, macOS `open`, `xdg-open`, standalone Playwright/Chromium, a shell-launched browser, web preview cards, or a newly created external browser window unless the user explicitly asks for an external browser. Do not silently fall back to any external or dedicated browser window.

## Core Rule

For project-level or aggregate UI requests, open or return Logfire directly by URL.

Do not query telemetry first:
- Do not call `query_run`.
- Do not say you will query Logfire or fetch spans first.

Only query first when the user asks to open a specific unknown item that must be found first, such as "open the slowest trace" or "open the latest error trace".

If the request is ambiguous, such as "show recent errors" or "view logs", ask whether the user wants Logfire opened in the UI or a query analysis in chat. Do not do both unless the user explicitly asks for both.

## Project Discovery

For UI requests without an explicit organization/project, first try to resolve the canonical project URL through the Logfire server's auth/current-project metadata. Use a project-link or current-project helper if the server exposes one. This is project discovery, not telemetry querying.

This plugin does not carry the Logfire server. If its tools are not available, ask the user to add `https://logfire-us.pydantic.dev/mcp` (EU region: `https://logfire-eu.pydantic.dev/mcp`) as a custom server in Settings, where it signs in with OAuth; until then, ask for the organization/project or full Logfire project URL.

If the server can resolve exactly one current project, use that project URL. If it cannot resolve a project, resolves multiple candidates, or returns an auth/error state, ask the user for the organization/project or full Logfire project URL.

Do not infer the project URL from `LOGFIRE_BASE_URL`, `LOGFIRE_URL`, exporter config, repository names, or localhost reachability. Env/config values can identify the Logfire platform/API base, but they do not by themselves identify the target organization/project.

## URL Workflow

1. If the full project URL is already known, use it directly.
2. If the user omits the project, resolve the current project through the Logfire server as described above.
3. If the user gives a project name but not the organization/base URL, call `project_logfire_ui_link(project=project)` with the default clean-link behavior to derive the canonical project URL. This is a URL discovery helper, not a telemetry query.
4. For project live-view/filter URLs, call `project_logfire_ui_link(project=project, query=query, since=since, until=until, handoff=True)` only when the link will be opened immediately in a browser the user asked for. Use the default clean-link behavior when returning a durable or shareable URL. If the user provides an existing clean Logfire project URL and asks for handoff, parse its project, `q`, `since`, and `until` values and pass them through this tool.
5. If the user gives or the query workflow has already found a real `trace_id`, call `project_logfire_link(trace_id=trace_id, project=project, handoff=True)` only when the link will be opened immediately in a browser the user asked for. Use the default clean-link behavior when returning a durable or shareable URL.
6. Add `query`, `since`, and `until` through `project_logfire_ui_link` when useful. If manually assembling a clean URL, URL-encode `q`, `since`, and `until`.
7. Return the URL rather than launching an external browser, unless the user explicitly asked for one.

## Browser Handoff URLs

When the Logfire server's link tools support `handoff: bool = False`, use `handoff=True` only for a URL that will be opened immediately in the browser. A handoff URL is short-lived, single-use, and bound to the destination minted by the platform.

- If the handoff result is a string, open that exact URL promptly. It may be an `/api/auth/handoff?ticket=...` URL. Do not add query params to it, rewrite it, persist it, quote it in docs, or treat it as shareable.
- If the handoff result is an object with `handoff: false`, use its `url` value as the clean fallback URL. Mention `reason` only when it helps the user understand why the browser may still ask for login, such as API-key auth or a need to re-authenticate.
- If the reason says to re-authenticate the Logfire server's connection, explain that its OAuth refresh token is missing the metadata needed to mint a UI session. Do not describe this as a browser-session refresh; the user needs to reconnect the Logfire server in Settings.
- If the server does not expose `handoff`, call the link tool normally and use the clean URL.
- Do not manually append filters or time params to a handoff URL. Put the final project filter destination into `project_logfire_ui_link` and let the platform mint the ticket for that destination.

## Common Filters

- Spans: `q=kind%3D%27span%27`
- Logs: `q=kind%3D%27log%27`
- Exceptions: `q=is_exception%3Dtrue`
- Errors: `q=level%3D%27error%27`
- Service: URL-encode a filter such as `service_name='api'`

## Example

For "open the Logfire live view for spans in starter-project for the last hour":

1. Open the known or derived `starter-project` Logfire URL directly.
2. Add `q=kind%3D%27span%27`.
3. Add `since=<one-hour-ago>` and `until=<now>`.
4. Return the URL.
5. Do not run SQL first.

For "find the slowest trace and open it", use the query workflow only to identify the trace, then use `project_logfire_link(trace_id=trace_id, project=project)` and return that link.

## Auth Boundary

Do not try to pass MCP auth tokens into the browser or Logfire UI. Never put bearer, API, read, or write tokens in URL query parameters, fragments, pasted browser instructions, logs, or notes. MCP/tool authentication and browser web sessions are separate security contexts.

For immediately opened UI links, prefer the platform handoff described above. If handoff is unavailable, fall back to the clean URL and explain the specific fallback reason when useful. A missing browser cookie may require normal browser login; a stale OAuth connection of the Logfire server requires reconnecting it in Settings instead.
