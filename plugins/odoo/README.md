# Odoo

This plugin connects Pleasefix to your firm's Odoo database through the MCP server built into Odoo. The agent can then look up and work with the records of the Odoo apps your firm runs, such as contacts, CRM, sales, invoices and inventory.

It needs Odoo 20.0 or later, with the AI app installed.

## Settings

### Odoo address

The address of your Odoo database, as your browser shows it when you are signed in. Type it with `https://` and without a slash at the end.

| Where your Odoo runs | Example |
| --- | --- |
| Odoo Online | `https://acme.odoo.com` |
| Your own domain or server | `https://erp.acme.com` |

Pleasefix adds `/mcp` to this address to reach the MCP server. If your server hosts several databases on one address, use an address that opens your firm's database directly.

When you change the address, Pleasefix signs you out of Odoo, and you connect again.

## Before the first connect: an Odoo admin allows Pleasefix

Odoo lets only the AI clients that an admin has approved sign in. Until an admin adds Pleasefix, Odoo shows an error page instead of the sign-in page. An admin does this once for the whole database:

1. In Odoo, open **Settings**, and go to the **Integrations** section.
2. Under **MCP OAuth**, add this address on a new line:

   ```
   https://cloud.pleasefix.ai/api/oauth/client-metadata.json
   ```

3. Click **Save**.

The admin does not need to tick **Allow Dynamic Client Registration (DCR)**. Pleasefix does not need it, and it lets any application register.

## Connecting

Click **Connect**. Odoo opens in your browser. Sign in, then choose how long Pleasefix may stay connected: 1 day, 1 month, 1 year or Never. When that time ends, you connect again.

Only internal users can connect. Portal users cannot sign in to Odoo's MCP server with OAuth.

## What the agent can do

A new database offers five tools, all of which only read:

- Get Models
- Get Fields
- Search
- Read group
- Retrieve initial context

An admin can offer more, including tools that create and change records. In developer mode, open **Settings › Technical › Server Actions**, open an action, and tick **Available in MCP** on its **Usage** tab. **Readonly Tool** marks an action that changes nothing.

The agent acts as the Odoo user who connected, with that user's access rights.

## Disconnecting

Disconnect in Pleasefix, or remove the access in Odoo: under **My Preferences › Security**, each connection is listed as an API key. Delete that key.

## More

- [Odoo's documentation of its MCP server](https://www.odoo.com/documentation/20.0/applications/productivity/ai/mcp_server.html)
