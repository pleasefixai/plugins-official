# Recovery

- Missing operation: list the relevant router again; distinguish nested operations from top-level tools. Never invent tools or silently use the main hub.
- 401: reconnect through the host's browser OAuth flow. Never ask for or display access tokens.
- 403 / account ambiguity: inspect permitted connections and ask which account. Do not omit an ID to bypass access checks.
- Quota/rate limits: report the actual condition; do not route around billing or permissions.
- Invalid input: re-read the live schema and resolve conflicting descriptions. Never copy enabled example status into a paused build.
- Missing warehouse data: state the gap and freshness; do not fabricate zeros or repeatedly poll.
- Uncertain write: inspect existing resources and returned IDs before any retry.
- Asset review: uploaded is not approved; inspect moderation state before claiming readiness.
