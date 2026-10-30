# Render MCP Troubleshooting

## Connection Errors

### "MCP server not found" or tool not available

**Cause:** MCP server not configured in the AI tool.

**Fix:** Follow the current setup and verification workflow in [render-access.md](render-access.md).

### "Connection refused" or timeout

**Cause:** Network issue or incorrect URL.

**Fix:** Confirm the current endpoint and transport using [render-access.md](render-access.md), check internet connectivity, and account for corporate firewalls that might block MCP connections.

### "Transport error" or "SSE not supported"

**Cause:** Using the wrong transport or URL.

**Fix:** Reconfigure the client from the current MCP documentation fetched through [render-access.md](render-access.md).

## Authentication Errors

### "Unauthorized" or 401

**Cause:** Missing or expired OAuth authorization (plugin setup), or a missing, invalid, or expired API key (manual setup).

**Fix:** Ask the user to reconnect the Render server in the plugin's Edit dialog, Connections tab, and complete authorization again. Then verify with `list_services()`.

### "Forbidden" or 403

**Cause:** OAuth authorization or API key doesn't have access to the requested resource, or wrong workspace.

**Fix:** Verify the intended workspace and confirm that the authenticated account has access to it, following [render-access.md](render-access.md).

## Connection Issues

- If the Render tools do not appear at all, the server is not connected: ask the user to connect it in the plugin's Edit dialog, Connections tab.
- If they appear but every call fails, ask the user to disconnect and connect the server again there.

## Workspace Issues

### "No workspace selected"

**Fix:** Follow the workspace-selection workflow in [render-access.md](render-access.md).

### Operations return empty results

**Cause:** Active workspace has no services, or wrong workspace is selected.

**Fix:** Call `get_selected_workspace()` to inspect the active workspace and `list_workspaces()` to find the intended one. Verify credential access before concluding that no resources exist.

## MCP vs CLI Fallback

Use the supported fallback selection in [render-access.md](render-access.md), then inspect the current CLI or MCP capability surface instead of relying on a fixed comparison table.
