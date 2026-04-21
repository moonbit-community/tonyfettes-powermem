///|
/// Runnable demo of the PowerMem HTTP API from MoonBit.
///
/// Usage:
///   moon run --target native examples/moonbit
///
/// Environment variables:
///   POWERMEM_BASE_URL  Base URL of the server (default: http://localhost:8000)
///   POWERMEM_API_KEY   API key (optional, required only if server auth is on)

///|
async fn main {
  let banner = "=".repeat(60)
  println(banner)
  println("PowerMem MoonBit Client Example")
  println(banner)
  let client = init_client()
  run_examples(client)
  println("")
  println(banner)
  println("All examples completed.")
  println(banner)
}

///|
fn init_client() -> Client {
  let base_url = match @env.get_env_var("POWERMEM_BASE_URL") {
    Some(v) => v
    None => "http://localhost:8000"
  }
  let api_key = @env.get_env_var("POWERMEM_API_KEY")
  println("")
  println("Configuration:")
  println("  Base URL: \{base_url}")
  match api_key {
    Some(_) => println("  API Key:  (set)")
    None => println("  API Key:  (not set)")
  }
  match api_key {
    Some(key) => Client::new(base_url, api_key=key)
    None => Client::new(base_url)
  }
}

///|
async fn run_examples(client : Client) -> Unit {
  let user_id = "moonbit-example-user"
  let agent_id = "moonbit-example-agent"

  example_health(client)
  let created = example_create(client, user_id~, agent_id~)
  example_list(client, user_id~)
  example_search(client, user_id~, agent_id~)
  match created {
    Some(memories) if memories.length() > 0 => {
      let first = memories[0]
      example_update(client, memory_id=first.id)
      example_delete(client, memory_id=first.id)
    }
    _ => {
      section("5. Update Memory")
      println("  skipped (no memories created)")
      section("6. Delete Memory")
      println("  skipped (no memories created)")
    }
  }
}

///|
fn section(title : String) -> Unit {
  println("")
  println("-".repeat(40))
  println(title)
  println("-".repeat(40))
}

///|
async fn example_health(client : Client) -> Unit {
  section("1. Health Check")
  let result = try? client.health()
  match result {
    Ok(h) => println("  status: \{h.status}")
    Err(e) => println("  failed: " + @debug.to_string(e))
  }
}

///|
async fn example_create(
  client : Client,
  user_id~ : String,
  agent_id~ : String,
) -> Array[Memory]? {
  section("2. Create Memory")
  let result = try? client.create_memory(
    content="User likes coffee and goes to Starbucks every morning. They prefer latte.",
    user_id~,
    agent_id~,
    infer=true,
  )
  match result {
    Ok(memories) => {
      println("  created \{memories.length()} memory(ies):")
      for i, m in memories {
        println("    [\{i + 1}] \{m.id}: \{m.content}")
      }
      Some(memories)
    }
    Err(e) => {
      println("  skipped: " + @debug.to_string(e))
      if needs_embedding_hint(e) {
        println("  (requires an embedding provider configured in the server .env)")
      }
      None
    }
  }
}

///|
/// Connection-refused and other transport failures have nothing to do with
/// the embedding provider — only print that hint for server-side errors.
fn needs_embedding_hint(err : ApiError) -> Bool {
  match err {
    Request(_) => false
    _ => true
  }
}

///|
async fn example_list(client : Client, user_id~ : String) -> Unit {
  section("3. List Memories")
  let result = try? client.list_memories(user_id~, limit=10)
  match result {
    Ok(list) => {
      println("  total: \{list.total}, showing \{list.memories.length()}:")
      for i, m in list.memories {
        println("    [\{i + 1}] \{m.id}: \{truncate(m.content, 60)}")
      }
    }
    Err(e) => println("  skipped: " + @debug.to_string(e))
  }
}

///|
async fn example_search(
  client : Client,
  user_id~ : String,
  agent_id~ : String,
) -> Unit {
  section("4. Search Memories")
  let result = try? client.search_memories(
    query="What beverages does the user like?",
    user_id~,
    agent_id~,
    limit=5,
  )
  match result {
    Ok(resp) => {
      println("  query: \{resp.query}")
      println("  results: \{resp.results.length()}")
      for i, r in resp.results {
        let score = match r.score {
          Some(s) => s.to_string()
          None => "-"
        }
        println("    [\{i + 1}] score=\{score}: \{truncate(r.content, 60)}")
      }
    }
    Err(e) => {
      println("  skipped: " + @debug.to_string(e))
      if needs_embedding_hint(e) {
        println("  (requires an embedding provider configured in the server .env)")
      }
    }
  }
}

///|
async fn example_update(client : Client, memory_id~ : String) -> Unit {
  section("5. Update Memory")
  let result = try? client.update_memory(
    memory_id~,
    content="User loves espresso and visits Starbucks daily",
  )
  match result {
    Ok(m) => println("  updated \{m.id}: \{m.content}")
    Err(e) => println("  skipped: " + @debug.to_string(e))
  }
}

///|
async fn example_delete(client : Client, memory_id~ : String) -> Unit {
  section("6. Delete Memory")
  let result = try? client.delete_memory(memory_id~)
  match result {
    Ok(d) => println("  deleted \{d.memory_id}")
    Err(e) => println("  skipped: " + @debug.to_string(e))
  }
}

///|
fn truncate(s : String, n : Int) -> String {
  if s.length() <= n {
    s
  } else {
    s[:n - 3].to_string() + "..."
  }
}
