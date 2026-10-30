---
name: triage-finding
description: Explain a Token Security finding: what it is, what identities and resources it touches, and what closes it. Use when the user pastes a finding id or title, asks "why is this flagged", or wants a remediation plan for a security issue.
---

# Triage a Token Security finding

Use the `token-security` MCP server. It exposes three meta-tools: `search` finds the underlying tool by name or intent, `get_schema` returns its arguments, `execute` runs it. The tool names below are what you pass to `search` and call inside `execute`. Everything is read-only.

1. Locate the finding. With an id, call `get_issue_details`. With a title, name or platform, call `query_issues` with the matching filter and pick the row the user means; if several match, list them and ask.
2. Read the finding's subject. For an identity, call `get_identity_details`; for an AI agent, `get_ai_agent_details`; for a secret, `query_secrets` filtered on its id. Follow the `resolve_entity_links` result when the finding points at an entity rather than a source record.
3. Explain in this order: what the finding says, why it matters (the access the subject has, `get_entity_graph` for the reach), how long it has been open, and who owns the subject.
4. Propose the fix as concrete steps on the source platform (rotate, remove, scope down, disable). Token Security does not change anything through this plugin; say so if the user asks you to fix it.

Report ids and platform names exactly as returned. Do not invent severity or dates that the tools did not return.
