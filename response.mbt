///|
pub(all) struct MemoryData {
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
pub impl ToJson for MemoryData with to_json(self) {
  let m : Map[String, Json] = {}
  m["id"] = self.id.to_json()
  m["content"] = self.content.to_json()
  json_set_opt(m, "user_id", self.user_id)
  json_set_opt(m, "agent_id", self.agent_id)
  json_set_opt(m, "run_id", self.run_id)
  json_set_opt(m, "metadata", self.metadata)
  json_set_opt(m, "created_at", self.created_at)
  json_set_opt(m, "updated_at", self.updated_at)
  Json::object(m)
}

///|
pub impl @json.FromJson for MemoryData with from_json(json, path) {
  let obj = json_as_object(json, path, "MemoryData")
  {
    id: json_require_string(obj, "id", path),
    content: json_require_string(obj, "content", path),
    user_id: json_opt_string(obj, "user_id"),
    agent_id: json_opt_string(obj, "agent_id"),
    run_id: json_opt_string(obj, "run_id"),
    metadata: json_opt_json(obj, "metadata"),
    created_at: json_opt_string(obj, "created_at"),
    updated_at: json_opt_string(obj, "updated_at"),
  }
}

///|
pub(all) struct MemoryList {
  memories : Array[MemoryData]
  total : Int
  limit : Int
  offset : Int
}

///|
pub impl ToJson for MemoryList with to_json(self) {
  let m : Map[String, Json] = {}
  m["memories"] = self.memories.to_json()
  m["total"] = self.total.to_json()
  m["limit"] = self.limit.to_json()
  m["offset"] = self.offset.to_json()
  Json::object(m)
}

///|
pub impl @json.FromJson for MemoryList with from_json(json, path) {
  let obj = json_as_object(json, path, "MemoryList")
  {
    memories: json_require_array(obj, "memories", path),
    total: json_require_int(obj, "total", path),
    limit: json_require_int(obj, "limit", path),
    offset: json_require_int(obj, "offset", path),
  }
}

///|
pub(all) struct SearchResult {
  memory_id : String
  content : String
  score : Double
  metadata : Json?
}

///|
pub impl ToJson for SearchResult with to_json(self) {
  let m : Map[String, Json] = {}
  m["memory_id"] = self.memory_id.to_json()
  m["content"] = self.content.to_json()
  m["score"] = self.score.to_json()
  json_set_opt(m, "metadata", self.metadata)
  Json::object(m)
}

///|
pub impl @json.FromJson for SearchResult with from_json(json, path) {
  let obj = json_as_object(json, path, "SearchResult")
  {
    memory_id: json_require_string(obj, "memory_id", path),
    content: json_require_string(obj, "content", path),
    score: json_require_double(obj, "score", path),
    metadata: json_opt_json(obj, "metadata"),
  }
}

///|
pub(all) struct SearchResponse {
  results : Array[SearchResult]
  total : Int
  query : String
}

///|
pub impl ToJson for SearchResponse with to_json(self) {
  let m : Map[String, Json] = {}
  m["results"] = self.results.to_json()
  m["total"] = self.total.to_json()
  m["query"] = self.query.to_json()
  Json::object(m)
}

///|
pub impl @json.FromJson for SearchResponse with from_json(json, path) {
  let obj = json_as_object(json, path, "SearchResponse")
  {
    results: json_require_array(obj, "results", path),
    total: json_require_int(obj, "total", path),
    query: json_require_string(obj, "query", path),
  }
}

///|
pub(all) struct UserProfile {
  user_id : String
  profile_content : String?
  topics : Json?
  updated_at : String?
}

///|
pub impl ToJson for UserProfile with to_json(self) {
  let m : Map[String, Json] = {}
  m["user_id"] = self.user_id.to_json()
  json_set_opt(m, "profile_content", self.profile_content)
  json_set_opt(m, "topics", self.topics)
  json_set_opt(m, "updated_at", self.updated_at)
  Json::object(m)
}

///|
pub impl @json.FromJson for UserProfile with from_json(json, path) {
  let obj = json_as_object(json, path, "UserProfile")
  {
    user_id: json_require_string(obj, "user_id", path),
    profile_content: json_opt_string(obj, "profile_content"),
    topics: json_opt_json(obj, "topics"),
    updated_at: json_opt_string(obj, "updated_at"),
  }
}

///|
pub(all) struct HealthStatus {
  status : String
} derive(Debug)

///|
pub impl ToJson for HealthStatus with to_json(self) {
  Json::object({ "status": self.status.to_json() })
}

///|
pub impl @json.FromJson for HealthStatus with from_json(json, path) {
  let obj = json_as_object(json, path, "HealthStatus")
  { status: json_require_string(obj, "status", path) }
}

///|
pub(all) struct SystemStatus {
  version : String
  status : String
  storage_type : String?
  llm_provider : String?
  uptime_seconds : Double?
  dependencies : Json?
  start_time : String?
}

///|
pub impl ToJson for SystemStatus with to_json(self) {
  let m : Map[String, Json] = {}
  m["version"] = self.version.to_json()
  m["status"] = self.status.to_json()
  json_set_opt(m, "storage_type", self.storage_type)
  json_set_opt(m, "llm_provider", self.llm_provider)
  json_set_opt(m, "uptime_seconds", self.uptime_seconds)
  json_set_opt(m, "dependencies", self.dependencies)
  json_set_opt(m, "start_time", self.start_time)
  Json::object(m)
}

///|
pub impl @json.FromJson for SystemStatus with from_json(json, path) {
  let obj = json_as_object(json, path, "SystemStatus")
  {
    version: json_require_string(obj, "version", path),
    status: json_require_string(obj, "status", path),
    storage_type: json_opt_string(obj, "storage_type"),
    llm_provider: json_opt_string(obj, "llm_provider"),
    uptime_seconds: json_opt_double(obj, "uptime_seconds"),
    dependencies: json_opt_json(obj, "dependencies"),
    start_time: json_opt_string(obj, "start_time"),
  }
}

///|
pub(all) struct QualityMetrics {
  low_quality_count : Int
  quality_issues_distribution : Json?
}

///|
pub impl ToJson for QualityMetrics with to_json(self) {
  let m : Map[String, Json] = {}
  m["low_quality_count"] = self.low_quality_count.to_json()
  json_set_opt(
    m,
    "quality_issues_distribution",
    self.quality_issues_distribution,
  )
  Json::object(m)
}

///|
pub impl @json.FromJson for QualityMetrics with from_json(json, path) {
  let obj = json_as_object(json, path, "QualityMetrics")
  {
    low_quality_count: json_require_int(obj, "low_quality_count", path),
    quality_issues_distribution: json_opt_json(
      obj, "quality_issues_distribution",
    ),
  }
}

///|
pub(all) struct DeletedMemory {
  memory_id : String
} derive(Debug)

///|
pub impl ToJson for DeletedMemory with to_json(self) {
  Json::object({ "memory_id": self.memory_id.to_json() })
}

///|
pub impl @json.FromJson for DeletedMemory with from_json(json, path) {
  let obj = json_as_object(json, path, "DeletedMemory")
  { memory_id: json_require_string(obj, "memory_id", path) }
}

///|
pub(all) struct DeleteResult {
  deleted_count : Int
} derive(Debug)

///|
pub impl ToJson for DeleteResult with to_json(self) {
  Json::object({ "deleted_count": self.deleted_count.to_json() })
}

///|
pub impl @json.FromJson for DeleteResult with from_json(json, path) {
  let obj = json_as_object(json, path, "DeleteResult")
  { deleted_count: json_require_int(obj, "deleted_count", path) }
}
