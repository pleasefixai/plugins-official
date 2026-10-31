---
name: searching-sourcegraph
description: Use when the user needs to search or navigate code with Sourcegraph MCP tools. Provides disciplined search workflows for finding implementations, understanding systems, debugging issues, fixing bugs, and reviewing code.
---

# Searching Sourcegraph

Search before you build. Existing patterns reduce tokens, ensure consistency, and surface tested solutions.

## Tool Selection Logic

**Start here:**

1. **Don't know the exact symbol, file, or even which directory?** → `code_finder`
2. **Know the exact symbol or pattern?** → `keyword_search`
3. **Know the concept, not the code?** → `nls_search`
4. **Need to understand how/why?** → `deepsearch` → `deepsearch_read`
5. **Tracing a symbol's usage?** → `find_references`
6. **Need full implementation?** → `go_to_definition` → `read_file`
7. **Need to know what repos a user has worked on?** → `get_contributor_repos`
8. **Need to tally, cross-reference, or compute over many search results?** → `evaluator`

| Goal | Tool |
|------|------|
| Locate relevant files/lines from a description | `code_finder` |
| Concepts/semantic search | `nls_search` |
| Exact code patterns | `keyword_search` |
| Trace usage | `find_references` |
| See implementation | `go_to_definition` |
| Initiate a deep search | `deepsearch` |
| Read deep search results | `deepsearch_read` |
| Read files | `read_file` |
| Browse structure | `list_files` |
| Find repos | `list_repos` |
| Search commits | `commit_search` |
| Track changes | `diff_search` |
| Compare versions | `compare_revisions` |
| Find repos a user has worked on | `get_contributor_repos` |
| Aggregate/cross-reference results programmatically | `evaluator` |

**About the newer tools:**

- **`code_finder`** — an agentic search tool: give it a natural-language description of what you're looking for and it runs its own search loop over the repo, returning matching file paths and line ranges with a short note on each. It's faster and cheaper than chaining several `keyword_search`/`nls_search` + `read_file` calls, so reach for it first when you don't yet know the exact symbol or file to target. It also powers file discovery inside Deep Search.
- **`evaluator`** — runs a sandboxed Lua script that can itself call `keyword_search`, regex, `commit_search`, or `diff_search` and then aggregate, cross-reference, or compute over the results. Use it instead of manually eyeballing raw output when you need counts, joins, or filters across many results (e.g. "how many files under `src/api/` still call the deprecated helper").
- **`deepsearch`** initiates a multi-step research job over the codebase and returns a URL/token; **`deepsearch_read`** reads back the resulting conversation.

**Server and endpoint note:** this plugin does not carry the Sourcegraph server. If its tools are not available, ask the user to add it as a custom server (HTTP) in Settings: the address `https://<your-sourcegraph-instance>/.api/mcp/all`, with the header `Authorization` set to `token <your Sourcegraph access token>`. The `/.api/mcp/all` endpoint exposes the full tool suite above (including `code_finder` and `evaluator`). Sourcegraph's default `/.api/mcp` endpoint only exposes a curated subset (`read_file`, `list_files`, `keyword_search`, `nls_search`, `list_repos`, `commit_search`, `diff_search`, `deepsearch_read`) and won't have code navigation, `code_finder`, or `evaluator` — and notably lacks `deepsearch` itself, so on that endpoint `deepsearch_read` can only fetch results of a job started elsewhere (e.g. the web UI), not run a new one. If any of those tools are missing, check that the custom server's address ends in `/.api/mcp/all`, not `/.api/mcp`.

## Scoping (Always Do This)

```
repo:^github.com/ORG/REPO$           # Exact repo (preferred)
repo:github.com/ORG/                 # All repos in org
file:.*\.ts$                         # TypeScript only
file:src/api/                        # Specific directory
file:.*\.test\.ts$ -file:__mocks__   # Tests, exclude mocks
```

Start narrow. Expand only if results are empty.

Combine filters: `repo:^github.com/myorg/backend$ file:src/handlers lang:typescript`

## Context-Aware Behaviour

**When the user provides a file path or error message:**
- Extract symbols, function names, or error codes
- Search for those exact terms first
- Trace references if the error involves a known symbol

**When the user asks "how does X work":**
- Use `deepsearch` to initiate the search, then `deepsearch_read` to retrieve results
- Follow up with `read_file` on key files mentioned in the response

**When the user asks who worked on something or what repos a contributor has touched:**
- Use `get_contributor_repos` with one or more usernames to discover their active repositories
- Then scope subsequent searches to those repos

**When the user is implementing a new feature:**
- Use `code_finder` to locate similar existing implementations first
- Read tests for usage examples
- Check for shared utilities before creating new ones

**When troubleshooting an error, build failure, or runtime exception:**
- Extract exact symbols, error codes, or log lines from the stack trace or build output
- Search for the error site, then trace the full call chain with `find_references`
- Check recent changes with `diff_search` and `commit_search` early — regressions are common
- Identify all affected code paths and services before proposing a fix

**When fixing a bug:**
- Extract exact symbols from the error message or stack trace
- Search for the error site, then trace the full call chain with `find_references`
- Check recent changes with `diff_search` and `commit_search` early — regressions are common
- Find all affected code paths before writing the fix
- Read existing tests to understand intended behaviour

## Workflows

For detailed step-by-step workflows, see:
- `workflows/implementing-feature.md` — when building new features
- `workflows/understanding-code.md` — when exploring unfamiliar systems
- `workflows/debugging-issue.md` — when troubleshooting errors, build failures, stack traces, support issues, or runtime exceptions
- `workflows/fixing-bug.md` — when fixing bugs with extensive Sourcegraph search
- `workflows/code-review.md` — when reviewing a pull request or changeset

## Efficiency Rules

**Minimise tool calls:**
- Chain searches logically: `code_finder`/search → read → references → definition
- Don't re-search for the same pattern; use results from prior calls
- Prefer `keyword_search` over `nls_search` when you have exact terms (faster, more precise)
- Prefer `code_finder` over several rounds of `keyword_search`/`nls_search` + `read_file` when you're still narrowing down where the relevant code lives

**Batch your understanding:**
- Read 2-3 related files before synthesising, rather than reading one and asking questions
- Use `deepsearch` + `deepsearch_read` for "how does X work" instead of multiple keyword searches
- Use `evaluator` instead of manually cross-referencing multiple raw result sets when you need counts, joins, or filters across many matches

**Avoid common token waste:**
- Don't search all repos when you know the target repo
- Don't use `deepsearch` for simple "find all" queries — `keyword_search` is faster
- Don't re-read files you've already seen in this conversation
- Don't hand-tally results across many `keyword_search`/`commit_search`/`diff_search` calls — use `evaluator` to aggregate programmatically instead

## Query Patterns

| Intent | Query |
|--------|-------|
| React hooks | `file:.*\.tsx$ use[A-Z].*= \(` |
| API routes | `file:src/api app\.(get\|post\|put\|delete)` |
| Error handling | `catch.*Error\|\.catch\(` |
| Type definitions | `file:types/ export (interface\|type)` |
| Test setup | `file:.*\.test\. beforeEach\|beforeAll` |
| Config files | `file:(webpack\|vite\|rollup)\.config` |
| CI/CD | `file:\.github/workflows deploy` |

For more patterns, see `query-patterns.md`.

## Output Formatting

**Search results:**
- Present as a brief summary, not raw tool output
- Highlight the most relevant file and line
- Include a code snippet only if it directly answers the question

**Code explanations:**
- Start with a one-sentence summary
- Use the codebase's own terminology
- Reference specific files and functions

**Recommendations:**
- Present as numbered steps if actionable
- Link to specific patterns found in the codebase
- Note any existing utilities that should be reused

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Searching all repos | Add `repo:^github.com/org/repo$` |
| Too many results | Add `file:` pattern or keywords |
| Missing relevant code | Try `nls_search` for semantic matching |
| Not understanding context | Call `deepsearch` to run the research job, then `deepsearch_read` to fetch its output |
| Guessing patterns | Read implementations with `read_file` |
| Many rounds of trial-and-error search | Use `code_finder` to locate candidates in one call |
| Manually tallying results across many searches | Use `evaluator` to aggregate/cross-reference programmatically |

## Principles

- Start narrow, expand if needed
- Chain tools: `code_finder` → search → read → find references → definition
- Check tests for usage examples
- Read before generating
- Reach for `evaluator` rather than eyeballing raw output when a question requires aggregating across many results
