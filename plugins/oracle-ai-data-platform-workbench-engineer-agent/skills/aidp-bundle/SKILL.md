---
name: aidp-bundle
description: Deploy AIDP resources as a bundle — create a bundle, deploy all its assets atomically, query deployment status, and purge. Use when the user wants to promote/deploy a set of AIDP resources together, manage a deployment bundle, check bundle deployment status, or tear one down. Preview API via `oci raw-request`; verify live first.
---

# `aidp-bundle` — resource bundles (Preview)

Deploy/manage AIDP resource bundles. **CLI (preferred):** the official `aidp bundle …` CLI
(Oracle-supported, versioned — see [references/aidp-cli-map.md](references/aidp-cli-map.md)):
`aidp bundle create | deploy | fetch-deployment-status | purge | sync-bundle`.
**Fallback:** `oci raw-request` against the same REST `Bundle` API (auth + base URL in
[references/oci-raw-request.md](references/oci-raw-request.md)) when the CLI isn't installed.
Self-contained: no MCP and no `ai-data-engineer-agent` repo required.

> **Preview + verify-first (no-fabrication):** `Bundle` is **Preview**. On this env (`20240831`,
> `dataLakes`) the Bundle resource may be **not provisioned** — expect a `404` (wrong version/prefix or
> feature not enabled in the tenancy). Confirm with a live read-only `getDeploymentStatus` before any
> deploy/purge, and record the result in `references/rest-endpoint-map.md`. Do not present endpoints as
> confirmed until a live 2xx (or documented 4xx) is recorded.

## When to use
- "Deploy these resources together", "promote a bundle", "what's the deployment status", "purge/tear down a
  bundle".

## Commands / endpoints (workspace-scoped; Preview)
**CLI (preferred):** `aidp bundle create` · `aidp bundle deploy` · `aidp bundle fetch-deployment-status`
(read-only — verify here) · `aidp bundle purge` · `aidp bundle sync-bundle`.

**Fallback (`oci raw-request`)** — default `20240831`, probe `20260430` only after a tenancy upgrade.
Base: `https://aidp.<region>.oci.oraclecloud.com/20240831/dataLakes/<DATALAKE_OCID>/…`
- `POST /workspaces/{ws}/bundles` — create
- `POST /workspaces/{ws}/bundles/actions/deploy` — deploy all resources
- `POST /workspaces/{ws}/bundles/actions/getDeploymentStatus` — status (read-only — verify here)
- `POST /workspaces/{ws}/bundles/actions/purge` — destroy deployed resources

> A `404` (REST) or not-provisioned error (CLI) on any of these means **not provisioned** in this tenancy
> (or wrong version/prefix — try the other per
> [references/oci-raw-request.md](references/oci-raw-request.md)), not that the request was
> malformed. Report it as a feature-availability gap, not a failure.

For mutating ops (create / deploy / purge / sync-bundle), persist the request body to `.aidp/payloads/`
and confirm first — see [references/payloads.md](references/payloads.md).

## What a bundle is (manifest + structure)
A bundle is a self-contained, portable package of selected workspace assets (jobs + agent flows) plus their
dependencies and code artifacts, captured so they can be recreated in another workspace/environment. The
**manifest is `aidp_workbench.yaml`** at the bundle root; the bundle mirrors the source workspace folder
layout. Dependency references use template variables, e.g. `$${jobs.dependencies.training_compute.compute.key}`,
`$${jobs.dependencies.training_job.job.key}`, `$${jobs.dependencies.training_aicompute.aicompute.key}`, plus
`$${bundle.root}` for artifact paths. (Source: CLI README `bundle create` long description, lines 180–209.)
Bundles can **only be created inside Git-backed workspace folders** (CLI README line 180).

## Create body (`CreateBundleDetails`)
`POST …/workspaces/{ws}/bundles` (CLI: `aidp bundle create <AI-DATA-PLATFORM-ID> <WORKSPACE-KEY> --body <JSON>`).
Wire fields from SDK `create_bundle_details.py:38-50` and `bundled_resource.py:39-47`:

| Field | Required | Type | Notes |
|---|---|---|---|
| `name` | yes | str | bundle folder name (`create_bundle_details.py:45-49`, README:208) |
| `path` | yes | str | parent folder in the workspace volume (`create_bundle_details.py`:46, README:209) |
| `description` | no | str | (`create_bundle_details.py`:47) |
| `bundledResources` | yes | array of `BundledResource` | jobs/agentflows to include (`create_bundle_details.py`:49) |
| ↳ `resourceType` | yes | enum | `JOB` \| `AGENTFLOW` (`bundled_resource.py:18,22,76`) |
| ↳ `resourceKey` | yes | str | workspace-unique key for the resource (`bundled_resource.py`:46) |

```json
{
  "name": "<bundle-name>",
  "path": "/Workspace/Shared/<git-folder>",
  "description": "<optional>",
  "bundledResources": [
    { "resourceType": "JOB",       "resourceKey": "<job-key>" },
    { "resourceType": "AGENTFLOW", "resourceKey": "<agentflow-key>" }
  ]
}
```

`deploy` / `fetch-deployment-status` / `purge` / `sync-bundle` each take only **`path`** (the bundle root
folder) — `DeployBundleDetails`/`FetchBundleDeploymentStatusDetails`/`PurgeBundleDetails`/`SyncBundleDetails`
are all single-field `{ "path": "<bundle-root>" }` (`deploy_bundle_details.py:26-32`,
`fetch_bundle_deployment_status_details.py:26-32`, `purge_bundle_details.py:26-32`,
`sync_bundle_details.py:26-32`; README:240/267/295/323).

`fetch-deployment-status` returns `BundleDeploymentStatus`: `status` ∈ `SUCCEEDED` \| `FAILED` \|
`IN_PROGRESS` \| `NOT_DEPLOYED` (`bundle_deployment_status.py:18,22,26,30,107`), plus `timeStarted`,
`timeCompleted`, `message`, and `resources[]` (each `{type: JOB|AGENTFLOW, key, name}` —
`bundle_deployed_resource.py:18,22,50`).

## Promotion (dev → test → prod) — Git + overrides
Promotion is a **Git workflow**, not a separate API: the whole bundle folder is committed/pushed, pulled into
the target workspace, and deployed there; bundles can be promoted across environments (dev → test → prod) via
Git (CLI README line 180, "Git integration and promotion").

Environment-specific values are parameterized in the manifest and overridden per environment:
- The manifest declares defaults under `defaults.variables`, e.g. `job_compute_key: "$${jobs.dependencies.small.compute.key}"`, referenced in descriptors as `$${var.<name>}` (e.g. `"clusterKey": "$${var.job_compute_key}"`). (CLI README:180.)
- Per-workspace overrides live in **`.aidp/overrides.yaml`** inside the bundle — *not committed to Git* so the bundle stays portable. When an override is supplied, the referenced dependency (e.g. compute) is **not created** and the provided value is used; with no override, the system falls back to the manifest default (which may create a bundled dependency). This is what lets prod reuse existing infrastructure while dev creates fresh resources. (CLI README:180.)
- `sync-bundle` preserves `.aidp/overrides.yaml` and `.aidp/aidp.state.json` when reconciling against `.aidp/resource_origins.yaml` — so refreshing source content does not clobber env-specific config (CLI README:309).

Override candidate shapes (SDK models — the request/response objects, **not** the on-disk yaml): the
`BundleOverrides` object groups candidates as `{ compute: [ComputeOverrideItem], aicompute: [AiComputeOverrideItem] }`
(`bundle_overrides.py:30-37`). Each item is
`{ name, variableName, defaultValue, overrideValue, jobs|agentflows: [...] }`
(`compute_override_item.py:42-56`, `ai_compute_override_item.py:42-56`). The create/update-overrides request
wraps it as `CreateOrUpdateBundleOverridesDetails{ path, overrides }`
(`create_or_update_bundle_overrides_details.py:30-37`); the read request is
`GetBundleOverridesDetails{ path }` (`get_bundle_overrides_details.py:26-32`).

> **Verify-first (overrides REST surface):** the get/update-overrides **HTTP endpoints have no `aidp bundle`
> CLI command** (CLI README lists only create/deploy/fetch-deployment-status/purge/sync-bundle) and were not
> live-probed on this env. The override *models* above are SDK-confirmed, but the exact override action path
> (e.g. `…/bundles/actions/{getOverrides|createOrUpdateOverrides}`) is **unconfirmed** — do not present it as
> a verified endpoint. For day-to-day promotion, edit `.aidp/overrides.yaml` in the bundle folder (the
> Oracle-documented path) rather than calling an unverified override API.

## Workflow
1. **Verify** with `aidp bundle fetch-deployment-status` (CLI) or `getDeploymentStatus` (REST fallback —
   `oci raw-request`, `--profile DEFAULT` → session fallback). A not-provisioned / `404` here = Bundle not
   provisioned → stop and report.
2. Create the bundle — `CreateBundleDetails` body above (`name`/`path`/`bundledResources[{resourceType,resourceKey}]`).
   Bundle folder must be inside a Git-backed workspace path.
3. **Deploy** (`{path}`) → poll async (202) to terminal via `aidp-observability`; report per-resource status
   from `fetch-deployment-status` (`SUCCEEDED`/`FAILED`/`IN_PROGRESS`/`NOT_DEPLOYED`).
4. **Promote** (dev → test → prod): commit/push the bundle folder, pull into the target workspace, set
   `.aidp/overrides.yaml` for that environment, then deploy there. `sync-bundle` refreshes source content
   while preserving overrides.
5. **Purge** (`{path}`) only on explicit confirmation — tears down deployed resources (does **not** delete
   the bundle files).

## Guardrails
- `deploy` and especially `purge` are high-impact — show the resource set and confirm before running.

## References
- [references/aidp-cli-map.md](references/aidp-cli-map.md) — skill → official `aidp` CLI command map (primary engine)
- [references/oci-raw-request.md](references/oci-raw-request.md) · [references/rest-endpoint-map.md](references/rest-endpoint-map.md)
- [references/payloads.md](references/payloads.md) — persist + confirm request bodies for mutating ops
