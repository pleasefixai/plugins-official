# NetDocuments

This plugin connects Pleasefix to your firm's NetDocuments through ndConnect, the MCP server that NetDocuments runs itself. The agent can then search your workspaces and folders and read the documents in them.

## Before the first connect

- Your firm needs **ndMAX Enterprise**. NetDocuments offers its MCP server only on that tier.
- A NetDocuments admin must turn on MCP for the firm in **Security Center**. It is off until an admin opts in. An admin can also limit which AI tools may connect. If yours does, ask them to allow Pleasefix.

## Settings

### Region

The region where your firm's NetDocuments lives. To find it, look at the address you sign in to NetDocuments at:

| You sign in at | Region |
| --- | --- |
| `vault.netvoyage.com` | `us` |
| `eu.netdocuments.com` | `uk` |
| `de.netdocuments.com` | `de` |
| `au.netdocuments.com` | `au` |
| `can.netdocuments.com` | `ca` |

`eu.netdocuments.com` is the UK region. A firm elsewhere in Europe is on `de` only if it signs in at `de.netdocuments.com`.

Pleasefix connects to `https://web-api.<region>.netdocuments.app/connect/mcp`. Each region is its own server, and a sign-in at one region does not work at another. With the wrong region, the connect fails after you sign in.

When you change the region, Pleasefix signs you out of NetDocuments, and you connect again.

## Connecting

Click **Connect**. NetDocuments opens its sign-in page for your region in your browser. Sign in with your own NetDocuments account and allow access.

NetDocuments always asks for all three of its permissions: `read`, `organize` and `edit`. Pleasefix cannot ask for less. That is why Pleasefix lists this connection as one that can change data.

## What the agent can do

The agent acts as the NetDocuments user who connected. NetDocuments applies that user's access rights, ethical walls and DLP rules to every request. The agent sees only what that user can see.

The tools come from NetDocuments, and NetDocuments decides which ones it serves. When this plugin was written, they were search and fetch: find documents, and read a document's text.

## Disconnecting

Disconnect in Pleasefix. A NetDocuments admin can also turn MCP off for the whole firm in Security Center.

## More

- [ndConnect, NetDocuments' AI and MCP integrations](https://www.netdocuments.com/ndconnect)
