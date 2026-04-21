///|
/// Request/response types for the PowerMem HTTP API. Each one has manual
/// `ToJson` / `FromJson` impls so the example runs on the MoonBit core +
/// async packages only — no third-party dependencies.

///|
pub(all) struct Memory {
  id : String
  content : String
  user_id : String?
  agent_id : String?
  run_id : String?
  metadata : Json?
  created_at : String?
  updated_at : String?
}

///|
pub impl @json.FromJson for Memory with from_json(json, path) {
  let obj = expect_object(json, path, "Memory")
  {
    id: require_string(obj, "id", path),
    content: require_string(obj, "content", path),
    user_id: opt_string(obj, "user_id"),
    agent_id: opt_string(obj, "agent_id"),
    run_id: opt_string(obj, "run_id"),
    metadata: opt_json(obj, "metadata"),
    created_at: opt_string(obj, "created_at"),
    updated_at: opt_string(obj, "updated_at"),
  }
}

///|
pub(all) struct MemoryList {
  memories : Array[Memory]
  total : Int
  limit : Int
  offset : Int
}

///|
pub impl @json.FromJson for MemoryList with from_json(json, path) {
  let obj = expect_object(json, path, "MemoryList")
  {
    memories: require_array(obj, "memories", path),
    total: require_int(obj, "total", path),
    limit: require_int(obj, "limit", path),
    offset: require_int(obj, "offset", path),
  }
}

///|
pub(all) struct SearchResult {
  memory_id : String
  content : String
  score : Double?
  metadata : Json?
}

///|
pub impl @json.FromJson for SearchResult with from_json(json, path) {
  let obj = expect_object(json, path, "SearchResult")
  {
    memory_id: require_string(obj, "memory_id", path),
    content: require_string(obj, "content", path),
    score: opt_double(obj, "score"),
    metadata: opt_json(obj, "metadata"),
  }
}

///|
pub(all) struct SearchResponse {
  results : Array[SearchResult]
  total : Int
  query : String
}

///|
pub impl @json.FromJson for SearchResponse with from_json(json, path) {
  let obj = expect_object(json, path, "SearchResponse")
  {
    results: require_array(obj, "results", path),
    total: require_int(obj, "total", path),
    query: require_string(obj, "query", path),
  }
}

///|
pub(all) struct HealthStatus {
  status : String
}

///|
pub impl @json.FromJson for HealthStatus with from_json(json, path) {
  let obj = expect_object(json, path, "HealthStatus")
  { status: require_string(obj, "status", path) }
}

///|
pub(all) struct SystemStatus {
  version : String
  status : String
  storage_type : String?
  llm_provider : String?
}

///|
pub impl @json.FromJson for SystemStatus with from_json(json, path) {
  let obj = expect_object(json, path, "SystemStatus")
  {
    version: require_string(obj, "version", path),
    status: require_string(obj, "status", path),
    storage_type: opt_string(obj, "storage_type"),
    llm_provider: opt_string(obj, "llm_provider"),
  }
}

///|
pub(all) struct DeletedMemory {
  memory_id : String
}

///|
pub impl @json.FromJson for DeletedMemory with from_json(json, path) {
  let obj = expect_object(json, path, "DeletedMemory")
  { memory_id: require_string(obj, "memory_id", path) }
}

// -----------------------------------------------------------------------------
// Small JSON helpers used by the manual FromJson impls above.
// -----------------------------------------------------------------------------

///|
fn expect_object(
  json : Json,
  path : @json.JsonPath,
  type_name : String,
) -> Map[String, Json] raise @json.JsonDecodeError {
  match json {
    Object(obj) => obj
    _ =>
      raise @json.JsonDecodeError((path, type_name + ": expected JSON object"))
  }
}

///|
fn require_string(
  obj : Map[String, Json],
  key : String,
  path : @json.JsonPath,
) -> String raise @json.JsonDecodeError {
  match obj.get(key) {
    Some(String(s)) => s
    _ => raise @json.JsonDecodeError((path.add_key(key), "expected string"))
  }
}

///|
fn require_int(
  obj : Map[String, Json],
  key : String,
  path : @json.JsonPath,
) -> Int raise @json.JsonDecodeError {
  match obj.get(key) {
    Some(Number(n, ..)) => n.to_int()
    _ => raise @json.JsonDecodeError((path.add_key(key), "expected number"))
  }
}

///|
fn[T : @json.FromJson] require_array(
  obj : Map[String, Json],
  key : String,
  path : @json.JsonPath,
) -> Array[T] raise @json.JsonDecodeError {
  match obj.get(key) {
    Some(Array(items)) => {
      let result : Array[T] = []
      for i, item in items {
        result.push(@json.from_json(item, path=path.add_key(key).add_index(i)))
      }
      result
    }
    _ => raise @json.JsonDecodeError((path.add_key(key), "expected array"))
  }
}

///|
fn opt_string(obj : Map[String, Json], key : String) -> String? {
  match obj.get(key) {
    Some(String(s)) => Some(s)
    _ => None
  }
}

///|
fn opt_double(obj : Map[String, Json], key : String) -> Double? {
  match obj.get(key) {
    Some(Number(n, ..)) => Some(n)
    _ => None
  }
}

///|
fn opt_json(obj : Map[String, Json], key : String) -> Json? {
  match obj.get(key) {
    Some(Null) | None => None
    Some(v) => Some(v)
  }
}
