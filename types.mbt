///|
/// Input for creating a memory in batch operations.
pub(all) struct MemoryInput {
  content : String
  user_id : String?
  agent_id : String?
  run_id : String?
  metadata : Json?
  infer : Bool?
} derive(Show, ToJson, FromJson)

///|
/// Input for updating a memory in batch operations.
pub(all) struct MemoryUpdateInput {
  memory_id : String
  content : String?
  metadata : Json?
} derive(Show, ToJson, FromJson)

///|
/// A chat message for user profile extraction.
pub(all) struct Message {
  role : String
  content : String
} derive(Show, ToJson, FromJson)
