# tonyfettes/powermem

Async HTTP client SDK for [PowerMem](https://github.com/oceanbase/powermem), a self-hosted memory service. Targets the MoonBit `native` backend.

## Install

```bash
moon add tonyfettes/powermem
```

Add to your `moon.pkg.json` imports:

```json
{
  "import": [
    "tonyfettes/powermem",
    "moonbitlang/async"
  ]
}
```

## Usage

```moonbit
async fn main {
  let client = @powermem.Client::new(base_url="http://127.0.0.1:8000")

  // Create a memory. The server runs LLM fact extraction, so a single input
  // may yield zero or more memories.
  let created = client.create_memory(
    content="The user prefers dark mode",
    user_id="alice",
  )

  // Semantic search.
  let results = client.search(query="preferences", user_id="alice")
  for hit in results.results {
    println("\{hit.content} (score=\{hit.score})")
  }

  // Delete a user's memories. Returns counts for auditing.
  let summary = client.delete_user_memories(user_id="alice")
  println("deleted \{summary.deleted_count} of \{summary.total}")
}
```

## Authentication

Pass `api_key` when the server has one configured. The client attaches it as `X-API-Key`:

```moonbit
let client = @powermem.Client::new(
  base_url="https://memories.example.com",
  api_key="sk-...",
)
```

## API surface

All methods hang off `Client` and are `async`. Errors are reported through the `PowerMemError` suberror (`HttpError`, `ApiError`, `ParseError`, `RequestError`).

**Memories** (`api_memories.mbt`) — `create_memory`, `batch_create_memories`, `list_memories`, `get_memory`, `update_memory`, `batch_update_memories`, `delete_memory`, `batch_delete_memories`, `get_memory_stats`, `get_memory_quality`, `list_memory_users`, `export_memories`.

**Search** (`api_search.mbt`) — `search` (POST), `search_get` (GET).

**Users** (`api_users.mbt`) — `extract_user_profile`, `get_user_profile`, `delete_user_profile`, `get_user_memories`, `update_user_memory`, `delete_user_memories`, `list_user_profiles`.

**Agents** (`api_agents.mbt`) — `list_agent_memories`, `create_agent_memory`, `share_agent_memories`, `get_shared_memories`.

**System** (`api_system.mbt`) — `health`, `system_status`, `get_metrics`, `delete_all_memories`.

## Local development

The repo ships a helper for running a PowerMem server locally (Python 3.12, Ollama, SQLite). See `.env.example` and `scripts/dev-server.sh`:

```bash
./scripts/dev-server.sh --bg     # start in background
./scripts/dev-server.sh --stop   # stop
moon test --target native        # runs unit + integration tests
```

Integration tests live in `integration_test.mbt` and require the server at `http://127.0.0.1:8000`.
