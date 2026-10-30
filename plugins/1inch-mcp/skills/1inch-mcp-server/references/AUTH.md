# Authentication -- 1inch MCP

## API key

Obtain a key from the [1inch Business Portal](https://business.1inch.com/portal).

Pass it as:

`Authorization: Bearer <YOUR_API_KEY>`

In Pleasefix, set it as a header on the custom server that points at `https://api.1inch.com/mcp/protocol`. Leave it out to use the public tools and OAuth only.

## OAuth

If the user calls an authenticated tool without a key, MCP clients that support OAuth can start a browser login against the 1inch Business Portal. After login, tools work for that session.

Protected tools (including the optional `debug` log lookup) need a **non-anonymous** session: a **Bearer API key** and/or **OAuth** as supported by the gateway, plus (for `debug`) organization context for log scoping. The `debug` tool is only available when the server registers it; see [TOOLS.md](TOOLS.md).

## Security

- Never commit API keys to repositories or skills.
- Treat skills that mention keys as **user-supplied configuration**, not embedded secrets.
