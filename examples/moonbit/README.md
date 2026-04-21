# PowerMem MoonBit Client Example

A self-contained MoonBit client that talks to a running PowerMem server over its HTTP API. Mirrors the shape of `examples/go/` — inline client, inline models, one runnable `main`.

No dependencies beyond `moonbitlang/core` and `moonbitlang/async` (MoonBit's stdlib-tier packages). You can copy this directory into any MoonBit workspace and run it.

## Prerequisites

1. **MoonBit toolchain** — install from <https://www.moonbitlang.com>.
2. **A running PowerMem API server.** See [`examples/go/README.md`](../go/README.md#start-the-powermem-server) for the same setup steps (the server is language-agnostic):

   ```bash
   pip install powermem
   cp .env.example .env    # and add your LLM/embedding keys if using a remote provider
   powermem-server --host 0.0.0.0 --port 8000
   ```

## Run

```bash
# From the repository root
moon run --target native examples/moonbit

# Or from this directory
moon run --target native .
```

### Configuration

Two environment variables:

```bash
export POWERMEM_BASE_URL=http://localhost:8000   # default
export POWERMEM_API_KEY=your-api-key             # optional, only if server auth is on
```

## What it demonstrates

The demo walks through each core endpoint and prints the result:

1. **Health check** — `GET /api/v1/system/health`
2. **Create memory** — `POST /api/v1/memories` with `infer=true`; may yield multiple memories per input when LLM extraction is on.
3. **List memories** — `GET /api/v1/memories` with pagination.
4. **Search memories** — `POST /api/v1/memories/search` with a natural-language query.
5. **Update memory** — `PUT /api/v1/memories/{id}` on the first memory created above.
6. **Delete memory** — `DELETE /api/v1/memories/{id}` on the same memory.

Steps that require an embedding provider (2 and 4) print a helpful `skipped:` message instead of aborting, so you can still see the other sections when running without one configured.

## Files

| File | Purpose |
| ---- | ------- |
| `main.mbt`    | Runnable demo (`async fn main`) with numbered sections. |
| `client.mbt`  | Inline HTTP client. `Client::new`, `health`, `system_status`, `create_memory`, `list_memories`, `search_memories`, `update_memory`, `delete_memory`. |
| `models.mbt`  | Request and response types, with manual `FromJson` impls. |
| `moon.pkg`    | Package imports and `is-main` flag. |
| `moon.mod.json` | Module metadata and dependencies. |

## Looking for a packaged SDK?

For a full-coverage client (29 endpoints, typed results for batch and share operations, integration tests), see [`tonyfettes/powermem`](https://mooncakes.io/docs/tonyfettes/powermem) on mooncakes.io.
