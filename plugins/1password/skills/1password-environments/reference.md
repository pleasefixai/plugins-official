# 1Password Environments — reference

Supplement to [SKILL.md](SKILL.md). Use for setup and failures.

## Components

| Component | Purpose |
|-----------|---------|
| 1Password MCP server (`1password-mcp`) | Connects the agent to the 1Password desktop MCP server (macOS/Linux). Add it as a custom server in Settings with the command `1password-mcp` |
| Agent skill (`SKILL.md`) | Import, mount, and Environment management workflow |

## Official documentation

Fetch hosted docs when you need product context, security boundaries, or
edge cases beyond this plugin's workflow. Index:
[llms.txt](https://www.1password.dev/llms.txt)

| Topic | Doc |
|-------|-----|
| Local `.env` mounts (FIFO, git conflicts, dotenv compatibility) | [local-env-file.md](https://www.1password.dev/environments/local-env-file.md) |
| MCP server (setup, auth prompts, security model) | [mcp-server.md](https://www.1password.dev/environments/mcp-server.md) |

## Setup

**Requirements**

- **macOS or Linux** with the [1Password desktop app](https://1password.com/downloads) installed
- The 1Password MCP server added as a custom server in Settings, with the command `1password-mcp`
- **Integrate with MCP clients** turned on under **Settings > Developer** in the desktop app
- Access to a 1Password account with Developer Environments enabled
- `1password-mcp` on your `PATH` (registered by the desktop app when MCP is enabled)

On **Windows**, MCP and local mounts are unavailable.

MCP server setup and platform details: [mcp-server.md](https://www.1password.dev/environments/mcp-server.md)

**When things fail**

- Authentication or environment access fails — the 1Password desktop app may need approval, unlocking, or account access
- MCP server unavailable — turn on **Integrate with MCP clients** under **Settings > Developer**. If the checkbox is missing, update 1Password; your account may not have the `ai-local-mcp-server` feature flag. If it is disabled by an administrator, ask your administrator to check **Policies > Sharing and permissions > Agentic permissions > Local MCP server** — see [mcp-server.md](https://www.1password.dev/environments/mcp-server.md)
- `create_local_env_file` fails — confirm the user is on macOS or Linux
