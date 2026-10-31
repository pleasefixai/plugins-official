---
name: mongodb-mcp-setup
description: Guide users through configuring key MongoDB server options. Use this skill when a user has added the MongoDB server but hasn't configured the required environment variables, or when they ask about connecting to MongoDB/Atlas and don't have the credentials set up.
license: Apache-2.0
metadata:
  version: "1.0.0"
---

# MongoDB Server Setup

This skill guides users through configuring the MongoDB server. This plugin does not carry it: the user adds it as a custom server in Settings, with the command `npx` and the arguments `-y mongodb-mcp-server@<3`, and puts its credentials in that server's environment.

## Overview

The MongoDB server requires authentication. Users have three options:

1. **Connection String** (Option A): Direct connection to a specific cluster
   - Quick setup for single cluster
   - Requires `MDB_MCP_CONNECTION_STRING` environment variable

2. **Service Account Credentials** (Option B): MongoDB Atlas Admin API access
   - **Recommended for Atlas users** - simplifies authentication and data access
   - Access to Atlas Admin API and dynamic cluster connection via `atlas-connect-cluster`
   - No manual DB user credential management
   - Requires `MDB_MCP_API_CLIENT_ID` and `MDB_MCP_API_CLIENT_SECRET` environment variables

3. **Atlas Local** (Option C): Local development with Docker
   - **Best for local testing** - zero configuration required
   - Runs Atlas locally in Docker, requires Docker installed
   - No credentials or cloud cluster access

This is an interactive step-by-step guide. The agent detects the user's environment and provides tailored instructions, but **never asks for or handles credentials** — users add those directly to the custom server's environment in Settings in Step 5. Make this clear to the user whenever credentials come up in Steps 3a and 3b.

## Step 0: Check the Server

Ask the user whether the MongoDB server is already in Settings as a custom server. If not, ask them to add it: the command `npx` with the arguments `-y mongodb-mcp-server@<3` (Node.js required). Its environment is where the credentials go in Step 5.

## Step 1: Check Existing Configuration

Check whether credentials are already configured. Ask the user which of these variables the MongoDB custom server's environment already holds — the names only, never the values:

- `MDB_MCP_CONNECTION_STRING`
- `MDB_MCP_API_CLIENT_ID` and `MDB_MCP_API_CLIENT_SECRET`
- `MDB_MCP_READ_ONLY`

**Interpretation:**

- If `MDB_MCP_CONNECTION_STRING` appears → connection string auth is configured
- If both `MDB_MCP_API_CLIENT_ID` and `MDB_MCP_API_CLIENT_SECRET` appear → service account auth is configured. If only one is present, treat it as incomplete.
- If `MDB_MCP_READ_ONLY` appears → read-only mode is enabled

**Partial Configuration Handling:**

- User wants to add read-only to existing setup (has auth, no read-only flag) → skip to Step 4
- User wants to switch authentication methods → explain they should remove the old credentials from the custom server's environment first, then proceed with Steps 2–5
- User wants to update credentials → skip to Step 5

**Important**: If the user wants an Atlas Admin API action (managing clusters, creating users, performance advisor) but only has `MDB_MCP_CONNECTION_STRING`, explain they need service account credentials and offer to walk through setup.

## Step 2: Present Configuration Options

If no valid configuration exists, present the options:

**Connection String (Option A)** — Best for:

- Single cluster access
- Existing database credentials
- Self-hosted MongoDB or no Atlas Admin API needs

**Service Account Credentials (Option B)** — Best for:

- MongoDB Atlas users (recommended)
- Multi-cluster switching
- Atlas Admin API access (cluster management, user creation, performance monitoring)

**Atlas Local (Option C)** — Best for:

- Local development/testing without cloud setup
- Fastest setup with Docker, no credentials required

Ask the user which option they'd like to proceed with.

## Step 3a: Connection String Setup

If the user chooses Option A:

### 3a.1: Explain How to Find the Connection String

Explain where and how to obtain their connection string:

**For MongoDB Atlas:**

1. Go to [cloud.mongodb.com](https://cloud.mongodb.com)
2. Select your cluster → click **Connect**
3. Choose **Drivers** or **Shell** → copy the connection string
4. Replace `<username>` and `<password>` with your database user credentials

**For self-hosted MongoDB:**

- The connection string is typically configured by your DBA or in your application config
- Format: `mongodb://username:password@host:port/database`

**Expected formats:**

- `mongodb://username:password@host:port/database`
- `mongodb+srv://username:password@cluster.mongodb.net/database`
- `mongodb://host:port` (local, no auth)

Proceed to Step 4 (Determine Read-Only Access).

## Step 3b: Service Account Setup

If the user chooses Option B:

### 3b.1: Guide Through Atlas Service Account Creation

Direct the user to create a MongoDB Atlas Service Account:

**Full documentation**: https://www.mongodb.com/docs/mcp-server/prerequisites/

Walk them through the key steps:

1. **Navigate to MongoDB Atlas** — [cloud.mongodb.com](https://cloud.mongodb.com)
2. **Select your organization** from the ORGANIZATION section near the top of the page
3. **Go to "Project Identity and Access"** on the left sidebar → **Applications** → **Create Service Account**
4. **Set Permissions** — Grant Organization Member or Project Owner (see docs for exact permission mappings)
5. **Generate Credentials** — Create Client ID and Secret
   - ⚠️ The **Client Secret is shown only once** — save it immediately before leaving the page
5. **Note both values** — you'll need Client ID and Client Secret for Step 5

### 3b.2: API Access List Configuration

⚠️ **CRITICAL**: The user MUST add their IP address to the service account's API Access List, or all Atlas Admin API operations will fail.

Steps:

1. On the service account details page, find **API Access List**
2. Click **Add Access List Entry**
3. Add your current IP address. Use a specific IP or CIDR range whenever possible.
   - ⚠️ **`0.0.0.0/0` allows access from any IP — this is a significant security risk.** Only use it as a last resort for temporary testing and remove it immediately afterward. It should never be used in production.
4. Save changes

This is more secure than global Network Access settings as it only affects API access, not database connections.

Proceed to Step 4 (Determine Read-Only Access).

## Step 3c: Atlas Local Setup

If the user chooses Option C:

### 3c.1: Check Docker Installation

Verify Docker is installed:

```bash
docker info
```

If not installed, direct them to: https://www.docker.com/get-started

### 3c.2: Confirm Setup Complete

Atlas Local requires no credentials — the user is ready to go:

- Create deployments: `atlas-local-create-deployment`
- List deployments: `atlas-local-list-deployments`
- All operations work out of the box with Docker

**Skip Steps 4 and 5** (no configuration needed) and proceed to Step 6 (Next Steps).

## Step 4: Determine Read-Only vs Read-Write Access

**Only applies to Options A and B. Skip to Step 6 for Option C.**

Ask whether they want read-only or read-write access:

- **Read-Write** (default): Full data access, modifications allowed
  - Best for: Development, testing, administrative tasks

- **Read-Only**: Data reads only, no modifications
  - Best for: Production data safety, reporting, compliance

**If read-only**: include the read-only flag in the credential snippet in Step 5.
**If read-write**: omit it (defaults to read-write).

Proceed to Step 5 (Configure Credentials).

## Step 5: Configure Credentials

**Do not ask for or handle credentials** — provide exact instructions so the user can add them directly.

### 5.1: Add credentials

The user adds the variables to the environment of the MongoDB custom server in Settings.

Show the user the appropriate variables:

**For Connection String (Option A):**

```
MDB_MCP_CONNECTION_STRING=<paste-your-connection-string-here>
```

**For Service Account (Option B):**

```
MDB_MCP_API_CLIENT_ID=<paste-your-client-id-here>
MDB_MCP_API_CLIENT_SECRET=<paste-your-client-secret-here>
```

**If read-only was chosen (Step 4), also add:**

```
MDB_MCP_READ_ONLY=true
```

⚠️ Do not paste these values into the chat, and do not commit them to version control.

### 5.2: Verify

Ask the user to save the server in Settings and check that it connects. If it does not, check that the variable names are spelled exactly as above.

Proceed to Step 6 (Next Steps).

## Step 6: Next Steps

### For Options A & B (Connection String / Service Account):

1. **Reconnect the server**: Once the credentials are saved, the server must connect again with its new environment.

2. **Verify the server**: Once it is connected, test by performing a MongoDB operation.

3. **Using the Tools**:
   - Option A: Direct database access tools available
   - Option B: Additionally has Atlas Admin API tools and `atlas-connect-cluster`
   - **Important (Option B)**: Ensure your IP is in the service account's API Access List or all API calls will fail

### For Option C (Atlas Local):

1. **Ready to use**: No restart or configuration needed!

2. **Next steps**:
   - Create deployments: `atlas-local-create-deployment`
   - List deployments: `atlas-local-list-deployments`
   - Use standard database operations once connected

## Troubleshooting

- **Server doesn't pick up variables**: Check that they were saved in the MongoDB custom server's environment in Settings, and that the server connected again afterwards
- **Invalid connection string format**: Re-check the format; must start with `mongodb://` or `mongodb+srv://`
- **Atlas Admin API errors (Option B)**: Verify your IP is in the service account's API Access List
- **Read-only mode not working**: Check that `MDB_MCP_READ_ONLY=true` is in the custom server's environment
