---
name: shadow-ai-risk
description: 'Use this skill whenever you want to find and govern shadow AI in your environment: unsanctioned, unmanaged, or out-of-policy AI usage such as personal assistant accounts, unapproved copilots, AI tools running outside security review, and agents operating without governance. Trigger on requests like "find shadow AI here", "who is using AI tools we haven''t approved", "is Copilot usage governed", "surface ungoverned assistants and accounts", "what AI is running outside policy", or any ask about unapproved, unsanctioned, or blind-spot AI usage and the governance gap it creates. Also use this when you need to tell whether AI usage you already found is sanctioned and policy-covered versus rogue. This skill is about usage that escapes governance, so use it whenever the concern is AI running where it should not be.'
---

# Shadow AI Risk

Find and govern shadow AI - unsanctioned, unmanaged, or out-of-policy AI usage - using the Dash MCP.

## When to use

- "Find shadow AI", "who's using AI we haven't approved", "what's running outside policy".
- Deciding whether already-found usage is sanctioned/governed vs rogue.
- Reviewing the governance gap for a specific platform (e.g. "is Copilot usage governed").

## Tools to use (Dash MCP)

1. `list_platforms` with `isManaged: false` - the core shadow signal (unmanaged platforms).
2. `list_integrations` - what is actually sanctioned/managed (the governance baseline).
3. `list_users` / `list_actors` - who is driving the usage; used to detect shadow identities.
4. `list_devices` - which workstations run unmanaged AI.
5. `list_saas_agents` - SaaS-side agents that may be ungoverned.

## Recipe

1. `list_platforms` with `isManaged: false` to get unmanaged platforms; also fetch managed for contrast.
2. `list_integrations` to confirm which providers are sanctioned.
3. For each shadow platform, use `list_devices` / `list_users` to attribute usage to devices and identities.
4. Classify each item sanctioned vs shadow, and for shadow, note why Dash flags it (unmanaged platform, untrusted/personal account, or no policy coverage).
5. Recommend a governance action per item (onboard/integrate, restrict, or block via Dash policy) and prioritize by exposure.

## How to interpret

- Managed vs shadow (platform): Dash marks a platform managed when your tenant governs it via an active integration; otherwise it surfaces as unmanaged/shadow.
- Shadow AI (user): Dash derives whether a user is sanctioned from your tenant's configured trusted domains and integrations. When Dash lacks the signals to make that call, treat it as indeterminate and say so rather than guessing.
- "Governed" means covered by an integration and policy; usage outside both is the governance gap this skill surfaces.

## Output

A shadow-AI inventory: unmanaged platforms, the users/devices behind them, why each is shadow, and a prioritized set of governance actions. Separate "confirmed shadow" from "needs confirmation" (e.g. when trusted domains are unset).

## Guardrails

- Read-only; recommend governance actions, do not enact them.
- Confirm tenant via `list_tenants` when multiple are available.
- Do not label a user shadow when Dash lacks the signals to make that determination; flag it as indeterminate.
