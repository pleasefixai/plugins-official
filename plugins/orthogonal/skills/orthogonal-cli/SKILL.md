---
name: orthogonal-cli
description: Use the official Orthogonal CLI to discover and inspect APIs, quote or run endpoints, generate integration code, manage authentication and usage, or browse and publish agent skills. Use for terminal commands, shell pipelines, CI jobs, and CLI troubleshooting. Do not use for application SDK code (orthogonal-sdk), hosted MCP calls (orthogonal), or MCP setup (orthogonal-mcp).
---

# Orthogonal CLI

Use the published `@orth/cli` package and treat `orth <command> --help` as the source of truth for the installed version.

## Install and authenticate

The CLI requires Node.js 18 or newer.

```bash
npm install -g @orth/cli
orth --version
```

For local use, `orth login --key <key>` stores the credential in the operating system's user-config directory. For CI or ephemeral shells, set `ORTHOGONAL_API_KEY`; it takes precedence over the stored credential. Never print, commit, or place a real key in a checked-in command.

Use `orth whoami` to verify the current identity and `orth logout` to remove the stored key.

## Discover before running

```bash
orth api search "search the web"
orth api list
orth api show tavily
orth api show tavily /search
```

Search returns candidates; `api show <slug> <path>` gives the current parameters, schema, and price. Inspect the endpoint before constructing query or body values.

## Run and generate code

```bash
orth run tavily /search -q query="latest AI news"
orth run some-api /v1/generate -X POST -b '{"prompt":"a red bicycle"}'
orth run some-api /v1/generate --dry-run
orth api code tavily /search --lang typescript
```

- `orth run` is shorthand for `orth api run`.
- Repeat `-q key=value` for query parameters, or pass one encoded query string.
- Use `-b` or `-d` for a JSON body and `-X` when the method is not GET.
- Use `--dry-run` to estimate cost without executing the endpoint.
- Use `--raw` for JSON pipelines and `-o <file>` for binary output.
- `orth api code` supports `typescript`, `python`, and `curl` output.

Quote or dry-run expensive, ambiguous, or repeated calls. Confirm the exact target before an endpoint sends messages, creates records, publishes content, makes purchases, or changes external state. Do not automatically retry a non-idempotent call.

## Account and skills

Use `orth balance` and `orth usage` to inspect credits and recent calls.

The `orth skills` command group can list, search, show, install, create, submit, push, update, and request verification for skills. Before publishing or updating a skill, inspect the working tree and confirm the intended owner, slug, and source path; those operations change remote state.

## References

- [CLI documentation and command reference](https://github.com/orthogonal-sh/cli)
- [Orthogonal CLI guide](https://docs.orthogonal.com/cli)
