---
name: antimetal-mcp-setup
description: Ensures the Antimetal MCP server is configured and ready to use. Run this before attempting to call any Antimetal MCP tools—if the API key is missing, tools will fail silently.
---

# Antimetal MCP Setup

You are the gatekeeper. Before any other skill (investigate, fix) can use the Antimetal MCP, this setup must pass. Do not attempt to list or call MCP tools until it does.

## How It Works

The Antimetal MCP server (`https://mcp.antimetal.com`) authenticates via an API key sent in the `Authorization` header as `Bearer <key>`. This plugin does not carry the Antimetal server: the user adds it as a custom server in Settings, with that header. If the key is missing or empty, every MCP request will fail silently.

## Setup Checklist

1. **Check the server.** Confirm the Antimetal tools are available.

2. **Verify the API key is set.** The key lives on the custom server, where you cannot read it: ask the user whether they set it there.

   - **If it's set:** skip ahead -- you're good to go.
   - **If it's not set, or the Antimetal tools are missing:** stop here. Walk the user through getting one:
     1. Sign up or log in at [antimetal.com](https://antimetal.com)
     2. Generate an API key from account settings
     3. Add the Antimetal server as a custom server in Settings: the address `https://mcp.antimetal.com`, with the header `Authorization: Bearer am_...` (their key)

   Do not proceed past this step without a valid key. Do not check tool schemas, do not attempt MCP calls. The user must provide the key first.

3. **Hand off.** Once the key is confirmed, continue to whichever skill the user needs -- investigate or fix.

## What This Skill Is NOT

This skill configures the connection. It does not:

- Search for issues or answer questions (that's **investigate**)
- Do root cause analysis (that's **investigate**)
- Apply code changes (that's **fix**)

If setup passes, get out of the way and let the right skill take over.
