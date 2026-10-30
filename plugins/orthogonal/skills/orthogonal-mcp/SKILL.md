---
name: orthogonal-mcp
description: Configure or troubleshoot Orthogonal's hosted MCP server in Codex, Claude Code, Cursor, Grok Bot, or another Streamable HTTP MCP client. Use for plugin installation, OAuth authorization, missing tools, connection errors, URL validation, or a read-only installation check. Do not use when the connection works and the user wants to discover or run an API (orthogonal).
---

# Orthogonal MCP

Use the hosted Streamable HTTP endpoint exactly as written:

```text
https://mcp.orthogonal.com
```

Do not append `/mcp`. OAuth-capable clients should connect with the bare URL and complete the Orthogonal browser authorization flow.

## Configuration

```json
{
  "mcpServers": {
    "orthogonal": {
      "type": "http",
      "url": "https://mcp.orthogonal.com"
    }
  }
}
```

This repository's `.mcp.json` provides the same server to Codex, Claude Code, Cursor, and compatible plugin clients. For manual Cursor project setup, place the server under `mcpServers` in `.cursor/mcp.json`.

## Available tools

The hosted server exposes seven tools: `search`, `get_details`, `quote`, `use`, `integrate`, `batch_use`, and `batch_get_details`. Load their schemas from the connected server; do not rely on a copied parameter contract.

## Verify

1. Restart the client, start a new session, or reload plugins after installation.
2. Inspect the client's MCP status and complete OAuth authorization.
3. Ask the agent to search Orthogonal for APIs that can enrich a lead by email.
4. Confirm `search` returns catalog results before attempting a paid `use` call.

## Troubleshoot

- **Server missing:** fully restart the client and verify it loads `.mcp.json` from the plugin root.
- **Connection failure:** confirm the URL is exactly `https://mcp.orthogonal.com` and the client supports HTTP MCP transport.
- **401 Unauthorized:** finish or repeat the browser authorization flow; the protected server requires authentication.
- **Tools missing after authorization:** reload the plugin/session and inspect the client's MCP logs.
- **Search works but execution fails:** check endpoint details and the Orthogonal account balance, then quote the call before retrying.
- **Cursor Marketplace or Grok Bot cannot find the plugin:** the repository must first be published and listed in Cursor's marketplace; use the local Cursor installation steps in the README for pre-publication testing.

Never place OAuth tokens or API keys in plugin manifests, issue reports, screenshots, or source control.
