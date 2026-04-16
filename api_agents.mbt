///|
/// List memories for a specific agent.
pub async fn Client::list_agent_memories(
  self : Client,
  agent_id~ : String,
  limit? : Int,
  offset? : Int,
) -> MemoryList raise PowerMemError {
  let params : Array[(String, String)] = []
  add_int_param(params, "limit", limit)
  add_int_param(params, "offset", offset)
  let json = self.do_json_request(
    Get,
    "/agents/\{agent_id}/memories",
    params,
    None,
  )
  parse_response(json)
}

///|
/// Create a new memory for a specific agent.
pub async fn Client::create_agent_memory(
  self : Client,
  agent_id~ : String,
  content~ : String,
  user_id? : String,
  run_id? : String,
) -> MemoryData raise PowerMemError {
  let body = json_obj([
    ("content", Some(content.to_json())),
    ("user_id", user_id.map(fn(s) { s.to_json() })),
    ("run_id", run_id.map(fn(s) { s.to_json() })),
  ])
  let json = self.do_json_request(
    Post,
    "/agents/\{agent_id}/memories",
    [],
    Some(body),
  )
  parse_response(json)
}

///|
/// Share memories from one agent to another.
pub async fn Client::share_agent_memories(
  self : Client,
  agent_id~ : String,
  target_agent_id~ : String,
  memory_ids~ : Array[String],
) -> Json raise PowerMemError {
  let body = json_obj([
    ("target_agent_id", Some(target_agent_id.to_json())),
    ("memory_ids", Some(memory_ids.to_json())),
  ])
  self.do_json_request(
    Post,
    "/agents/\{agent_id}/memories/share",
    [],
    Some(body),
  )
}

///|
/// Get shared memories for a specific agent.
pub async fn Client::get_shared_memories(
  self : Client,
  agent_id~ : String,
  limit? : Int,
  offset? : Int,
) -> MemoryList raise PowerMemError {
  let params : Array[(String, String)] = []
  add_int_param(params, "limit", limit)
  add_int_param(params, "offset", offset)
  let json = self.do_json_request(
    Get,
    "/agents/\{agent_id}/memories/share",
    params,
    None,
  )
  parse_response(json)
}
