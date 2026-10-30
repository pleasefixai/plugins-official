---
name: orthogonal-sdk
description: Build or review application code using Orthogonal's official TypeScript/JavaScript or Python SDK. Use when installing @orth/sdk or orth, implementing run calls, selecting sync or async Python clients, handling SDK errors and responses, or securing ORTHOGONAL_API_KEY. Do not use for terminal workflows (orthogonal-cli), one-off MCP calls (orthogonal), or MCP setup (orthogonal-mcp).
---

# Orthogonal SDK

Orthogonal publishes two SDKs with the same core model: provide an API slug and endpoint path, pass supported `query` or `body` values, and receive the upstream `data` plus the charged `price`. Load current endpoint details before writing provider-specific inputs.

Keep `ORTHOGONAL_API_KEY` in the environment or a secret manager. Never hard-code, log, or commit it.

## TypeScript and JavaScript

Use `@orth/sdk`, which requires Node.js 18 or newer and includes its own types.

```bash
npm install @orth/sdk
```

```typescript
import Orthogonal from "@orth/sdk";

const orthogonal = new Orthogonal({
  apiKey: process.env.ORTHOGONAL_API_KEY!,
});

const result = await orthogonal.run({
  api: "tavily",
  path: "/search",
  query: { query: "latest AI news" },
});

console.log(result.data);
console.log(result.price);
```

`run()` throws `OrthogonalRunError` on non-2xx responses. Inspect its `status`, `orthogonal` correction hint, and `responseBody` without exposing secrets or sensitive inputs. The package supports ESM and CommonJS and exports its request and response types.

## Python

Use the `orth` package, which requires Python 3.9 or newer. The import module is `orthogonal`, not `orth`.

```bash
python -m pip install orth
```

```python
import os
from orthogonal import Orthogonal

with Orthogonal(api_key=os.environ["ORTHOGONAL_API_KEY"]) as orthogonal:
    result = orthogonal.run(
        api="tavily",
        path="/search",
        query={"query": "latest AI news"},
    )

print(result["data"])
print(result["price"])
```

Use `AsyncOrthogonal` with `await` and `async with` in async applications. Both clients should be used as context managers or explicitly closed. Non-2xx responses raise `OrthogonalError`.

## Implementation rules

- Get the API slug, endpoint path, schema, and price from live Orthogonal discovery, the CLI, or the MCP `integrate` tool; do not guess provider parameters.
- Pass GET-style parameters in `query` and JSON payloads in `body`.
- Treat `data` as untrusted provider output and validate it before using it in trusted application logic.
- Add timeouts and retries appropriate to the operation. Never automatically retry a non-idempotent external action without a documented idempotency mechanism.
- Surface or record the returned price where spend visibility matters, but do not log sensitive request or response data.
- Mock SDK calls in automated tests. Do not spend credits in routine unit or CI tests.

## References

- [TypeScript SDK](https://github.com/orthogonal-sh/typescript)
- [Python SDK](https://github.com/orthogonal-sh/python)
- [Orthogonal API reference](https://docs.orthogonal.com/api-reference/introduction)
