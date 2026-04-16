///|
/// Semantic search for memories via POST.
pub async fn Client::search(
  self : Client,
  query~ : String,
  user_id? : String,
  agent_id? : String,
  run_id? : String,
  filters? : Json,
  limit? : Int,
) -> SearchResponse raise PowerMemError {
  let body = json_obj([
    ("query", Some(query.to_json())),
    ("user_id", user_id.map(fn(s) { s.to_json() })),
    ("agent_id", agent_id.map(fn(s) { s.to_json() })),
    ("run_id", run_id.map(fn(s) { s.to_json() })),
    ("filters", filters),
    ("limit", limit.map(fn(n) { n.to_json() })),
  ])
  let json = self.do_json_request(Post, "/memories/search", [], Some(body))
  parse_response(json)
}

///|
/// Search memories via GET query parameters.
pub async fn Client::search_get(
  self : Client,
  query~ : String,
  user_id? : String,
  agent_id? : String,
  run_id? : String,
  limit? : Int,
) -> SearchResponse raise PowerMemError {
  let params : Array[(String, String)] = [("query", query)]
  add_param(params, "user_id", user_id)
  add_param(params, "agent_id", agent_id)
  add_param(params, "run_id", run_id)
  add_int_param(params, "limit", limit)
  let json = self.do_json_request(Get, "/memories/search", params, None)
  parse_response(json)
}
