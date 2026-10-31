---
name: mcp-server
description: Route calls to ReadMe's MCP server to the right project and the right spec. Use before any request touching the user's own content - "our docs", "my hub", "create a page", "update the changelog", "what endpoints do we have", "search our guides", "how many page views", "top search terms", "send our API logs to ReadMe" - and before calling execute-request for the first time in a session.
---

# Which project does this call land in?

These tools come from ReadMe's server at `https://docs.readme.com/mcp`, which serves **ReadMe's own
documentation**. This plugin does not carry it: if the tools below are missing, ask the user to add it
as a custom server in Settings, with that address (the `readme:mcp-auth` skill has the header that carries
their key).

`search` and `fetch` answer questions about how ReadMe works. The user's project is reached only
through `execute-request` with their API key. Reads and writes land in different places.

Questions about ReadMe itself need nothing else: use `search` and `fetch` and answer.

## Tools on this server

| Tool | Answers for | Use it when |
| --- | --- | --- |
| `search`, `fetch` | ReadMe's own product documentation | The question is about how ReadMe works |
| `list-specs`, `list-endpoints`, `get-endpoint`, `search-endpoints` | ReadMe's API definitions, as documents | Looking up a route before calling it |
| `execute-request` | **The user's project**, with their key | Reading or changing anything of theirs |
| `update-docs`, `draft-changelog` | Nothing. They return instructions for you to carry out | You want the recommended procedure |

Tool availability is per-project configuration, not a fixed list. Call `tools/list` rather than
assuming a tool named here is present, and never assume one that is not.

## The three specs

`execute-request` reaches only servers declared in these definitions. There are three, and
`search-endpoints` searches all of them at once:

| Spec title | Server | Auth |
| --- | --- | --- |
| `ReadMe API` | `https://api.readme.com/v2` | Bearer `rdme_...` |
| `Developer Metrics API` | `https://metrics.readme.io` | HTTP basic, the key as username and an empty password |
| `Legacy API` | `https://dash.readme.com/api/v1` | HTTP basic |

**Use `ReadMe API` for all work on the user's content.** `Legacy API` is v1: it takes basic auth
rather than a bearer token, and it is unavailable to projects on ReadMe Refactored. `search-endpoints`
will surface its routes alongside the others — ignore them. Never fall back to v1 when a v2 call
fails.

## Finding a route

Do not guess paths or work from memory. `list-endpoints` returns every path and summary in a spec in
one cheap call; `get-endpoint` adds the full request and response schema for one of them, including
which routes exist only on ReadMe Refactored. Read them rather than reproducing them here.

Two things the definitions do not tell you:

- Paginated responses carry `paging.next`, `paging.previous`, `paging.first` and `paging.last`.
  Query with `page` and `per_page`, max 100 and max 50 on search.
- Enterprise child projects need the child's own key. Only the API-key routes take a `{subdomain}`,
  and `me` works there.

## Calling execute-request

```json
{
  "title": "ReadMe API",
  "harRequest": {
    "method": "get",
    "url": "https://api.readme.com/v2/projects/me"
  }
}
```

- `title` names the spec and is required whenever the server carries more than one, as this one does.
  Omitting it fails validation before the request is made.
- `url` must be absolute. `get-endpoint` and `search-endpoints` report paths relative to the server
  (`/projects/me`), so prepend `https://api.readme.com/v2` rather than pasting the path through.
- The key decides which project the call lands in, and the user cannot override it per-request.
  Name the project before you change anything; asking them which one to write to is misleading.

Setting up, verifying, or repairing that key is the `mcp-auth` skill.

## When the user asks about their own docs

"Search our docs", "what does our guide say", "find the page about X in my project" cannot be
answered by `search` or `fetch` here. Those read ReadMe's documentation and would return confident,
wrong answers about someone else's content.

Their key already reaches their content through the ReadMe API, so switch tools and carry on rather
than sending them away to configure anything:

| They want | Call, via `execute-request`, spec title `ReadMe API` |
| --- | --- |
| Search their content | `GET https://api.readme.com/v2/search?query=...`, optionally `section`, `version`, `projects` |
| Read one guide | `GET https://api.readme.com/v2/branches/{branch}/guides/{slug}` |
| List what is in a category | `GET https://api.readme.com/v2/branches/{branch}/categories/{section}/{title}/pages` |

`{branch}` is a version number, `stable`, or a branch name. Everything is branch-scoped except
changelogs, images, fonts, API keys, search and the project itself.

## Metrics

Page views, search terms and page quality live in the `Developer Metrics API` spec, and reading them
needs the Enterprise plan — without it the API answers with an auth or plan error rather than saying
so. The registration sends a bearer token; if a call returns `Unauthorized` with a key set, send
`Authorization: Basic <base64 of "<key>:">` on the HAR request instead.

Most of what the dashboard shows has no route at all, so check here before going looking:

| Metric | Readable via API |
| --- | --- |
| Page views, page quality, search terms | Yes |
| API calls | No — ingest only, `POST https://metrics.readme.io/request` |
| MCP tool calls, API errors, top endpoints, new users | No, dashboard only |

For anything in the No rows, send the user to
`https://dash.readme.com/project/{subdomain}/v{version}/metrics`.

Ingesting the user's own API logs is a server-side integration, not something to hand-build here.
Point them at the SDK for their stack — `readmeio` (Node), `readme-metrics` (Python, Ruby),
`readme/metrics` (PHP), `ReadMe.Metrics` (.NET) — and at `fetch` with id `main/sdks`.

## A different server, when they actually want one

Every ReadMe project publishes its own MCP server at `https://{subdomain}.readme.io/mcp`, or its
custom domain. That is for *their* end users to ask questions of *their* published hub. It is a
product feature they set up deliberately, not a workaround for this conversation, and it is not
needed to work on their own docs from here.

A server's hostname decides which project it serves. Enterprise hostnames serve a whole group, so
`search` and `fetch` there can span several child projects.
