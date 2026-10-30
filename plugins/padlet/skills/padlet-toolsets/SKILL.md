---
name: padlet-toolsets
description: Views, enables, and disables toolsets for the Padlet MCP server. Use when the user wants to change which Padlet tools are available — for example to turn on board administration or school/team library management, or to trim the tool list back down.
---

## What a toolset is

The Padlet MCP server groups its tools into named toolsets. The plugin requests a subset by
name, so only those tools are exposed to the model. This exists because agent clients cap how
many tools a model can see across *all* connected MCP servers (Cursor's ceiling is roughly 80),
and Padlet's full surface is 69 tools on its own.

| Toolset | Tools | Contents |
| --- | --- | --- |
| `core` | 16 | Listing, searching, and reading padlets; creating padlets; creating, editing, connecting, and commenting on posts; analysing attachments |
| `utility` | 2 | Current time and web search |
| `board_admin` | 28 | Per-board appearance, access and collaborators, content settings, freeze, automations, remakes, grading, whiteboard tool settings |
| `library` | 23 | School and team library membership and invitations, SSO (OAuth and SAML), approved domains, per-role permissions, content safety, allowed attachment types |

`core` is what the plugin ships with.

## The registration file

The plugin's MCP registration is at `<plugin-root>/.mcp.json`. Derive `<plugin-root>` from this
file's own path by removing `skills/padlet-toolsets/SKILL.md` from the end. One registration file
serves every host the plugin supports.

It contains a single server entry whose URL carries the active toolsets as a comma-separated
`toolsets` query parameter:

```json
{ "mcpServers": { "padlet": { "type": "http", "url": "https://mcp.padlet.com/?toolsets=core" } } }
```

### Editing rule

Replace **only** the value after `toolsets=`. Leave the scheme, host, path, and the
`toolsets=` key itself intact, and do not add other query parameters. Order within the list is
not meaningful — treat the lists as sets when comparing.

```
?toolsets=core  →  ?toolsets=core,board_admin
```

## Flow

### 1. Read the current state

Read `<plugin-root>/.mcp.json` and parse the current `toolsets` value. Present the table above,
making clear which toolsets are currently enabled. Pick whatever format reads best in the
client — a checklist, a table, a grouped summary.

Ignore any name in the file that is not in the table above; it is stale. Drop it silently when
writing the updated list.

### 2. Understand the intent

The user may want to **add** toolsets, **remove** toolsets, or **replace** the list outright.
Ask for clarification if it is ambiguous.

### 3. Compute the new list, and warn where warranted

- **Result would omit `core`** — warn first. Almost every Padlet workflow depends on it. Only
  proceed if the user confirms explicitly.
- **Result would be every toolset, or an empty value** — both mean the server returns its full
  69-tool surface. Warn that this will consume nearly all of the client's tool budget and can
  crowd out the user's other MCP servers. Only proceed if the user confirms explicitly.
- **`utility`** — mention that most agent clients already have their own web search, so this
  toolset is usually redundant.
- **Result is unchanged** — say so and stop without editing the file.

### 4. Apply and confirm

Make the edit, then tell the user which toolsets are now enabled and that the client has to
reload before it re-reads the registration. Give the instruction for the client you are actually
running in:

- **Cursor** — open the command palette (⌘⇧P on macOS, Ctrl+Shift+P on Windows and Linux — show
  the shortcut for the user's actual operating system) and run **Developer: Reload Window**. If
  the Padlet server then asks for authentication, run **Cursor Settings: Tools & MCP** from the
  command palette and sign in to the `padlet` server.
- **Any other client** — restart the session or the app so the plugin's MCP servers reconnect,
  then complete the Padlet sign-in prompt if one appears.

Also tell the user, once, that this setting lives inside the installed plugin and will revert
to `core` if the plugin is updated or reinstalled — they can re-run this skill to restore it.
