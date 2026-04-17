///|
/// Create memories from content. The LLM extracts individual facts, so
/// a single input may produce multiple memories.
pub async fn Client::create_memory(
  self : Client,
  content~ : String,
  user_id? : String,
  agent_id? : String,
  run_id? : String,
  metadata? : Json,
  infer? : Bool,
) -> Array[MemoryData] raise PowerMemError {
  let body = json_obj([
    ("content", Some(content.to_json())),
    ("user_id", user_id.map(fn(s) { s.to_json() })),
    ("agent_id", agent_id.map(fn(s) { s.to_json() })),
    ("run_id", run_id.map(fn(s) { s.to_json() })),
    ("metadata", metadata),
    ("infer", infer.map(fn(b) { b.to_json() })),
  ])
  let json = self.do_json_request(Post, "/memories", [], Some(body))
  parse_response(json)
}

///|
/// Batch create memories (max 100).
pub async fn Client::batch_create_memories(
  self : Client,
  memories~ : Array[MemoryInput],
  user_id? : String,
  agent_id? : String,
  run_id? : String,
) -> Json raise PowerMemError {
  let body = json_obj([
    ("memories", Some(memories.to_json())),
    ("user_id", user_id.map(fn(s) { s.to_json() })),
    ("agent_id", agent_id.map(fn(s) { s.to_json() })),
    ("run_id", run_id.map(fn(s) { s.to_json() })),
  ])
  self.do_json_request(Post, "/memories/batch", [], Some(body))
}

///|
/// List memories with pagination and optional filters.
pub async fn Client::list_memories(
  self : Client,
  limit? : Int,
  offset? : Int,
  sort_by? : String,
  user_id? : String,
  agent_id? : String,
  run_id? : String,
) -> MemoryList raise PowerMemError {
  let params : Array[(String, String)] = []
  add_int_param(params, "limit", limit)
  add_int_param(params, "offset", offset)
  add_param(params, "sort_by", sort_by)
  add_param(params, "user_id", user_id)
  add_param(params, "agent_id", agent_id)
  add_param(params, "run_id", run_id)
  let json = self.do_json_request(Get, "/memories", params, None)
  parse_response(json)
}

///|
/// Get a single memory by ID.
pub async fn Client::get_memory(
  self : Client,
  memory_id~ : String,
) -> MemoryData raise PowerMemError {
  let json = self.do_json_request(Get, "/memories/\{memory_id}", [], None)
  parse_response(json)
}

///|
/// Update a single memory by ID.
pub async fn Client::update_memory(
  self : Client,
  memory_id~ : String,
  content? : String,
  metadata? : Json,
) -> MemoryData raise PowerMemError {
  let body = json_obj([
    ("content", content.map(fn(s) { s.to_json() })),
    ("metadata", metadata),
  ])
  let json = self.do_json_request(Put, "/memories/\{memory_id}", [], Some(body))
  parse_response(json)
}

///|
/// Batch update memories (max 100).
pub async fn Client::batch_update_memories(
  self : Client,
  updates~ : Array[MemoryUpdateInput],
) -> Json raise PowerMemError {
  let body = json_obj([("updates", Some(updates.to_json()))])
  self.do_json_request(Put, "/memories/batch", [], Some(body))
}

///|
/// Delete a single memory by ID.
pub async fn Client::delete_memory(
  self : Client,
  memory_id~ : String,
) -> DeletedMemory raise PowerMemError {
  let json = self.do_json_request(Delete, "/memories/\{memory_id}", [], None)
  parse_response(json)
}

///|
/// Batch delete memories by IDs, user_id, or agent_id.
pub async fn Client::batch_delete_memories(
  self : Client,
  memory_ids? : Array[String],
  user_id? : String,
  agent_id? : String,
) -> DeleteResult raise PowerMemError {
  let body = json_obj([
    ("memory_ids", memory_ids.map(fn(ids) { ids.to_json() })),
    ("user_id", user_id.map(fn(s) { s.to_json() })),
    ("agent_id", agent_id.map(fn(s) { s.to_json() })),
  ])
  let json = self.do_json_request(Delete, "/memories/batch", [], Some(body))
  parse_response(json)
}

///|
/// Get memory statistics.
pub async fn Client::get_memory_stats(
  self : Client,
  time_range? : String,
) -> Json raise PowerMemError {
  let params : Array[(String, String)] = []
  add_param(params, "time_range", time_range)
  self.do_json_request(Get, "/memories/stats", params, None)
}

///|
/// Get memory quality metrics.
pub async fn Client::get_memory_quality(
  self : Client,
) -> QualityMetrics raise PowerMemError {
  let json = self.do_json_request(Get, "/memories/quality", [], None)
  parse_response(json)
}

///|
/// List unique user IDs that have memories.
pub async fn Client::list_memory_users(
  self : Client,
) -> Array[String] raise PowerMemError {
  let json = self.do_json_request(Get, "/memories/users", [], None)
  match json {
    Array(items) => {
      let result : Array[String] = []
      for item in items {
        match item {
          String(s) => result.push(s)
          _ => raise ParseError("expected string in users array, got \{item}")
        }
      }
      result
    }
    _ => raise ParseError("expected array for users response, got \{json}")
  }
}

///|
/// Export memories as raw text (JSON or CSV format).
pub async fn Client::export_memories(
  self : Client,
  format? : String,
  limit? : Int,
) -> String raise PowerMemError {
  let params : Array[(String, String)] = []
  add_param(params, "format", format)
  add_int_param(params, "limit", limit)
  self.do_text_request(Get, "/memories/export", params)
}
