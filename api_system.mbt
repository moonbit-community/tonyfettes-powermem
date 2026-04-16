///|
/// Health check endpoint. No authentication needed.
pub async fn Client::health(self : Client) -> HealthStatus raise PowerMemError {
  let json = self.do_json_request(Get, "/system/health", [], None)
  parse_response(json)
}

///|
/// Get system status information.
pub async fn Client::system_status(
  self : Client,
) -> SystemStatus raise PowerMemError {
  let json = self.do_json_request(Get, "/system/status", [], None)
  parse_response(json)
}

///|
/// Get Prometheus metrics in raw text format.
pub async fn Client::get_metrics(self : Client) -> String raise PowerMemError {
  self.do_text_request(Get, "/system/metrics", [])
}

///|
/// Delete all memories, with optional filters by user, agent, or run.
pub async fn Client::delete_all_memories(
  self : Client,
  user_id? : String,
  agent_id? : String,
  run_id? : String,
) -> DeleteResult raise PowerMemError {
  let params : Array[(String, String)] = []
  add_param(params, "user_id", user_id)
  add_param(params, "agent_id", agent_id)
  add_param(params, "run_id", run_id)
  let json = self.do_json_request(
    Delete,
    "/system/delete-all-memories",
    params,
    None,
  )
  parse_response(json)
}
