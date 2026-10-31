# Implementing a Feature

When building new features, search for similar patterns first to ensure consistency.

## Checklist

```
Task Progress:
- [ ] Find similar implementations
- [ ] Read file structure
- [ ] Study a good example
- [ ] Check shared utilities
```

## Steps

### 1. Find Similar Implementations

```
code_finder: "repo:^github.com/org/repo$ existing CRUD feature similar to user settings"
```

`code_finder` runs its own search loop and returns candidate files with line ranges in one call — faster than iterating on `nls_search`/`keyword_search` manually. Fall back to `nls_search` for a broader semantic pass if `code_finder` doesn't surface a good match:

```
nls_search: "repo:^github.com/org/repo$ user settings CRUD"
```

Look for features that solve similar problems. Note the patterns used.

### 2. Explore File Structure

```
keyword_search: "repo:^github.com/org/repo$ file:src/features/ index.ts"
```

Understand how features are organised in this codebase.

### 3. Study a Representative Example

```
read_file: Read 2-3 files from a well-implemented similar feature
```

Pay attention to:
- Naming conventions
- File organisation
- Import patterns
- Error handling approach

### 4. Check for Shared Utilities

```
find_references: Trace usage of common utilities
```

Before creating new helpers, check if reusable utilities exist:
- Validation functions
- API wrappers
- UI components
- Type definitions

## Tips

- Don't create new patterns when existing ones work
- Match the style of surrounding code
- Check tests for usage examples of utilities
- Look at recent PRs for similar features
- Use `code_finder` as the first move when you're not yet sure where similar code lives; it's cheaper than several rounds of manual search
