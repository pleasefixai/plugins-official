---
name: pagerduty-mcp-setup
description: REQUIRED setup for how to use the PagerDuty MCP server. IMPORTANT If you want to use PagerDuty MCP tools, read these instructions BEFORE checking tool schemas or doing any PagerDuty investigation because the MCP may not work until the API token is configured.
---

IMPORTANT: Before using the PagerDuty MCP or doing any other investigation related to PagerDuty, you must follow these directions and make sure that the following requirements are met.

### Context

This plugin does not carry the PagerDuty MCP server. The user adds it as a custom server in Settings, with the PagerDuty-hosted address `https://mcp.pagerduty.com/mcp` and an `Authorization` header that holds a real PagerDuty User API token.

The PagerDuty-hosted MCP service expects the header to look like this:

```json
{
  "Authorization": "Token your-pagerduty-api-token-here"
}
```

If the PagerDuty MCP tools are not available to you, you should not do anything except tell the user that the PagerDuty MCP is not configured yet and help them finish setup.

Do not continue investigating PagerDuty or checking PagerDuty MCP tool schemas until the server is added with the token.

### Steps

Before continuing, take the following steps:

1. Check whether the PagerDuty MCP tools are available to you.
2. If they are not, stop immediately. Tell the user the PagerDuty MCP is not configured yet.
3. In that message, do all of the following:
   - Ask them to add the PagerDuty MCP as a custom server in Settings, with the address `https://mcp.pagerduty.com/mcp`.
   - Include a JSON code block with the header the server needs, so they can copy it directly.
   - Tell them to replace `your-pagerduty-api-token-here` with their PagerDuty User API token, keeping the `Token ` prefix in the Authorization header.
   - Tell them they can follow PagerDuty's API token instructions here: `https://support.pagerduty.com/main/docs/pagerduty-mcp-server-integration-guide#generate-your-pagerduty-api-token`
   - Do not ask them to send you the token.
   - Do not inspect PagerDuty MCP tools or continue the PagerDuty task yet.
4. Once the server has been added with the token, continue on to using the PagerDuty MCP.

### Reference

- PagerDuty API token setup instructions: `https://support.pagerduty.com/main/docs/pagerduty-mcp-server-integration-guide#generate-your-pagerduty-api-token`
- PagerDuty hosted MCP setup guide: `https://support.pagerduty.com/main/docs/pagerduty-mcp-server-integration-guide`
- PagerDuty developer docs: `https://developer.pagerduty.com/docs/mcp-tooling-remote-server`

### Example code block to show the user

When prompting the user to configure the token, include the header like so:

```json
"headers": {
  "Authorization": "Token your-pagerduty-api-token-here"
}
```
