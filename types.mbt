///|
/// Input for creating a memory in batch operations.
pub(all) struct MemoryInput {
  content : String
  user_id : String?
  agent_id : String?
  run_id : String?
  metadata : Json?
  infer : Bool?
}

///|
pub impl ToJson for MemoryInput with to_json(self) {
  let m : Map[String, Json] = {}
  m["content"] = self.content.to_json()
  json_set_opt(m, "user_id", self.user_id)
  json_set_opt(m, "agent_id", self.agent_id)
  json_set_opt(m, "run_id", self.run_id)
  json_set_opt(m, "metadata", self.metadata)
  json_set_opt(m, "infer", self.infer)
  Json::object(m)
}

///|
pub impl @json.FromJson for MemoryInput with from_json(json, path) {
  let obj = json_as_object(json, path, "MemoryInput")
  {
    content: json_require_string(obj, "content", path),
    user_id: json_opt_string(obj, "user_id"),
    agent_id: json_opt_string(obj, "agent_id"),
    run_id: json_opt_string(obj, "run_id"),
    metadata: json_opt_json(obj, "metadata"),
    infer: json_opt_bool(obj, "infer"),
  }
}

///|
/// Input for updating a memory in batch operations.
pub(all) struct MemoryUpdateInput {
  memory_id : String
  content : String?
  metadata : Json?
}

///|
pub impl ToJson for MemoryUpdateInput with to_json(self) {
  let m : Map[String, Json] = {}
  m["memory_id"] = self.memory_id.to_json()
  json_set_opt(m, "content", self.content)
  json_set_opt(m, "metadata", self.metadata)
  Json::object(m)
}

///|
pub impl @json.FromJson for MemoryUpdateInput with from_json(json, path) {
  let obj = json_as_object(json, path, "MemoryUpdateInput")
  {
    memory_id: json_require_string(obj, "memory_id", path),
    content: json_opt_string(obj, "content"),
    metadata: json_opt_json(obj, "metadata"),
  }
}

///|
/// A chat message for user profile extraction.
pub(all) struct Message {
  role : String
  content : String
} derive(Debug)

///|
pub impl ToJson for Message with to_json(self) {
  Json::object({
    "role": self.role.to_json(),
    "content": self.content.to_json(),
  })
}

///|
pub impl @json.FromJson for Message with from_json(json, path) {
  let obj = json_as_object(json, path, "Message")
  {
    role: json_require_string(obj, "role", path),
    content: json_require_string(obj, "content", path),
  }
}
