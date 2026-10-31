# MCP Server Configuration Reference

Detailed instructions for configuring the Dataverse MCP server. This plugin does not carry the Dataverse server: the user adds it as a custom server in Settings (step 5).

The environment URL should already be known from the `dv-connect` flow (stored in `DATAVERSE_URL` in `.env`). If it's not set, go back to Step 2 of the `dv-connect` skill to discover and select the environment first.

The parameters for the MCP server should be determined from context or environment variables where possible, and interactive prompts should only be used when it cannot be done.

---

## 1. Set the MCP client ID

Set the `MCP_CLIENT_ID` variable in `.env` to `0c412cc3-0dd6-449b-987f-05b053db9457`: the custom server uses the `@microsoft/dataverse` npx stdio proxy, which authenticates as the Dataverse CLI app.

---

## 2. Check whether the server is already added

If Dataverse MCP tools (such as `describe` and `search`) are already in your tool list, the MCP server is **already configured**. Confirm with the user whether they want to add it again (e.g. for another environment or to change the endpoint type) before proceeding. If not, skip to the end.

---

## 3. Determine the environment URL

If the user gave the URL in their request, use it. Otherwise, take the URL from the `DATAVERSE_URL` variable in `.env`. If you have the URL, skip to step 4.

If the file or the variable doesn't exist, the environment URL must be discovered. Try the `dv-connect` skill's Step 2 first. If that's not possible (e.g., this reference is being used standalone), use the auto-discovery priority order below — try each method in order, stop at the first that succeeds:

1. **PAC CLI** (preferred) → step 3a
2. **Azure CLI** (fallback) → step 3b
3. **Manual entry** (last resort) → step 3c

### 3a. Auto-discover via PAC CLI (preferred)

Check if PAC CLI is available (bare `pac` prints the version banner; `pac --version` is not a valid command and returns non-zero):

```
pac
```

If available, check auth and list environments:

```
pac auth list
pac org who
pac env list
```

If PAC CLI is authenticated and `pac env list` returns results, present the environments to the user:

> I found the following Dataverse environments via PAC CLI. Which one would you like to configure MCP for?
>
> 1. My Dev Org — `https://orgfbb52bb7.crm.dynamics.com`
> 2. Another Env — `https://orgabc123.crm.dynamics.com`
>
> Or type a URL manually.

If PAC CLI is not installed or not authenticated, fall back to step 3b.

### 3b. Auto-discover via Azure CLI (fallback)

**Check prerequisites:**
- Verify Azure CLI (`az`) is installed (check with `which az` or `where az` on Windows)
- If not installed, inform the user and fall back to step 3c

**Make the API call:**

1. Check if the user is logged into Azure CLI:
   ```bash
   az account show
   ```
   If this fails, prompt the user to log in:
   ```bash
   az login
   ```

2. Get an access token for the Power Apps API:
   ```bash
   az account get-access-token --resource https://service.powerapps.com/ --query accessToken --output tsv
   ```

3. Call the Power Apps API to list environments:
   ```
   GET https://api.powerapps.com/providers/Microsoft.PowerApps/environments?api-version=2016-11-01
   Authorization: Bearer {token}
   Accept: application/json
   ```

4. Parse the JSON response and filter for environments where `properties?.linkedEnvironmentMetadata?.instanceUrl` is not null.

5. For each matching environment, extract:
   - `properties.displayName` as `displayName`
   - `properties.linkedEnvironmentMetadata.instanceUrl` (remove trailing slash) as `instanceUrl`

6. Create a list of environments in this format:
   ```json
   [
     { "displayName": "My Org (default)", "instanceUrl": "https://orgfbb52bb7.crm.dynamics.com" },
     { "displayName": "Another Env", "instanceUrl": "https://orgabc123.crm.dynamics.com" }
   ]
   ```

**If the API call succeeds**, present the environments as a numbered list.

> I found the following Dataverse environments on your account. Which one would you like to configure?
>
> 1. My Org (default) — `https://orgfbb52bb7.crm.dynamics.com`
> 2. Another Env — `https://orgabc123.crm.dynamics.com`
>
> Enter the number of your choice, or type "manual" to enter a URL yourself.

If the user types "manual", fall back to step 3c.

**If the API call fails** (user not logged in, network error, no environments found, or any other error), tell the user what went wrong and fall back to step 3c.

### 3c. Manual entry — ask for the URL

Ask the user to provide their environment URL directly:

> Please enter your Dataverse environment URL.
>
> Example: `https://myorg.crm10.dynamics.com`
>
> You can find this in the Power Platform Admin Center under Environments.

### 3d. Remember the selected URL

Take the URL determined above (from context, `.env`, manual entry, or `instanceUrl` from discovery) and strip any trailing slash. This is `USER_URL` for the remainder of this reference.

---

## 4. Decide whether to use the "Preview" or "Generally Available (GA)" endpoint

Determine from the context which of these options the user wants to use. If they did not mention either, default to GA:

- If **Generally Available (GA)**: set `MCP_URL` to `{USER_URL}/api/mcp`
- If **Preview**: set `MCP_URL` to `{USER_URL}/api/mcp_preview`

---

## 5. Add the MCP server as a custom server in Settings

This plugin does not carry the Dataverse server. Ask the user to add it as a custom server in Settings.

**IMPORTANT: Always use the stdio transport via the npx proxy.** Do not add `/api/mcp` as an HTTP address — the Dataverse MCP endpoint requires authentication that only the npx proxy handles. The proxy is `@microsoft/dataverse@latest mcp <url>`.

**Generate a unique server name** from the `USER_URL`:
1. Extract the subdomain (organization identifier) from the URL
   - Example: `https://orgbc9a965c.crm10.dynamics.com` → `orgbc9a965c`
2. Use lowercase format: `dataverse-{orgid}`
   - Example: `dataverse-orgbc9a965c`

This is the `SERVER_NAME`.

**The custom server:**

- Name: `{SERVER_NAME}`
- Command: `npx`, with the arguments `-y @microsoft/dataverse@latest mcp {USER_URL}`, plus `--preview` if the user chose the Preview endpoint in step 4. On Windows without WSL, wrap the call: command `cmd`, arguments `/c npx -y @microsoft/dataverse@latest mcp {USER_URL}`.
- Environment variable: `DATAVERSE_OPERATION_CONTEXT=app=dataverse-skills/{DATAVERSE_PLUGIN_VERSION};skill=mcp-direct;agent={DATAVERSE_PLUGIN_AGENT}`, so the stdio proxy attaches plugin attribution to outbound requests.

Where:
- `{USER_URL}` is the base environment URL (e.g., `https://orgbc9a965c.crm10.dynamics.com`)
- `{DATAVERSE_PLUGIN_VERSION}` and `{DATAVERSE_PLUGIN_AGENT}` come from `.env` (set in dv-connect Step 3)

---

## 6. Ensure tenant-level admin consent (one-time per tenant)

The MCP client app registration must be granted admin consent on the Azure AD tenant. This is a **one-time** action per tenant — once done, it applies to all Dataverse environments in that tenant. It **requires an Azure AD Global Admin or Privileged Role Admin**.

List out the parameters chosen in previous steps:
- Environment URL from step 3
- Endpoint (GA or Preview) from step 4
- MCP Client ID from step 1

Ask the user if admin consent has already been granted for this tenant. If not, provide the consent URL:

> **Tenant-level admin consent** is required for the MCP client app. This is a one-time action per Azure AD tenant — once granted, it covers all environments in the tenant.
>
> An Azure AD Global Admin or Privileged Role Admin must open this URL and click **Accept**:
> ```
> https://login.microsoftonline.com/{TENANT_ID}/adminconsent?client_id={MCP_CLIENT_ID}
> ```
>
> If you don't have admin permissions, send this URL to your Azure AD administrator.

Wait for the user to confirm this is done (or was already done previously) before proceeding.

---

## 7. Add the MCP client to the environment's allowed list (one-time per environment)

Separately from tenant-level consent, each Dataverse environment must explicitly allow the MCP client. This is a **one-time** action per environment and does **NOT** require Azure AD admin permissions — any user with Environment Admin or System Administrator role in the environment can do it.

> **One sign-in for CLI, MCP, and Python.** When the user runs `dataverse auth create` (see `dv-connect` Step 2) the token cache is written to a path / OS keychain entry that the `@microsoft/dataverse` stdio MCP proxy and `scripts/auth.py` both read silently. As a result, the allowlisted MCP client ID (`0c412cc3-…` for the stdio proxy) is exercised exactly once per environment — there is no separate Python device-code sign-in for the same user/env. If a script does prompt for a device code, the shared cache is missing or stale; re-run `dataverse auth create --environment <url>`.

Present the methods in priority order. **Always attempt Method A first** — it is a single command, needs no portal navigation, and is the most reliable path.

> **Method A (preferred): Dataverse CLI `mcp allow`**
>
> Run the first-class CLI command — it ensures the MCP client app is in the environment's allowed list using the active auth profile's environment:
>
> ```
> dataverse mcp allow {MCP_CLIENT_ID}
> ```
>
> Any of these outputs means success — continue to validation:
> - `Client {MCP_CLIENT_ID} is already enabled. No changes needed.`
> - `Client exists but is disabled. Enabling... Done.`
> - `Client not found. Creating... Done.`
>
> Requires the signed-in user to have Dataverse admin rights (Environment Admin or System Administrator) on the target environment. No Azure AD admin needed.

> **Method B (fallback): Power Platform Admin Center**
>
> Use this only if `dataverse mcp allow` is unavailable (CLI not installed) or fails on permissions:
>
> 1. Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com/)
> 2. Select **Environments** in the left navigation
> 3. Click on your environment (e.g., the one matching `{USER_URL}`)
> 4. Click **Settings** in the top toolbar
> 5. Expand **Product** and click **Features**
> 6. Scroll down to the **MCP Server** section
> 7. Toggle **Enable MCP Server** to **On** (if not already)
> 8. Under **Allowed clients**, click **Add client**
> 9. Paste the MCP Client ID: `{MCP_CLIENT_ID}`
> 10. Click **Save**

> **Method C (fallback): Programmatic via script**
>
> Run `scripts/enable-mcp-client.py` to add the client ID to the allowed list via the Dataverse API. Useful in non-interactive environments where the CLI isn't present.

**Do not send the user to the portal (Method B) before attempting Method A.** Run `dataverse mcp allow {MCP_CLIENT_ID}` yourself first; fall back to Method B or C only if it fails (CLI missing, or the user lacks Dataverse admin rights).

**Then validate the endpoint:**

```
npx -y @microsoft/dataverse@latest mcp {USER_URL} --validate
```

Treat `GA endpoint is valid, but Preview endpoint is not configured` as **success** for a GA registration (the default). Only revisit enablement if the GA endpoint still returns **403 Forbidden** after `mcp allow` reported success.

### ERP-linked environments

If `.env` contains `ERP_URL`, the ERP MCP proxy has a separate F&O allowlist. Do not treat the Dataverse allow command or validation as covering ERP.

The ERP proxy always authenticates as the Dataverse CLI app, including when the host's Dataverse MCP entry uses a different client ID. Use this fixed app ID:

```
dataverse mcp allow 0c412cc3-0dd6-449b-987f-05b053db9457 --erp
```

Then validate the ERP endpoint independently:

```
dataverse mcp {ERP_URL} --validate
```

An allow result of `already enabled`, `created and allowed`, or `enabled` is success. F&O AOS may cache the allowed-app list for up to five minutes; if validation initially returns 401 or 403 after a successful allow, wait for that cache window and retry once. Do not report the ERP MCP server as ready until ERP validation exits successfully.

---

## 8. Confirm success and provide next steps

Tell the user:

> ✅ Dataverse MCP server `{SERVER_NAME}` is ready to add as a custom server in Settings (step 5).
>
> **On first use, a browser window may open** asking you to sign in to your Dataverse environment. This is the MCP proxy (`@microsoft/dataverse`) authenticating on your behalf. Sign in with the same account you used earlier. This only happens once — the token is cached for future sessions.
>
> Once it is added, you will be able to:
> - List all tables in your Dataverse environment
> - Query records from any table
> - Create, update, or delete records
> - Explore your schema and relationships

**Do not claim the Dataverse MCP tools are callable until they appear in your tool list.** If the user asks you to run an MCP query before the server is added, explain that the tools load once it is — do **not** spin up a separate `npx @microsoft/dataverse mcp` stdio proxy as a workaround, and if the user explicitly required MCP, do **not** silently fall back to the SDK or Web API.

Pause and give the user a chance to add the server before proceeding. Do not perform any subsequent or parallel operations until the user responds.

---

## 9. Troubleshooting

If something goes wrong, help the user check:

- The URL format is correct (`https://<org>.<region>.dynamics.com`)
- They have access to the Dataverse environment
- The environment URL matches what's shown in the Power Platform Admin Center
- **Tenant-level admin consent** has been granted for the MCP client app. This is a one-time per-tenant action requiring an Azure AD admin. Without it, authentication succeeds but the app is denied access. Use the admin consent URL from step 6.
- **Org-level allowed clients** — the MCP client ID has been added to the environment's allowed list. The quickest fix is the CLI command `dataverse mcp allow {MCP_CLIENT_ID}` (Step 7, Method A). To check or fix it via the portal instead:
  1. Go to [Power Platform Admin Center](https://admin.powerplatform.microsoft.com/) > Environments > your environment > Settings > Product > Features
  2. Verify **MCP Server** is toggled **On**
  3. Verify the MCP Client ID appears under **Allowed clients**
- **ERP-linked environments** — Dataverse and ERP use separate allowlists and validation calls. Run `dataverse mcp allow 0c412cc3-0dd6-449b-987f-05b053db9457 --erp`, allow up to five minutes for the F&O AOS cache, and validate `{ERP_URL}` independently.
- If using the Preview endpoint, verify that the Preview MCP endpoint is also enabled in the same Features page
- If the server does not start, check that `npx` and `npm` (Node.js 18+) are installed and on PATH; on Windows the command may need `cmd /c` wrapping (see Step 5).
- If the MCP proxy version seems outdated or behaves unexpectedly, clear the npx cache and retry:
  ```
  npx clear-npx-cache
  ```
- To validate authentication independently, run:
  ```
  npx -y @microsoft/dataverse@latest mcp "{USER_URL}" --validate
  ```
  This checks credentials and prints error details if issues are found. If it returns **403 Forbidden** on the GA endpoint, the client isn't allowlisted yet — run `dataverse mcp allow {MCP_CLIENT_ID}` (Step 7, Method A), then re-validate.
