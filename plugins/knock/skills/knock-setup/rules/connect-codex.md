---
title: Connect Knock in ChatGPT and Codex
description: Route ChatGPT and Codex sessions by host interface — in-app plugin, Codex CLI /plugins, IDE extension unsupported
tags:
  - setup
  - plugin
  - cli
  - chatgpt
  - codex
category: knock-setup
last_updated: 2026-09-03
---

# Connect Knock in ChatGPT and Codex

First identify the current surface using only the session's host interface. Do not determine the surface from shell access. An in-app Codex agent may also have a terminal, so shell access is not evidence of Codex CLI.

- **Codex CLI** — the user launched the interactive Codex terminal interface by running `codex`. CLI slash commands such as `/plugins` are available. → Follow the Codex CLI path.
- **In-app** — the conversation is running in ChatGPT on the web, mobile, or desktop, including Codex inside the ChatGPT desktop app. → Follow the in-app path.
- **Codex IDE extension** — the agent is embedded in an editor such as VS Code. Do not classify this as in-app merely because it has a UI or shell access. Plugins are not currently supported in the IDE extension. → Explain that limitation and stop.
- **Unclear** — ask one question: **Are you using ChatGPT, the Codex desktop app, the Codex IDE extension, or the terminal interface launched with `codex`?**

Do not ask about a Knock account. Plugin sign-in covers signup. Do not install skills separately on any surface. Plugin packages provide their own bundled skills and tools. Do not use `npx skills add`, a skill installer, or a manually configured Knock MCP server. Do not paste `https://mcp.knock.app/mcp`. Do not run `codex mcp add`. Do not paste an unverified plugin URL. The verified Knock listing URL may be provided only after searches by both provider name and exact plugin ID fail.

A plugin connection and successful authentication are separate states:

- **Connected.** The user completed the plugin's sign-in or connection flow.
- **Authenticated.** A Knock tool call succeeds in the current conversation.

Never describe Knock as authenticated based only on the connection UI or OAuth redirect.

## In-app path

Use this path only in ChatGPT or Codex inside the ChatGPT desktop app.

If Knock tools are already available, skip directly to the authentication checkpoint.

1. Search the plugin directory for the exact provider name **Knock**.
2. If no exact match is returned, search once using the exact plugin ID `plugin_asdk_app_6a8dddd50424819196928510eff4c70f`.
3. If Knock is found, surface its inline connection control and wait for the user to connect it. Do not substitute a fuzzy or similarly named result.
4. If both searches fail, provide the verified listing:
   `https://chatgpt.com/plugins/plugin_asdk_app_6a8dddd50424819196928510eff4c70f`
   Ask the user to open it, connect Knock, and return to the conversation. This direct-listing fallback is permitted only after both directory searches fail.
5. After connection, call `list_environments`. If unavailable, call `execute_mapi_read` with `GET /v1/whoami`.
6. Authentication is verified only when a Knock tool call succeeds in the current conversation.

If the call succeeds, say setup is done in one short line and continue to `discover-workflows`.

If Knock was connected during the current Codex task but its tools are not available, instruct the user to start a new task. Do not repeat plugin discovery or install anything separately. Provide this continuation prompt, then stop:

```text
Continue Knock setup with the knock-setup skill.

Knock was connected in the previous task, but authentication has not yet been verified in this task. Do not repeat plugin discovery or ask about a Knock account.

First action: call list_environments. If unavailable, call execute_mapi_read with GET /v1/whoami.

After a successful Knock tool call:
Resume from: discover-workflows
Confirmed to build: none confirmed yet
Skipped: none
Deferred: none
Next action: propose workflows
```

End with this as the last line, bolded:

**Open a new task, paste the prompt above, and continue there.**

In the new task, call a Knock tool before doing anything else. If the call succeeds, authentication is verified; continue to `discover-workflows`. If the tool is available but requests authorization, surface the authorization control and wait. If no Knock tools are available, search the plugin directory once by provider name **Knock**, then once by exact plugin ID. If both searches fail, provide the verified listing and stop.

The direct listing is only a fallback for opening and connecting the plugin; it does not itself prove that authentication succeeded.

## Codex CLI path

Use this path only when the user is inside the interactive terminal interface launched with `codex`.

1. Ask the user to enter `/plugins`.
2. Search the CLI plugin browser for the exact provider name **Knock**.
3. If necessary, search for the exact plugin ID `plugin_asdk_app_6a8dddd50424819196928510eff4c70f`.
4. Install the exact Knock plugin and complete any connection or authentication prompts shown by the CLI.
5. Start a new Codex CLI session after installation so the plugin's bundled capabilities load.
6. In the new session, call `list_environments`. If unavailable, call `execute_mapi_read` with `GET /v1/whoami`.
7. Authentication is verified only when a Knock tool call succeeds in that session.

Provide this continuation prompt for the new session, then stop:

```text
Continue Knock setup with the knock-setup skill.

The Knock plugin was installed in the previous Codex CLI session, but authentication has not yet been verified here. Do not repeat plugin discovery or ask about a Knock account.

First action: call list_environments. If unavailable, call execute_mapi_read with GET /v1/whoami.

After a successful Knock tool call:
Resume from: discover-workflows
Confirmed to build: none confirmed yet
Skipped: none
Deferred: none
Next action: propose workflows
```

End with this as the last line, bolded:

**Start a new Codex CLI session, paste the prompt above, and continue there.**

Do not use `npx skills add`, a skill installer, or a manually configured Knock MCP server on either path.

For users without an account, the plugin's sign-in doubles as signup: they'll create their account, complete onboarding, and be redirected back automatically. If the redirect doesn't complete (e.g. they land on the dashboard instead), have them finish signup there, then continue from the authentication checkpoint for this surface.

**Hard gate:** do not discover, build, implement, or wrap up until a Knock tool call succeeds in the current conversation.
