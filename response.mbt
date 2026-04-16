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
} derive(ToJson, FromJson)

///|
pub(all) struct MemoryList {
  memories : Array[MemoryData]
  total : Int
  limit : Int
  offset : Int
} derive(Debug, ToJson, FromJson)

///|
pub(all) struct SearchResult {
  memory_id : String
  content : String
  relevance_score : Double
  metadata : Json?
} derive(ToJson, FromJson)

///|
pub(all) struct SearchResponse {
  results : Array[SearchResult]
  total : Int
  query : String
} derive(Debug, ToJson, FromJson)

///|
pub(all) struct UserProfile {
  user_id : String
  profile_content : String?
  topics : Json?
  updated_at : String?
} derive(ToJson, FromJson)

///|
pub(all) struct HealthStatus {
  status : String
} derive(Debug, ToJson, FromJson)

///|
pub(all) struct SystemStatus {
  version : String
  status : String
  storage_type : String?
  llm_provider : String?
  uptime_seconds : Double?
  dependencies : Json?
  start_time : String?
} derive(ToJson, FromJson)

///|
pub(all) struct QualityMetrics {
  low_quality_count : Int
  quality_issues_distribution : Json?
} derive(ToJson, FromJson)

///|
pub(all) struct DeleteResult {
  deleted_count : Int
} derive(Debug, ToJson, FromJson)
