---
name: import
description: Imports memories from an exported Markdown file or another AI tool's rules files into the current project. Use when migrating from another project, restoring from backup, or setting up a new project with existing knowledge.
---

# Mem0 Import

Import memories from a mem0 export file into the current project.

## Execution

### Step 1: Determine the export file to import

If the user provided a filename as an argument to `/mem0:import <filename>`, use that file.

Otherwise, list `.md` files in the current directory whose names contain `mem0-export`:

```bash
ls -1 *.md 2>/dev/null | grep mem0-export || echo "No export files found"
```

If multiple files are found, ask the user which one to import. If none are found, print:
```
No mem0-export files found in the current directory.
Run /mem0:export first, or provide the filename: /mem0:import <path-to-file>
```

### Step 2: Parse the export file

Read the export file and extract its memory records. Each memory is a block
delimited by lines containing exactly `---`: first `key: value` lines (only the
first colon delimits; other lines are ignored), then, after the next `---`, the
memory content text up to the following `---`. Example block:

```
---
id: abc123
created_at: 2024-01-01T00:00:00Z
type: task_learnings
confidence: 0.9
branch: main
files: src/foo.py, src/bar.py
categories: coding_conventions, task_learnings
---
The actual memory content text goes here.
```

Build one record per block, skipping blocks whose content is empty once
trimmed. Each record has:
- `id` — original memory ID (for reference only; a new ID will be assigned on import)
- `type` — metadata type
- `confidence` — metadata confidence value
- `branch` — metadata branch
- `files` — list of associated files (the comma-separated value, split and trimmed)
- `categories` — list of categories (the same way)
- `content` — the memory text

If the file cannot be read or yields no records, print:
```
Failed to parse <filename> or file contains no valid memory blocks.
```
and stop.

### Step 3: Resolve identity

Determine the active identity:
- `user_id` from `MEM0_USER_ID` env var, else `$USER`, else `"default"`
- `project_id` (used as `app_id`) from `MEM0_PROJECT_ID` env var, or via the project resolver

### Step 4: Import each memory

For each record in the parsed JSON array, call `add_memory` with:

- `text="<record.content>"`
- `user_id=<active_user_id>`
- `app_id=<active_project_id>`
- `metadata={`
  - `"type": "<record.type>"` (if non-empty)
  - `"confidence": "<record.confidence>"` (if non-empty)
  - `"branch": "<record.branch>"` (if non-empty)
  - `"files": <record.files>` (the list, if non-empty)
  - `"source": "import"`
  - `}`
- `infer=False`

Notes:
- Do NOT pass the original `id` — the platform assigns a new ID.
- Skip records where `content` is empty.
- Continue importing even if individual records fail; track the count of successes.

### Step 5: Print results

```
Imported <N> memories into project <project_id>
```

Where `<N>` is the number of successfully imported memories.

If any failed:
```
Imported <N>/<total> memories into project <project_id> (<failed> failed)
```

## Importing from competing AI tools (`--tools`)

When invoked with `--tools` (e.g., `/mem0:import --tools`), detect and import
from competing AI tool configuration files:

### Supported tools

| Tool | File/directory |
|------|---------------|
| Cursor | `.cursorrules` |
| GitHub Copilot | `.github/copilot-instructions.md` |
| Cline | `memory-bank/` (directory of `.md` files) |
| Continue | `.continue/rules.md` |

### T1: Detect

```bash
test -f .cursorrules && echo "cursor: .cursorrules"
test -f .github/copilot-instructions.md && echo "copilot: .github/copilot-instructions.md"
test -d memory-bank/ && echo "cline: memory-bank/"
test -f .continue/rules.md && echo "continue: .continue/rules.md"
```

### T2: Ask user

List found files, ask which to import (numbers, comma-separated, or "all").
If none found:
```
No competing tool configuration files found.
Checked: .cursorrules, .github/copilot-instructions.md, memory-bank/, .continue/rules.md
```

### T3: Run import

For each selected tool, read its file (for Cline, every `.md` file in
`memory-bank/`) and split it into sections at its Markdown headings. Store each
section with `add_memory` (`text=<section>`, `user_id=<active_user_id>`,
`app_id=<active_project_id>`, `metadata={"source": "<tool>-import"}`,
`infer=False`), following the notes below. Tools: `cursorrules`, `copilot`,
`cline`, `continue`.

### T4: Report

```
Imported <N> memories into <project_id> (cursor: <N>, copilot: <N>)
```

Notes: `infer=False`, tagged `metadata.source=<tool>-import`, sections <50 chars
skipped, chunks >10k chars truncated. Before storing a section, search for it
with `search_memories` and skip it when the same text is already stored, so a
re-run adds no duplicates.

---

## Error Handling

- If `add_memory` calls fail consistently (e.g. auth error), report the issue and stop early.
