---
name: aidp-data-sharing
description: Share AIDP data via Delta Sharing — create/manage shares, add data assets, manage recipients, and grant access/permissions. Use when the user wants to share a table/schema with another team or org, set up Delta Sharing, manage recipients, or control share permissions/token expiry. Primary engine is the official `aidp` CLI (`aidp delta-share …`); the same GA REST API via `oci raw-request` is the no-CLI fallback.
---

# `aidp-data-sharing` — Delta Sharing (shares & recipients)

Open data sharing over the Delta Sharing protocol via the AIDP `DeltaShare` API. A differentiator:
open-protocol sharing driven from the agent.

**CLI (preferred):** `aidp delta-share <command> --instance-id <DATALAKE_OCID> --auth api_key --profile DEFAULT --region <r>`
- Shares: `aidp delta-share create | get | list | update | delete | manage-access | manage-data-asset | manage-permission | list-data-assets`
- Recipients: `aidp delta-share create-recipient | get-recipient | list-recipients | update-recipient | delete-recipient | manage-recipient-permission | list-recipient-shares | list-recipient-permissions`

**Fallback (no CLI):** same `DeltaShare` REST API via `oci raw-request` (identical endpoint + auth; see
`references/oci-raw-request.md`).

> **Verify-first:** `GET /shares` and `GET /recipients` are **LIVE-VERIFIED 200** on `20240831/dataLakes`
> (auth `--profile DEFAULT`, api_key) — `aidp delta-share list` / `list-recipients` hit the same path.
> Default to that version/prefix; treat `20260430` as the future GA target and probe only after a tenancy
> upgrade. Confirm any write with a live response before destructive actions; record in
> `references/rest-endpoint-map.md`.

## When to use
- "Share this table/schema with <team/org>", "set up Delta Sharing", "add/manage a recipient", "grant
  access to a share", "rotate a recipient token".

## Workflow
1. **Verify** with `aidp delta-share list` (CLI) — or `GET /shares` (REST fallback; auth ladder in
   `references/oci-raw-request.md`).
2. **Create a share** → **add data assets** (`manage-data-asset`, referencing real catalog tables from
   `aidp-catalog-explore`) → **create/attach recipients** → **manage access/permissions**.
3. Recipient tokens: surface expiry; rotate via `update-recipient` / `manage-recipient-permission`. **Never
   print the recipient bearer token.**
4. Confirm before granting access or deleting a share/recipient (outward-facing — data leaves the tenancy).

**Mutating ops** (share/recipient `create`, `manage-access`, `manage-data-asset`, `manage-permission`,
`manage-recipient-permission`): persist the body to `.aidp/payloads/` and confirm first
([references/payloads.md](references/payloads.md)).

### Fallback (no CLI) — REST endpoints (base `20240831/dataLakes/<OCID>`)
- Shares: `POST|GET /shares` · `GET|PUT|DELETE /shares/{k}` · `GET /shares/{k}/recipients|permissions|dataAssets`
  · `POST /shares/{k}/actions/manageAccess|managePermission|manageDataAsset`
- Recipients: `POST|GET /recipients` · `GET|PUT|DELETE /recipients/{k}` · `GET /recipients/{k}/shares|permissions`
  · `POST /recipients/{k}/actions/managePermission`

## Guardrails
- Sharing publishes data externally — confirm scope (which assets, which recipient) before any grant.
- Don't log share tokens/credentials.

## References
- [references/aidp-cli-map.md](references/aidp-cli-map.md) · [references/payloads.md](references/payloads.md) · [references/oci-raw-request.md](references/oci-raw-request.md) · [references/rest-endpoint-map.md](references/rest-endpoint-map.md)
