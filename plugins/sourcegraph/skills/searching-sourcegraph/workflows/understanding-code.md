# Understanding Unfamiliar Code

When exploring systems you don't know, start broad and narrow down.

## Checklist

```
Task Progress:
- [ ] Get big picture via Deep Search
- [ ] Find entry points
- [ ] Trace implementation
- [ ] Review related tests
```

## Steps

### 1. Get the Big Picture

```
deepsearch: "How does order fulfillment work in this codebase?"
deepsearch_read: <URL or read token returned by the deepsearch call above>
```

`deepsearch` initiates the research job and returns a URL/token; `deepsearch_read` only reads back an existing job's results, so it must be called after `deepsearch`, never on its own. Deep Search provides architectural understanding. Ask "how" and "why" questions.

### 2. Find Entry Points

```
code_finder: "repo:X entry points for order fulfillment: route handlers, event listeners, CLI commands"
```

`code_finder` returns candidate files and line ranges in one call. If you already know the exact route pattern, `keyword_search` is faster:

```
keyword_search: "repo:X file:src/routes export.*order"
```

Look for:
- API route handlers
- Event listeners
- CLI commands
- UI component entry points

### 3. Trace the Implementation

```
go_to_definition: Jump to main handler
find_references: See how it's used
```

Follow the code path from entry point through business logic.

### 4. Review Related Tests

```
keyword_search: "repo:X file:.*\.test\.ts describe.*order"
```

Tests reveal:
- Expected behaviour
- Edge cases
- Usage patterns
- Integration points

## Tips

- Read 2-3 related files before synthesising
- Tests are documentation—read them
- Check for architecture docs in `docs/` or README files
- Use `code_finder` to jump straight to relevant files when you don't yet know exact symbols or paths
- Use `evaluator` if you need to tally or cross-reference results across many files (e.g. counting how many handlers still use a deprecated pattern)
