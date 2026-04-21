# Contributing

## Local development

The SDK targets the MoonBit `native` backend. Integration tests hit a real PowerMem server on `http://127.0.0.1:8000`.

### One-time setup

1. **Python venv with the PowerMem server.** Requires Python 3.12 (3.14 is too new for some dependencies):

   ```bash
   python3.12 -m venv .venv
   .venv/bin/pip install powermem
   ```

2. **Ollama for LLM + embeddings** (the default in `.env.example`). If you don't have Ollama yet:

   ```bash
   ollama serve
   ollama pull mistral
   ollama pull nomic-embed-text
   ```

   To use OpenAI or OpenRouter instead, swap the `LLM_PROVIDER` / `EMBEDDING_PROVIDER` blocks in `.env` — see the commented Option B in `.env.example`.

3. **Environment file.** Copy the template and edit as needed:

   ```bash
   cp .env.example .env
   ```

### Running the server

`scripts/dev-server.sh` wraps the venv's `powermem-server` with the right env:

```bash
./scripts/dev-server.sh          # foreground
./scripts/dev-server.sh --bg     # background (logs to .pmem-server.log)
./scripts/dev-server.sh --stop   # stop a backgrounded server
```

Boot takes ~30s; tail `.pmem-server.log` until you see `Application startup complete.`

### Running tests

```bash
moon test --target native                          # unit + integration
moon test --target native --filter "integration/*" # integration only
```

Integration tests live in `integration_test.mbt`. They require the dev server to be running. Some tests rely on LLM fact extraction, so occasional flakes are possible if the LLM decides an input isn't an extractable fact.

### Known server bugs

Two tests tolerate `500` responses from PowerMem `1.1.0` because the server's response serializer chokes on rows with `memory_id=None`:

- `integration/export_memories`
- `integration/update_user_memory`

The SDK request path is still exercised; the tests will tighten back to strict success once the server is fixed upstream.
