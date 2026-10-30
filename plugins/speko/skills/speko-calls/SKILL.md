---
name: speko-calls
description: Place and monitor outbound AI phone calls through Speko. This skill dials real telephone numbers and costs real money, so it reads its own environment variable and asks the user to confirm the number and the purpose before every call. Use when explicitly asked to call someone, ring a number, run an outbound voice campaign, or check the status, recording or transcript of a call that was already placed. For transcription, speech synthesis or model routing with no dialing involved, use the speko skill instead.
---

# Speko calls

This skill dials real phones. Treat every call as irreversible: it rings a physical device,
it can reach a stranger, it is billed, and it cannot be recalled once connected.

It is deliberately separate from the `speko` skill. Speech, transcription and model routing
place no calls; dialing is irreversible and billed. One Speko key covers both, so the split is
enforced by the environment rather than by the credential: this skill reads a second variable
that a speech-only setup has no reason to set.

Nothing in Cursor gates this skill on that variable being present. If `SPEKO_PLATFORM_API_KEY`
is not in the environment, every command below has nothing to send and no call is placed. The
confirmation steps in the next section are mandatory regardless.

The hosted Speko MCP shipped with this plugin exposes the same telephony surface as tools
(`sessions.phone_create`, `calls.get`, `sessions.transcript_get`, `phone_numbers.list`). The
same four confirmations apply to those tools — the guardrail is about dialing, not about which
transport reached the API.

## Credential

`SPEKO_PLATFORM_API_KEY` — your Speko key from the dashboard, on the **platform** host
`https://api.speko.dev/v1`.

It is the same key the `speko` skill uses on the router host; the second variable name is the
gate, so set it only where dialing is approved. Keys are environment-scoped, so a staging key
fails against production.

**Only supply this key in an environment where dialing is approved, audited and expected.**
If it is absent, this skill is not eligible and no calling instruction is in play.

## Before every call

Do all four. Do not skip one because the request looked explicit.

1. **State the number back** in full E.164 and get an unambiguous yes. Never dial a number you
   inferred, completed, or guessed a country code for.
2. **State the purpose** — what the agent will say and why — and get agreement on it.
3. **Check the hour** at the destination. Do not cold-call outside normal waking hours.
4. **Stop at one call** unless the user asked for more, by number, one at a time. Never loop
   over a list without per-number confirmation.

Refuse, and say plainly why, if the request is to dial an emergency line, a premium-rate
number, a number the user does not appear to have a relationship with, or any recipient at
volume. Decline impersonation of a real person or organisation on the call.

## List the numbers you can call from

```bash
curl -s https://api.speko.dev/v1/phone-numbers \
  -H "Authorization: Bearer $SPEKO_PLATFORM_API_KEY" | jq '.[] | {id, e164, direction}'
```

Returns a **bare JSON array**, not an object. The path is kebab-case — `/v1/phone_numbers`
404s. `from` on a call must be a number the organisation owns. If it owns exactly one outbound
number, use it; if several, ask which; if none, say one has to be provisioned first.

## Place the call

```bash
curl -s https://api.speko.dev/v1/sessions/phone \
  -H "Authorization: Bearer $SPEKO_PLATFORM_API_KEY" -H "Content-Type: application/json" \
  -d '{
    "to": "+15551234567",
    "from": "+15557654321",
    "intent": { "language": "en" },
    "systemPrompt": "You are calling to confirm a delivery window. Be brief.",
    "firstMessage": "Hi, this is an assistant calling about your delivery."
  }'
```

Only `to` is required and it is regex-checked as E.164. Supply either `agentId` for a
pre-built agent or `intent` for an ad-hoc call — an ad-hoc call needs no agent created in
advance. Also accepts `voice`, `telephony`, `llm`, `ttsOptions`, `sttOptions`, `webhookTags`
and `metadata`. Returns `{sessionId, callControlId, roomName, status, to, from}`.

**To prove a request body without ringing anyone**, post it with a deliberately invalid `to`
and read the validation error, or with a bogus `agentId` for a `404 AGENT_NOT_FOUND`. Do that
first when you are unsure about the shape.

## Follow the call

```bash
curl -s https://api.speko.dev/v1/calls/$ID \
  -H "Authorization: Bearer $SPEKO_PLATFORM_API_KEY" | jq '{status, duration_seconds, ended_at}'

curl -s https://api.speko.dev/v1/calls/$ID/report \
  -H "Authorization: Bearer $SPEKO_PLATFORM_API_KEY" | jq '{summary, outcome, cost_micro_usd}'
```

Call ids are UUIDs. `/report` carries `summary`, `outcome`, `structured_data`, a turn-by-turn
`transcript.entries[]`, and cost. **`structured_data` echoes the dialed number back**, so
anything that redacts phone numbers has to account for it too.

## Gotchas

- `GET /v1/calls/{unknown-id}` returns **500, not 404**. A 500 here usually means the id is
  wrong, not that the platform is down. Re-check the id before escalating.
- Validation errors are uniform: `{"error":"Invalid request","code":"VALIDATION_ERROR","issues":[…]}`.
- A recording may not exist yet immediately after a call ends; `recording_status` says so.
- Never paste this key into a shell command that gets logged. Read it from the environment.
