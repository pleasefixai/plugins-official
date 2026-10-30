---
name: identity-blast-radius
description: For a user, service account, role, key or other identity, show what it can reach across platforms, who owns it, and how it has been used. Use when the user asks "what can X access", "who owns X", "is X still used", or before offboarding or rotating an identity.
---

# Identity blast radius

Use the `token-security` MCP server. It exposes three meta-tools: `search` finds the underlying tool by name or intent, `get_schema` returns its arguments, `execute` runs it. The tool names below are what you pass to `search` and call inside `execute`. Everything is read-only.

1. Find the identity: `find_entity` by name (or `query_identities` with a filter on email, ARN or platform), or `global_search` when the user only has a fragment. If more than one matches, show the candidates with their platform and ask.
2. `get_identity_details` for the full record: type (human or non-human), platform, owner, permissions and cross-platform links.
3. `get_entity_graph` on the identity's entity id for reach: resources, roles, groups and other identities one or two hops away. `analyze_entity_graph` when the user wants a summary rather than the raw graph.
4. `get_identity_activity_logs` for recent usage; call an identity unused only when the log window the tool returned is long enough to say so.
5. `query_issues` filtered on the identity for open findings.

Answer with: what it is, who owns it, what it reaches (highest privilege first), last activity, open findings. For an offboarding question, end with the list of things that would break if the identity were removed.
