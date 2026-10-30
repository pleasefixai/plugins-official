---
title: Knock directory structure
description: Understanding the knock directory layout, configuration files, and resource organization
tags:
  - knock
  - cli
  - directory-structure
  - configuration
  - knock-json
  - workflows
  - layouts
category: knock-cli
last_updated: 2026-09-02
---

# Knock directory structure

## Project configuration

### The knock.json file

Running `knock init` creates a `knock.json` file in the current directory. This file configures where Knock resources are stored. The command prompts for the resources directory and suggests `.knock`, so accepting the default produces:

```json
{
  "$schema": "https://schemas.knock.app/cli/knock.json",
  "knockDir": ".knock"
}
```

**Configuration options:**

| Property | Description |
|----------|-------------|
| `knockDir` | Path to the directory containing Knock resources |

`knockDir` has no default value. The `.knock` above is the prefilled answer to the `init` prompt, and you can enter any path you like. `.knock` is a hidden directory.

When `knock.json` is present, all CLI operations use `knockDir` as the root for reading and writing resources. The CLI locates `knock.json` by walking up from the current directory, but a relative `knockDir` resolves against the **current working directory**, not against the location of `knock.json`. Running a command from a subdirectory will therefore look for the resources directory in the wrong place — run CLI commands from the directory that contains `knock.json`.

When `knock.json` is absent, there is no configured root. Resource subcommands fall back to the current working directory, so `knock layout pull --all` run from your project root would write layout directories directly into that root rather than into a `layouts/` subdirectory. The top-level `knock pull` and `knock push` do not fall back — they error out unless you pass `--knock-dir`. To target a specific directory, pass `--knock-dir` on `knock pull` / `knock push`, or the matching per-resource flag on a subcommand (see the table below).

**Directory flags by command:**

| Command | Flag |
|---------|------|
| `knock pull` / `knock push` | `--knock-dir` |
| `knock workflow pull/push/validate` | `--workflows-dir` |
| `knock layout pull/push/validate` | `--layouts-dir` |
| `knock guide pull/push/validate` | `--guides-dir` |
| `knock partial pull/push/validate` | `--partials-dir` |
| `knock message-type pull/push/validate` | `--message-types-dir` |
| `knock translation pull/push/validate` | `--translations-dir` |
| `knock audience pull/push/validate` | `--audiences-dir` |
| `knock schema pull/push` | `--schemas-dir` |

These directory flags exist only on the `pull`, `push`, and `validate` subcommands; `get`, `list`, `open`, and `new` do not accept them. `knock schema` has only `pull` and `push`, so `--schemas-dir` is limited to those.

Each per-resource flag also depends on `--all`, so pass it as `knock workflow pull --all --workflows-dir=<path>`. `--schemas-dir` is the exception and works with or without `--all`.

## Directory layout

The knock directory contains subdirectories for each resource type. These names are fixed by the CLI and are what `knock pull` writes and `knock push` expects:

```
.knock/
├── audiences/                    # Audiences
│   └── {audience-key}/
│       └── audience.json         # Audience configuration
│
├── partials/                     # Reusable template partials
│   └── {partial-key}/
│       ├── partial.json          # Partial configuration
│       └── content.html          # Content file; extension varies by type
│
├── layouts/                      # Email layout templates
│   └── {layout-key}/
│       ├── layout.json           # Layout configuration
│       ├── html_layout.html      # HTML template; .mjml for MJML layouts
│       └── text_layout.txt       # Plaintext layout template
│
├── workflows/                    # Workflow definitions
│   └── {workflow-key}/           # One directory per workflow
│       ├── workflow.json         # Main workflow definition
│       └── {step-ref}/           # Channel step content (optional)
│           └── ...               # Template files
│
├── message-types/                # Message type schemas for guides
│   └── {message-type-key}/
│       ├── message_type.json     # Schema and metadata
│       └── preview.html          # Optional; Liquid template for dashboard preview
│
├── guides/                       # In-app guides (lifecycle messaging)
│   └── {guide-key}/
│       └── guide.json            # Guide definition and content
│
├── translations/                 # Translation files
│   └── {locale}/                 # Directory per locale code
│       ├── {locale}.json         # e.g. en.json
│       └── {namespace}.{locale}.json  # e.g. admin.en.json
│
└── schemas/                      # Item schemas for users, tenants, objects
    ├── user.json
    ├── tenant.json
    └── objects/
        └── {collection}.json
```

`knock pull` and `knock push` operate on audiences, partials, layouts, workflows, message types, guides, and translations. Schemas are managed separately with `knock schema pull` and `knock schema push`.

Commit history lives in Knock and is reached with `knock commit list` and related commands.

## Workflow structure

Each workflow lives in its own directory under `workflows/`:

```
workflows/{workflow-key}/
├── workflow.json                 # Main workflow definition
└── {step-ref}/                   # Directory per channel step (optional)
    └── ...                       # Template content files
```

### workflow.json

The main workflow definition file contains:

```json
{
  "name": "Order Confirmation",
  "description": "Sends order confirmation notifications",
  "categories": ["transactional", "orders"],
  "steps": [
    {
      "ref": "email-step",
      "type": "email",
      "template": {
        "subject": "Order #{{data.order_id}} confirmed",
        "visual_blocks@": "email-step/visual_blocks.json"
      }
    }
  ]
}
```

**Key fields:**

| Field | Description |
|-------|-------------|
| `name` | Display name for the workflow |
| `description` | Optional description |
| `categories` | Optional array of category tags |
| `steps` | Array of workflow steps |

### Step directories

Channel steps (email, SMS, push, etc.) can have their template content extracted into separate files within a step directory:

```
workflows/order-confirmation/
├── workflow.json
└── email-step/
    ├── visual_blocks.json        # Email visual blocks structure
    └── visual_blocks/
        ├── 1.content.md          # First block content
        ├── 2.content.md          # Second block content
        └── ...
```

**When step directories exist:**
- Channel steps with extracted template content
- Complex templates that benefit from separate files

**When step directories don't exist:**
- Function steps (delay, batch, branch, fetch, etc.) never have directories
- Simple templates with inline content

## Email layouts

Email layouts define reusable structure for email templates:

```
layouts/{layout-key}/
├── layout.json                   # Layout configuration
├── html_layout.html              # HTML layout template
└── text_layout.txt               # Plaintext layout template
```

MJML layouts use the same structure with the HTML template written as `html_layout.mjml`. The extension follows the layout's `is_mjml` setting, which Knock supplies when the layout is pulled.

A directory is recognized as an email layout when it contains a `layout.json` file.

### layout.json

```json
{
  "name": "Default Layout",
  "html_layout@": "html_layout.html",
  "text_layout": "{{ content }}",
  "footer_links": [
    {
      "label": "Unsubscribe",
      "url": "{{ unsubscribe_url }}"
    }
  ]
}
```

## Guides

Guides are in-app UI components for lifecycle messaging (banners, modals, announcements). Each guide lives in its own directory:

```
guides/{guide-key}/
└── guide.json                    # Guide definition with steps and content
```

### guide.json

A guide contains a `name` and a `steps` array. Each step references a message type via `schema_key` and `schema_variant_key`, with content in `values`. See the guides and message types rule file for full details.

## Message types

Message types define the schema for guide content. They live under `message-types/`:

```
message-types/{message-type-key}/
├── message_type.json             # Schema with variants and fields
└── preview.html                  # Optional; Liquid template for dashboard preview
```

### message_type.json

The message type schema defines `name`, `description`, `icon_name`, and `variants`. Each variant has `key`, `name`, and `fields`. The `preview@` field references the preview HTML file. See the guides and message types rule file for schema details.

## File path references

Knock uses the `@` suffix convention to indicate file path references:

```json
{
  "content@": "visual_blocks/1.content.md",
  "html_body@": "body.html",
  "visual_blocks@": "email-step/visual_blocks.json"
}
```

**Path resolution rules:**

1. Paths are **relative to the file containing the reference**
2. In `workflow.json` (at workflow root): paths start from the workflow directory
3. In `visual_blocks.json` (inside step directory): paths are relative to that step directory

**Example:**

```
workflows/my-workflow/
├── workflow.json                 # Uses: "visual_blocks@": "email-step/visual_blocks.json"
└── email-step/
    ├── visual_blocks.json        # Uses: "content@": "visual_blocks/1.content.md"
    └── visual_blocks/
        └── 1.content.md
```

**Common mistake:** Doubling the step directory path. If you're in `email-step/visual_blocks.json`, use `visual_blocks/1.content.md`, NOT `email-step/visual_blocks/1.content.md`.

## Resource identification

Resources are identified by their directory name (the key):

| Resource Type | Key Location | Example |
|---------------|--------------|---------|
| Workflow | Directory name under `workflows/` | `workflows/order-confirmation/` → key: `order-confirmation` |
| Email Layout | Directory name under `layouts/` | `layouts/default/` → key: `default` |
| Guide | Directory name under `guides/` | `guides/welcome-modal/` → key: `welcome-modal` |
| Message Type | Directory name under `message-types/` | `message-types/banner/` → key: `banner` |
| Partial | Directory name under `partials/` | `partials/footer/` → key: `footer` |
| Audience | Directory name under `audiences/` | `audiences/new-signups/` → key: `new-signups` |

This key is used in CLI commands:

```bash
knock workflow push order-confirmation
knock layout push default
knock guide push welcome-modal
knock message-type push banner
knock audience push new-signups
```

Translations are referenced by locale rather than by directory key, as `<locale>` or `<namespace>.<locale>`:

```bash
knock translation push en
knock translation push admin.en
```
