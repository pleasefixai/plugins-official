---
title: Wrap up
description: Final next steps, test send, and optional return link
tags:
  - setup
  - wrap-up
  - mcp
  - cli
category: knock-setup
last_updated: 2026-07-30
---

# Wrap up

Once all earlier rules are complete, do the following in order.

## 1. Test send

Always send a test — do not ask whether they want one. Follow **exactly one** path below, matching how Knock tooling was connected earlier in this skill (MCP vs Knock CLI). Do not mix paths and do not set up MCP from the CLI path.

Pick one of the workflows that was built (prefer an API-triggerable one with an email channel if available). Note whether an **email** channel message was sent successfully — you need that for the finishing bang below. If the workflow is only source-triggered and cannot be run directly, say so in one line and skip to the final output (source path was already verified earlier).

### Recipient (both paths)

Resolve email and name the same way on either path:

1. Load whoami (MCP: `execute_mapi_read` `GET /v1/whoami`; CLI: `knock whoami`).
2. If `user_email` is present → use it as the recipient email. Use `user_name` for the recipient name when present and non-blank; otherwise fall back to `"Test User"`.
3. If `user_email` is null (service token auth) → ask for the email they used to sign up for Knock. End as the last line, bolded:

**What email did you use to sign up for Knock?**

   Use that email with name `"Test User"` (do not ask for a name).

Inline-identify recipient shape (both paths): `{"id": "1", "email": "USER_EMAIL", "name": "USER_NAME"}`.

### MCP path

Use this path only when Knock MCP was connected earlier. Do not fall back to the Knock CLI here.

1. Resolve the recipient per **Recipient (both paths)** above.
2. Call `start_knock_agent` with a prompt that includes **exactly** these constraints:
   - run this not in sandbox mode
   - recipient uses **inline identify** with the recipient object from above
3. **From name:** if the email (or other message) would come from an internal/system address that looks generic or technical, tell the Knock agent to set a realistic human-readable **from** name for the test (e.g. the product or company name). If the from already looks like a normal product sender, do not change it.
4. Poll with `get_knock_agent` until the run finishes.

Example prompt shape (substitute the whoami / provided email and name):

```text
Test workflow `[workflow_key]` in the development environment. Run this not in sandbox mode. Use inline identify for the recipient: `{"id": "1", "email": "USER_EMAIL", "name": "USER_NAME"}`. Use a minimal valid data payload for the workflow templates. If the message from address looks internal or generic, set a realistic from name for this test. Report the run result and a link or run id if available.
```

### Knock CLI path

Use this path only when tooling was connected via `rules/connect-knock-cli.md`. Do **not** add MCP, edit MCP config, or call `start_knock_agent` / `get_knock_agent`.

1. Resolve the recipient per **Recipient (both paths)** above (`knock whoami`).
2. Trigger the test with `knock workflow run` (see the `knock-cli` skill), using the same inline-identify recipient and a minimal valid `--data` payload for the workflow templates. Prefer the development environment.
3. **From name:** if you can set a from name via CLI/workflow config for this test and the current from looks internal or generic, set a realistic human-readable from name. Otherwise leave it.
4. Report the run result (run id / link if available). Do not hand off to MCP for the test send.

## 2. Final output

Then output the following in this exact order:

1. **What you can do next with Knock** — a short bulleted list. Always include:
   - **Set up in-app notifications** (notification feed / inbox) in the product.
   - If guides were created or mentioned in the plan/build list: note that guide **resources** alone are not enough — app wiring (providers, rendering, engagement) is done with `knock-in-app-ui`. Do **not** start that skill yet; you will ask below.
   - Then pick other relevant items as needed: send test runs of your workflows, create more workflows, add more channels (email, SMS, push, Slack), let users manage their notification preferences, add translations for localized notifications.
2. **Immediate steps to complete this implementation** — only if any remain, a short bulleted list, e.g.: commit the workflows and promote them to production, import or identify your users in Knock (see `rules/import-users.md` when ready — not required on first pass), configure production channel credentials and API keys, verify the trigger path end to end.
3. If the user provided a return URL, render this markdown link on its own line (substitute the provided URL):

[View setup in Knock dashboard](RETURN_URL)

4. **Close with Knock agent help** — always include this. Make clear the Knock agent can help with most remaining tasks. If Knock MCP was set up earlier in this skill, say they can just ask here in this chat. If the Knock CLI path was used, say they can keep asking here — the CLI stays authenticated; do **not** tell them to connect MCP.

Example closing line when MCP is connected:

> The Knock agent can help with most of these next steps — just ask here.

5. **Finishing bang on success (email only)** — if the test send succeeded, include this ASCII art email (fenced as a code block). If no email was sent, skip this step entirely.

```
 _______________________________________
|\                                     /|
| \                                   / |
|  \                                 /  |
|   \_______________________________/   |
|                                       |
|   Check your email inbox to view      |
|          the test message!            |
|_______________________________________|
```

6. **Guides next-step ask (only if guides were created or mentioned)** — first check whether any confirmed items (this chat or `knock-plan.md`) are **guides** or have Knock shape `guide` / `both`. That controls the in-app bullets above and whether to ask here. Do **not** invoke `knock-in-app-ui` until the user says yes. Just before the confirmation, note in one short line that the same skill can easily set up in-app notifications (feed / inbox) too if they wish. End with this confirmation as the **very last line**, on its own, and bolded:

**Want to wire up the Knock in-app guides next?**

If the user declines, stop (they can still ask later for in-app notifications). If they accept, continue with `knock-in-app-ui` — and offer in-app notifications there if they want those as well.
