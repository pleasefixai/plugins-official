---
name: supply-chain-risk
description: 'Use this skill whenever you want to assess the agent supply chain as an attack surface: the trust, provenance, and integrity of the MCP servers, tools, connectors, third-party packages, and model endpoints your agents depend on. Trigger on requests like "is this MCP server safe to trust", "assess our agent supply chain risk", "where did this tool come from and who controls it", "check these connectors for tampering or over-broad scopes", "which third-party components could compromise our agents", or anything touching malicious or compromised MCP servers, dependency risk, tool poisoning, or untrusted integrations. Also use this when vetting a new integration before you approve it or reviewing which platforms you trust. This skill is about the trustworthiness of the components agents rely on, so use it whenever the question is whether something in the chain can be trusted.'
---

# Supply Chain Risk

Assess the agent supply chain - MCP servers, tools, connectors, third-party packages, and model endpoints - for trust, provenance, and integrity, using the Dash MCP.

## When to use

- Vetting whether a specific MCP server / tool / connector is safe to trust.
- Org-wide supply-chain risk assessment across the tenant AI BOM.
- Reviewing provenance ("who controls this", "where did it come from"), over-broad scopes, tampering, or tool poisoning.

## Tools to use (Dash MCP)

1. `list_inventory_mcps` - tenant MCP catalog (AI BOM) with `securityGrade`, `riskScore`, `signature`, provenance `sources`. Filter with `securityGrade`, `search`, `packageName`, `identityKey`.
2. `get_inventory_mcp` - full scoring/provenance detail for one catalog entry.
3. `list_mcp_servers` - MCP servers observed in use.
4. `list_workstation_mcps` - where MCPs actually run across devices.
5. `get_mcp_usage_summary` / `list_mcp_usage` - which MCPs are actually being called (blast radius).
6. `search_findings` + `list_finding_evidence` - existing findings tied to a component.

## Recipe

Scope one component:

1. `list_inventory_mcps` with `search`/`packageName`/`identityKey` to locate the entry.
2. `get_inventory_mcp` for its grade, risk score, signature, and provenance.
3. `list_mcp_usage` / `list_workstation_mcps` to see where it runs and how widely (blast radius).
4. `search_findings` for related detections; pull `list_finding_evidence` for the specifics.
5. Give a trust verdict + rationale + recommended action (approve / restrict / block / investigate).

Whole supply chain:

1. `list_inventory_mcps` sorted by `riskScore` (desc) and filtered to weak grades (`securityGrade: ["D","F"]`).
2. Cross-reference usage to prioritize risky + widely-used components.
3. Summarize the riskiest dependencies and the concrete next actions.

## How to interpret

- `securityGrade` A-F and `riskScore` are the trust signal; D/F or high risk score = untrusted until reviewed.
- Provenance `sources` (`workstation`, `saas-agent`) and `signature`/`identityKey` establish who controls the component and whether identity is stable.
- Weak grade + high usage = top priority (large blast radius).

## Output

Per component: trust verdict, grade/score, provenance, where it runs and how widely, related findings, and a recommended action. For org-wide: a ranked risk table with the top actions.

## Guardrails

- Read-only. This skill assesses and recommends; it does not block or change trust state.
- Confirm tenant via `list_tenants` if multiple are available.
- Do not assume an ungraded/stale entry is safe; call it out as needing review (`includeStale: true` to inspect stale rows).
