///|
/// Integration tests — require a running PowerMem server.
///
///   ./scripts/dev-server.sh --bg   # start server first
///   moon test --target native --filter "integration/*"
///   ./scripts/dev-server.sh --stop

///|
async test "integration/health" {
  let client = @powermem.Client::new(base_url="http://127.0.0.1:8000")
  let status = client.health()
  inspect(status.status, content="healthy")
}

///|
async test "integration/create" {
  let client = @powermem.Client::new(base_url="http://127.0.0.1:8000")
  let ts = @async.now()
  let user = "mbt_create_\{ts}"
  let created = client.create_memory(
    content="The user prefers dark mode",
    user_id=user,
  )
  guard created.length() > 0 else { fail("expected at least one memory") }
  ignore(client.delete_user_memories(user_id=user))
}

///|
async test "integration/search" {
  let client = @powermem.Client::new(base_url="http://127.0.0.1:8000")
  let ts = @async.now()
  let user = "mbt_search_\{ts}"
  let created = client.create_memory(
    content="The user likes MoonBit language",
    user_id=user,
  )
  guard created.length() > 0 else { fail("no memories created") }
  @async.sleep(500)
  let results = client.search(query="MoonBit", user_id=user)
  guard results.results.length() > 0 else { fail("expected search results") }
  ignore(client.delete_user_memories(user_id=user))
}

///|
async test "integration/get_and_delete" {
  let client = @powermem.Client::new(base_url="http://127.0.0.1:8000")
  let ts = @async.now()
  let user = "mbt_getdel_\{ts}"
  let created = client.create_memory(content="The user uses vim", user_id=user)
  guard created.length() > 0 else { fail("no memories created") }
  let get_result = try? client.get_memory(memory_id=created[0].id)
  guard get_result is Ok(_) else {
    match get_result {
      Err(e) => fail("get_memory failed: " + @debug.to_string(e))
      _ => fail("unreachable")
    }
  }
  let del_result = try? client.delete_memory(memory_id=created[0].id)
  guard del_result is Ok(_) else {
    match del_result {
      Err(e) => fail("delete_memory failed: " + @debug.to_string(e))
      _ => fail("unreachable")
    }
  }
  ignore(client.delete_user_memories(user_id=user))
}

///|
async test "integration/list" {
  let client = @powermem.Client::new(base_url="http://127.0.0.1:8000")
  let ts = @async.now()
  let user = "mbt_list_\{ts}"
  let created = client.create_memory(
    content="The user drinks coffee",
    user_id=user,
  )
  guard created.length() > 0 else { fail("no memories created") }
  let list_result = try? client.list_memories(user_id=user)
  guard list_result is Ok(_) else {
    match list_result {
      Err(e) => fail("list_memories failed: " + @debug.to_string(e))
      _ => fail("unreachable")
    }
  }
  ignore(client.delete_user_memories(user_id=user))
}

///|
async test "integration/system_status" {
  let client = @powermem.Client::new(base_url="http://127.0.0.1:8000")
  let status = client.system_status()
  guard status.version != "" else { fail("expected non-empty version") }
}
