---
name: secrets-exposure
description: Find exposed or stale credentials (API keys, tokens, passwords in code, chat or documents) and the identities they belong to. Use when the user asks "do we have leaked keys", "which secrets are in this repo", or "what does this secret unlock".
---

# Secrets exposure

Use the `token-security` MCP server. It exposes three meta-tools: `search` finds the underlying tool by name or intent, `get_schema` returns its arguments, `execute` runs it. The tool names below are what you pass to `search` and call inside `execute`. Everything is read-only.

1. `query_secrets` with the user's filter: source (code repository, chat, documents, cloud), repository or project name, owner, age. Page through when the total exceeds one page.
2. For a secret the user asks about, `resolve_entity_links` to reach the identity it authenticates as, then `get_identity_details` and `get_entity_graph` for what that identity can do.
3. `query_issues` filtered on the secret or its identity for open findings; `get_issue_details` for the remediation the finding carries.

Never print a secret value, even partially; the tools return metadata and locations, and that is all the user needs. Answer with location, secret type, which identity it unlocks, the reach of that identity, and the fix (rotate at the source platform, remove from the location, scope down).
