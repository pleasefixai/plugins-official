---
name: ai-agent-inventory
description: List the AI agents, copilots and MCP servers Token Security has observed in the environment, what they access and which identities run them. Use when the user asks "what AI agents do we have", "which agents touch production", or "who is running MCP servers".
---

# AI agent inventory

Use the `token-security` MCP server. It exposes three meta-tools: `search` finds the underlying tool by name or intent, `get_schema` returns its arguments, `execute` runs it. The tool names below are what you pass to `search` and call inside `execute`. Everything is read-only.

1. `query_ai_agents` with the user's filter (platform, owner, time window, name). Page through the result when the total is larger than one page; do not stop at the first page and call it the inventory.
2. For each agent the user cares about, `get_ai_agent_details`: the identity that runs it, the tools and data sources it reaches, and where it was seen.
3. `get_entity_graph` on an agent's entity id when the user asks what it can reach; `query_issues` filtered on the agent for open findings.

Group the answer by platform, then by the identity that runs the agent. Flag agents whose running identity is a shared or non-human account with broad access, since that is the usual finding. Give counts from the tool's total, not from the rows you happened to read.
