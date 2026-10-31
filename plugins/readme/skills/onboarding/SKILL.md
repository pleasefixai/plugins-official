---
name: onboarding
description: Get a new customer from zero to a live ReadMe developer hub. Use when someone is new to ReadMe, asks what ReadMe is, wants to sign up, create a project, publish their first API reference or guide, or needs an API key for this plugin. Explains the product and walks the web-UI setup flow.
---

# ReadMe onboarding

> Onboarding endpoints are coming soon. Until then this skill only covers the web-UI flow and ReadMe basics.

## Tools

- `search`
- `fetch`
- `execute-request`

## What ReadMe is

ReadMe hosts a developer hub for your API at `{subdomain}.readme.io` or a custom domain. One hub contains:

| Section | Content |
| --- | --- |
| Guides | Markdown pages in categories, with a sidebar |
| API Reference | Interactive docs generated from an OpenAPI or Swagger definition, with a Try It console |
| Recipes | Step-by-step code walkthroughs |
| Changelog | Release notes, shared across versions |
| Custom Pages | Free-form Markdown or HTML pages |

Guides, reference, recipes and custom pages live on a **branch** (a version such as `1.0` or `stable`). The changelog does not. Ask AI and the project's MCP server answer questions from the hub content. Metrics track page views, search, page quality, and, with SDK setup, API calls.

Plans: Starter (free), Pro, Enterprise. Enterprise supports child projects and Developer Metrics API reads.

## Quick Start

1. Sign up at `https://dash.readme.com/signup`.
2. Click **Create New Project**. Set a name, upload a logo (ReadMe picks brand colors from it), and choose the subdomain.
3. Add the API definition under **API Reference**: upload an OpenAPI file, import a URL, build one from scratch, or run `npx rdme openapi upload <file>` from a terminal. ReadMe validates the file and renders every endpoint.
4. Write the first guide under **Guides**. Use the AI Agent for a draft or the editor for a blank page. A "Getting Started" page is the usual first one.
5. Generate an API key at **Configuration → API Keys**, URL `https://dash.readme.com/project/{subdomain}/v{version}/api-key`.
6. Attach the key. The plugin's own `readme` server is anonymous and cannot read the key. The user registers a server under the same name, which replaces the plugin's one. The command differs per client: use the registration table in the `mcp-auth` skill, which also covers repairing a key that is already set.
7. Verify: `execute-request` with spec title `ReadMe API`, `GET https://api.readme.com/v2/projects/me`. A 200 with the project name means the plugin is wired to the right project. `Missing Security Schemes` means the registration is sending no key; a 401 titled `The API key couldn't be located.` means the key is wrong; a 500 titled `An unknown error has occurred.` means it resolved to an empty string. In every case, go back to step 5.

After step 7, the `mcp-server` skill covers which spec and which project everything else lands in.

## Driving the browser yourself

Steps 1 to 5 are all browser work. If you can drive a browser, offer to do them in the user's own browser instead of only listing the steps: open the signup page, create the project, upload the API definition, and open the API Keys page. Let the user type credentials and payment details themselves. Steps 6 and 7 stay in the terminal.

Find the row for the client you are running in. If you cannot tell which one that is, ask rather than guess.

| Client | Drive the browser with |
| --- | --- |
| Claude Code | `mcp__claude-in-chrome__*`, when the Claude in Chrome extension is connected |
| ChatGPT desktop app or ChatGPT web | `@Browser`. It has its own profile, so the user signs in to ReadMe there, and it asks before submitting forms. It cannot upload files, so for step 3 import the API definition by URL or run `npx rdme openapi upload <file>` from a terminal |
| Codex CLI, Codex IDE extension, Cursor | No browser of their own. List the steps for the user |

## When you cannot install anything yourself

On a chat surface you have no shell and cannot add a marketplace, install a plugin or edit MCP config. Do not attempt it and do not ask the user to run commands there. If the ReadMe tools are missing, the user has to install the plugin by hand. Find their client below and give them those steps exactly.

| Client | Steps |
| --- | --- |
| Claude Desktop, Cowork, claude.ai | Click **Customize** in the left sidebar, then **Plugins** — in Cowork, open the **Cowork** tab first. Under **Personal plugins**, click **+** → **Add marketplace** and enter `readmeio/agent-plugins`. Find **readme** in the list, click **Install**, then start a new chat so the tools load. Plugins need a paid Claude plan; on Team and Enterprise an owner may have disabled personal marketplaces, in which case they add it under **Organization settings → Plugins** |
| ChatGPT desktop app | Open the **Plugins** tab and click **Add marketplace**. Enter `readmeio/agent-plugins` as the source, leave the Git ref as `main` and the sparse paths empty, then click **Add marketplace**. Install **readme** from the new marketplace and start a new chat so the tools load |
| ChatGPT web | There is no marketplace option, only the plugin directory. Until the ReadMe plugin is listed there, the user can still add the MCP server on its own: turn on **Developer mode** under **Settings → Security and login**, open **Plugins**, click **+** next to the search box, and in the **New Plugin** form set the name to `readme`, the server URL to `https://docs.readme.com/mcp`, and authentication to **No Auth**. That gives the tools but not the skills, so keep this skill's content in the conversation yourself |
| Cursor | Open **Cursor Settings → Plugins**, search for **ReadMe**, click **Install** and choose project or user scope. Or run `/add-plugin readme` in chat |

On the chat surfaces above the ReadMe connector stays read-only once installed: `search`, `fetch` and the endpoint tools work on public projects, but there is no way to supply an API key, so steps 6 and 7 of the Quick Start do not apply and write tools such as `update-docs` fail. Say so before the user tries. For creating or updating pages, offer to continue in a CLI or editor with the server registered as in step 6.

## Reading the docs meanwhile

Use `search` for a question, then `fetch` with the returned id. Useful pages:

| Id | Page |
| --- | --- |
| `main/quickstart` | Three-step setup |
| `main/creating-a-project` | Project settings on creation |
| `main/openapi-upload-and-management` | Upload, sync, and re-sync an OpenAPI file |
| `main/branches` | How branches and versions work |
| `ref:main/intro-to-the-readme-api` | API v2 overview and auth |
| `main/sdks` | Metrics SDKs for API logs |
