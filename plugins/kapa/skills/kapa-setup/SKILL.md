---
name: kapa-setup
description: Set up a Kapa project by connecting a knowledge source and checking it ingests. Use when the user wants to start with Kapa or add a source and has not said which kapa-setup-* skill applies.
---

# Set up a Kapa project

1. Call `list_projects` to confirm the user is signed in to the kapa MCP
   server. If it fails with an authentication error, tell them to run `/mcp`
   and sign in, then wait for them before retrying.
2. If there is more than one project, ask which one to use.
3. Ask what they want Kapa to answer questions about, and load the matching
   `kapa-setup-*` skill for what they choose rather than working the calls out
   yourself.
4. Do not pick filters for them: show the options and ask.
