///|
/// Extract user profile from messages.
/// Post messages and extract a user profile. The server returns a result
/// dict whose shape depends on `profile_type` (content vs topics) and on
/// the underlying `memory.add` result — kept as raw Json.
pub async fn Client::extract_user_profile(
  self : Client,
  user_id~ : String,
  messages~ : Array[Message],
  extraction_type? : String,
  language? : String,
  strict_mode? : Bool,
  role_filter? : String,
  custom_topics? : Array[String],
) -> Json raise PowerMemError {
  let body = json_obj([
    ("messages", Some(messages.to_json())),
    ("extraction_type", extraction_type.map(fn(s) { s.to_json() })),
    ("language", language.map(fn(s) { s.to_json() })),
    ("strict_mode", strict_mode.map(fn(b) { b.to_json() })),
    ("role_filter", role_filter.map(fn(s) { s.to_json() })),
    ("custom_topics", custom_topics.map(fn(arr) { arr.to_json() })),
  ])
  self.do_json_request(Post, "/users/\{user_id}/profile", [], Some(body))
}

///|
/// Get user profile.
pub async fn Client::get_user_profile(
  self : Client,
  user_id~ : String,
) -> UserProfile raise PowerMemError {
  let json = self.do_json_request(Get, "/users/\{user_id}/profile", [], None)
  parse_response(json)
}

///|
/// Delete user profile.
pub async fn Client::delete_user_profile(
  self : Client,
  user_id~ : String,
) -> Json raise PowerMemError {
  self.do_json_request(Delete, "/users/\{user_id}/profile", [], None)
}

///|
/// List a user's memories.
pub async fn Client::get_user_memories(
  self : Client,
  user_id~ : String,
  limit? : Int,
  offset? : Int,
) -> MemoryList raise PowerMemError {
  let params : Array[(String, String)] = []
  add_int_param(params, "limit", limit)
  add_int_param(params, "offset", offset)
  let json = self.do_json_request(
    Get,
    "/users/\{user_id}/memories",
    params,
    None,
  )
  parse_response(json)
}

///|
/// Update a specific memory for a user.
pub async fn Client::update_user_memory(
  self : Client,
  user_id~ : String,
  memory_id~ : String,
  content? : String,
  metadata? : Json,
) -> MemoryData raise PowerMemError {
  let body = json_obj([
    ("content", content.map(fn(s) { s.to_json() })),
    ("metadata", metadata),
  ])
  let json = self.do_json_request(
    Put,
    "/users/\{user_id}/memories/\{memory_id}",
    [],
    Some(body),
  )
  parse_response(json)
}

///|
/// Delete all memories for a user.
pub async fn Client::delete_user_memories(
  self : Client,
  user_id~ : String,
) -> UserMemoryDeleteResult raise PowerMemError {
  let json = self.do_json_request(
    Delete,
    "/users/\{user_id}/memories",
    [],
    None,
  )
  parse_response(json)
}

///|
/// List all user profiles.
pub async fn Client::list_user_profiles(
  self : Client,
  limit? : Int,
  offset? : Int,
  fuzzy_match? : String,
) -> Json raise PowerMemError {
  let params : Array[(String, String)] = []
  add_int_param(params, "limit", limit)
  add_int_param(params, "offset", offset)
  add_param(params, "fuzzy_match", fuzzy_match)
  self.do_json_request(Get, "/users/profiles", params, None)
}
