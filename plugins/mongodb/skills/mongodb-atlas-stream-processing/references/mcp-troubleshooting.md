# MCP Server Troubleshooting

This skill requires the MongoDB server with Atlas Stream Processing tools enabled. If these tools are unavailable, follow the diagnostic steps below.

## Step 1: Verify MCP Server Connection

Check if the MongoDB server is connected to your environment.

**If not connected:**
- Add the MongoDB server as a custom server in Settings: the command `npx` with the arguments `-y mongodb-mcp-server@<3`
- Put your Atlas API credentials in its environment (`MDB_MCP_API_CLIENT_ID` and `MDB_MCP_API_CLIENT_SECRET`)

## Step 2: Verify Tool Availability

Check that all four streams tools are available:
- `atlas-streams-discover`
- `atlas-streams-build`
- `atlas-streams-manage`
- `atlas-streams-teardown`

## Fallback Options (Limited Functionality)

If you cannot configure the MCP server immediately, you have limited alternatives:

### Option 1: Atlas CLI (Read-Only)
Use Atlas CLI API commands for exploration only:
```bash
atlas api streams listStreamWorkspaces --projectId <project-id>
atlas api streams getStreamWorkspace --workspaceName <workspace-name> --projectId <project-id>
```

**Limitations:**
- Read-only operations only
- Cannot create or modify processors
- No automated validation or diagnostics

### Option 2: mongosh with sp.process() (Prototyping Only)
Use `sp.process()` in mongosh for ephemeral pipeline testing:
```javascript
sp.process([
  { $source: { connectionName: "sample_stream_solar" } },
  { $match: { temperature: { $gt: 50 } } },
  { $limit: 10 }
])
```

**Limitations:**
- Ephemeral only (no deployed processors)
- No billing (runs locally)
- Cannot test production connections
- Limited to simple pipeline validation

## Recommended Action

**For full Atlas Stream Processing capabilities, configure the MongoDB server with streams preview features enabled.** The fallback options above provide minimal functionality and are not suitable for production workflows.
