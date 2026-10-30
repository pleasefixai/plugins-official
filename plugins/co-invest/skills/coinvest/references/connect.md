# Connect Co-Invest

The skill is portable instructions. It does not register an MCP server or carry
credentials. Add a server through the host's native MCP settings, then complete
Liquid's OAuth flow in that host. Never paste a private key, access token, or
refresh token into chat or a configuration snippet.

## Default connection

For every host, use Computer at
`https://coinvest-computer.liquid.trade/mcp` by default. Its discovered reads
and direct executors support user-authorized live or paper trades without a
widget. Use Main or Restricted only when the user explicitly selects that
workflow:

| Endpoint | Use | Authority boundary |
| --- | --- | --- |
| `https://coinvest-computer.liquid.trade/mcp` | Computer's text/direct tools for terminal-friendly execution | Direct execution is available only for tools and policies returned by this server. |
| `https://coinvest.liquid.trade/mcp` | Main interactive research, account context, proposals, and widget-mediated actions | The server's discovered schemas and widget confirmation flow govern behavior. |
| `https://coinvest-chat.liquid.trade/mcp` | Restricted review-link behavior | Do not substitute it with a direct executor or silently upgrade its permissions. |

Reuse an already-connected Computer connection. If Computer is absent, guide
the host's MCP settings and Liquid OAuth setup; do not use an installed Main or
Restricted connection as an implicit fallback. Respect an explicit Main or
Restricted selection and ask before adding or switching a connection when the
change could alter whether an action is interactive, direct, paper, or live. A
connection name, shared tool name, or OAuth success does not establish
capability parity between servers.

After connecting, discover the server's current tools and inspect the candidate
tool's live schema, annotations, and approval behavior. If discovery does not
expose a requested capability, report that boundary instead of deriving an HTTP
route or inventing a tool. If Computer is unavailable, explain that the default
direct workflow is not connected and guide its setup. An explicitly selected
Main workflow still requires its existing widget flow; do not claim that a
widget executed without authoritative confirmation.
