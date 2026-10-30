---
name: vibecode
description: Build and change iPhone apps and web apps with Vibecode. Use when the user wants to make an app, change an app they built in Vibecode, check on a build, or find out why their Vibecode app isn't working.
---

# Vibecode

Vibecode's agent writes, builds and tests apps in the user's Vibecode account. These tools start that work, follow it and look inside the app. Every tool acts on the account the user connected.

## Building and changing
- To make a new app, call `create_app` with a clear brief: what the app is for, its screens, and anything the user asked for. A build takes several minutes.
- To change an app, call `edit_app`. If the agent is still working on that app, the change waits its turn and starts by itself.
- After either, call `wait_for_build` until it says the build is done, then tell the user. Each call waits up to about a minute and a half.
- `get_build_status` answers at once, without waiting.
- `show_app` and `get_handoff_links` give links to open the app in Vibecode, on the user's iPhone, or to publish it to the App Store from Vibecode.

## Following the agent
- `get_activity` shows what the agent did and why a build failed.
- `stop_build` stops the agent's current work and anything waiting behind it. Ask the user first.

## When something isn't working
- `get_logs` reads the app's logs: the workspace's while it runs, or the published backend's (`where: live`).
- `list_files` and `read_file` show the app's code. `.env` files can't be read, and keys in any output are hidden.
- `run_command` runs a command in the app's workspace and stops after 60 seconds. Use it to look, not to change the app: changes go through `edit_app`, so Vibecode's agent makes and tests them.
- `get_screenshot` shows the app's latest screenshot.

## Versions
- `list_versions` lists the app's saved versions.
- `restore_version` brings an earlier version back as a new version, so later versions stay and the restore can be undone. Ask the user first.

## Managing apps
- `list_projects` finds the user's apps. Refer to apps by name; never show project ids to the user.
- `rename_app` and `duplicate_app` change only the app named.
- `delete_app` removes the app from Vibecode, and only Vibecode support can bring it back. Use it only when the user asks, and confirm the app's name with them first.

## Account and credits
- `get_profile` names the connected account, its plan and its credits.
- Builds and changes use Vibecode credits. When a tool says the account needs a plan or more credits, pass on its link: plans and credits are managed on vibecodeapp.com, and nothing is sold in the chat.
