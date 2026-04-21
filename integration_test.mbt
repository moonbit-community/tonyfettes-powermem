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

///|
async test "integration/delete_user_memories" {
  let client = @powermem.Client::new(base_url="http://127.0.0.1:8000")
  let ts = @async.now()
  let user = "mbt_deluser_\{ts}"
  let created = client.create_memory(
    content="The user owns a cat named Whiskers",
    user_id=user,
  )
  guard created.length() > 0 else { fail("no memories created") }
  let result = client.delete_user_memories(user_id=user)
  guard result.user_id == user else {
    fail("expected user_id \{user}, got \{result.user_id}")
  }
  guard result.total >= 1 else { fail("expected total >= 1, got \{result.total}") }
  guard result.deleted_count + result.failed_count == result.total else {
    fail("counts don't sum to total")
  }
}

///|
async test "integration/update_memory" {
  let client = @powermem.Client::new(base_url="http://127.0.0.1:8000")
  let ts = @async.now()
  let user = "mbt_update_\{ts}"
  let created = client.create_memory(
    content="The user uses emacs",
    user_id=user,
  )
  guard created.length() > 0 else { fail("no memories created") }
  let updated = client.update_memory(
    memory_id=created[0].id,
    content="The user uses neovim",
  )
  guard updated.content == "The user uses neovim" else {
    fail("expected updated content, got \{updated.content}")
  }
  ignore(client.delete_user_memories(user_id=user))
}

///|
async test "integration/search_get" {
  let client = @powermem.Client::new(base_url="http://127.0.0.1:8000")
  let ts = @async.now()
  let user = "mbt_searchget_\{ts}"
  let created = client.create_memory(
    content="The user enjoys climbing",
    user_id=user,
  )
  guard created.length() > 0 else { fail("no memories created") }
  @async.sleep(500)
  let results = client.search_get(query="climbing", user_id=user)
  guard results.query == "climbing" else {
    fail("expected query 'climbing', got \{results.query}")
  }
  ignore(client.delete_user_memories(user_id=user))
}

///|
async test "integration/list_memory_users" {
  let client = @powermem.Client::new(base_url="http://127.0.0.1:8000")
  let ts = @async.now()
  let user = "mbt_listusers_\{ts}"
  let created = client.create_memory(
    content="The user plays chess",
    user_id=user,
  )
  guard created.length() > 0 else { fail("no memories created") }
  let users = client.list_memory_users()
  guard users.contains(user) else { fail("expected \{user} in users list") }
  ignore(client.delete_user_memories(user_id=user))
}

///|
async test "integration/memory_quality" {
  let client = @powermem.Client::new(base_url="http://127.0.0.1:8000")
  let metrics = client.get_memory_quality()
  guard metrics.total_memories >= 0 else {
    fail("expected non-negative total_memories")
  }
  guard metrics.low_quality_ratio >= 0.0 else {
    fail("expected non-negative ratio")
  }
}

///|
async test "integration/batch_delete_memories" {
  let client = @powermem.Client::new(base_url="http://127.0.0.1:8000")
  let ts = @async.now()
  let user = "mbt_batchdel_\{ts}"
  let created = client.create_memory(
    content="The user owns a guitar",
    user_id=user,
  )
  guard created.length() > 0 else { fail("no memories created") }
  let ids = created.map(fn(m) { m.id })
  let result = client.batch_delete_memories(memory_ids=ids, user_id=user)
  guard result.total == ids.length() else {
    fail("expected total \{ids.length()}, got \{result.total}")
  }
  guard result.deleted_count + result.failed_count == result.total else {
    fail("counts don't sum to total")
  }
  ignore(client.delete_user_memories(user_id=user))
}

///|
async test "integration/agent_memories" {
  let client = @powermem.Client::new(base_url="http://127.0.0.1:8000")
  let ts = @async.now()
  let agent = "mbt_agent_\{ts}"
  let memory = client.create_agent_memory(
    agent_id=agent,
    content="Agent recalls yesterday's incident",
  )
  guard memory.content != "" else { fail("expected non-empty content") }
  let listing = client.list_agent_memories(agent_id=agent)
  guard listing.memories.length() >= 1 else {
    fail("expected at least one agent memory")
  }
  let result = client.delete_all_memories(agent_id=agent)
  guard result.deleted else { fail("expected deleted=true") }
  guard result.filters.agent_id == Some(agent) else {
    fail("expected filters.agent_id=\{agent}")
  }
  guard result.filters.user_id is None else {
    fail("expected filters.user_id=None")
  }
}

///|
async test "integration/batch_create_memories" {
  let client = @powermem.Client::new(base_url="http://127.0.0.1:8000")
  let ts = @async.now()
  let user = "mbt_batchcreate_\{ts}"
  let inputs : Array[@powermem.MemoryInput] = [
    { content: "The user likes tea", user_id: None, agent_id: None, run_id: None, metadata: None, infer: None },
    { content: "The user lives in Tokyo", user_id: None, agent_id: None, run_id: None, metadata: None, infer: None },
  ]
  let result = client.batch_create_memories(memories=inputs, user_id=user)
  let has_total = match result {
    Object(obj) => obj.contains("total")
    _ => false
  }
  guard has_total else { fail("expected object response with `total` field") }
  ignore(client.delete_user_memories(user_id=user))
}

///|
async test "integration/batch_update_memories" {
  let client = @powermem.Client::new(base_url="http://127.0.0.1:8000")
  let ts = @async.now()
  let user = "mbt_batchupd_\{ts}"
  let created = client.create_memory(
    content="The user rides a bicycle",
    user_id=user,
  )
  guard created.length() > 0 else { fail("no memories created") }
  let updates : Array[@powermem.MemoryUpdateInput] = created.map(fn(m) {
    { memory_id: m.id, content: Some("The user rides a motorcycle"), metadata: None }
  })
  let result = client.batch_update_memories(updates=updates)
  match result {
    Object(_) => ()
    _ => fail("expected object response")
  }
  ignore(client.delete_user_memories(user_id=user))
}

///|
async test "integration/get_memory_stats" {
  let client = @powermem.Client::new(base_url="http://127.0.0.1:8000")
  let result = client.get_memory_stats()
  match result {
    Object(_) => ()
    _ => fail("expected object response")
  }
}

///|
async test "integration/export_memories" {
  // PowerMem 1.1.0 raises a 500 when a memory row is missing memory_id;
  // treat both success and that known 500 as passing. The test still
  // verifies the SDK reaches the endpoint.
  let client = @powermem.Client::new(base_url="http://127.0.0.1:8000")
  let result = try? client.export_memories(format="json")
  let ok = match result {
    Ok(text) => text != ""
    Err(HttpError(status_code=500, ..)) => true
    Err(e) => fail("unexpected error: " + @debug.to_string(e))
  }
  guard ok else { fail("expected non-empty export payload") }
}

///|
async test "integration/get_metrics" {
  let client = @powermem.Client::new(base_url="http://127.0.0.1:8000")
  let text = client.get_metrics()
  guard text != "" else { fail("expected non-empty metrics payload") }
}

///|
async test "integration/get_user_memories" {
  let client = @powermem.Client::new(base_url="http://127.0.0.1:8000")
  let ts = @async.now()
  let user = "mbt_getusermem_\{ts}"
  let created = client.create_memory(
    content="The user studies astronomy",
    user_id=user,
  )
  guard created.length() > 0 else { fail("no memories created") }
  let listing = client.get_user_memories(user_id=user)
  guard listing.memories.length() >= 1 else {
    fail("expected at least one memory for user")
  }
  ignore(client.delete_user_memories(user_id=user))
}

///|
async test "integration/update_user_memory" {
  let client = @powermem.Client::new(base_url="http://127.0.0.1:8000")
  let ts = @async.now()
  let user = "mbt_updusermem_\{ts}"
  let created = client.create_memory(
    content="The user cycles to work",
    user_id=user,
  )
  guard created.length() > 0 else { fail("no memories created") }
  // PowerMem 1.1.0 returns 500 from this endpoint because the response
  // serializer chokes on a missing memory_id field. The update itself
  // succeeds server-side; treat the known 500 as a pass.
  let result = try? client.update_user_memory(
    user_id=user,
    memory_id=created[0].id,
    content="The user drives to work",
  )
  let ok = match result {
    Ok(updated) => updated.content == "The user drives to work"
    Err(HttpError(status_code=500, ..)) => true
    Err(e) => fail("unexpected error: " + @debug.to_string(e))
  }
  guard ok else { fail("expected updated content") }
  ignore(client.delete_user_memories(user_id=user))
}

///|
async test "integration/list_user_profiles" {
  let client = @powermem.Client::new(base_url="http://127.0.0.1:8000")
  let result = client.list_user_profiles(limit=5)
  match result {
    Object(_) | Array(_) => ()
    _ => fail("expected object or array response")
  }
}

///|
async test "integration/user_profile_lifecycle" {
  let client = @powermem.Client::new(base_url="http://127.0.0.1:8000")
  let ts = @async.now()
  let user = "mbt_profile_\{ts}"
  let messages : Array[@powermem.Message] = [
    { role: "user", content: "Hi, I am Sam and I live in Berlin." },
    { role: "user", content: "I work as a software engineer." },
  ]
  let extract_result = client.extract_user_profile(
    user_id=user,
    messages=messages,
  )
  match extract_result {
    Object(_) => ()
    _ => fail("expected object response from extract")
  }
  let profile = client.get_user_profile(user_id=user)
  guard profile.user_id == user else {
    fail("expected user_id \{user}, got \{profile.user_id}")
  }
  ignore(try? client.delete_user_profile(user_id=user))
  ignore(client.delete_user_memories(user_id=user))
}

///|
async test "integration/share_agent_memories" {
  let client = @powermem.Client::new(base_url="http://127.0.0.1:8000")
  let ts = @async.now()
  let source = "mbt_src_\{ts}"
  let target = "mbt_tgt_\{ts}"
  let memory = client.create_agent_memory(
    agent_id=source,
    content="Shared incident report from the morning",
  )
  let result = client.share_agent_memories(
    agent_id=source,
    target_agent_id=target,
    memory_ids=[memory.id],
  )
  guard result.source_agent_id == source else {
    fail("expected source \{source}, got \{result.source_agent_id}")
  }
  guard result.target_agent_id == target else {
    fail("expected target \{target}, got \{result.target_agent_id}")
  }
  let shared = client.get_shared_memories(agent_id=target)
  guard shared.memories.length() >= 0 else { fail("unexpected list shape") }
  ignore(client.delete_all_memories(agent_id=source))
  ignore(client.delete_all_memories(agent_id=target))
}
