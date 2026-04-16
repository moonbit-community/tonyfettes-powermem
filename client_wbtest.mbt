///|
test "build_query_string empty" {
  inspect(build_query_string([]), content="")
}

///|
test "build_query_string with params" {
  let params = [("limit", "10"), ("offset", "0"), ("user_id", "u1")]
  inspect(build_query_string(params), content="?limit=10&offset=0&user_id=u1")
}

///|
test "json_obj skips None entries" {
  let obj = json_obj([
    ("content", Some("hello".to_json())),
    ("user_id", None),
    ("count", Some((42).to_json())),
  ])
  inspect(obj.stringify(), content="{\"content\":\"hello\",\"count\":42}")
}

///|
test "add_param with Some and None" {
  let params : Array[(String, String)] = []
  add_param(params, "a", Some("val"))
  add_param(params, "b", None)
  add_int_param(params, "c", Some(5))
  add_int_param(params, "d", None)
  inspect(params.length(), content="2")
  inspect(params[0], content="(\"a\", \"val\")")
  inspect(params[1], content="(\"c\", \"5\")")
}

///|
test "extract_response_data with data envelope" {
  let body =
    #|{"success": true, "data": {"id": "123"}, "message": "ok"}
  let json = @json.parse(body)
  let data = extract_response_data(json)
  inspect(data.stringify(), content="{\"id\":\"123\"}")
}

///|
test "extract_response_data without envelope" {
  let body =
    #|{"id": "456", "content": "hello"}
  let json = @json.parse(body)
  let data = extract_response_data(json)
  inspect(data.stringify(), content="{\"id\":\"456\",\"content\":\"hello\"}")
}

///|
test "extract_response_data api error" {
  let body =
    #|{"success": false, "message": "Not found"}
  let json = @json.parse(body)
  let result = try? extract_response_data(json)
  guard result is Err(_) else { fail("expected error") }
}

///|
test "parse MemoryData from json" {
  let body =
    #|{"id": "100", "content": "test memory", "user_id": "u1", "created_at": "2024-01-01"}
  let json = @json.parse(body)
  let mem : MemoryData = parse_response(json)
  inspect(mem.id, content="100")
  inspect(mem.content, content="test memory")
  inspect(mem.user_id, content="Some(\"u1\")")
  inspect(mem.agent_id, content="None")
}

///|
test "parse MemoryList from json" {
  let body =
    #|{"memories": [{"id": "1", "content": "a"}, {"id": "2", "content": "b"}], "total": 2, "limit": 10, "offset": 0}
  let json = @json.parse(body)
  let list : MemoryList = parse_response(json)
  inspect(list.total, content="2")
  inspect(list.memories.length(), content="2")
  inspect(list.memories[0].id, content="1")
}

///|
test "build_default_headers without api_key" {
  let h = build_default_headers(None)
  inspect(h.get("Content-Type"), content="Some(\"application/json\")")
  inspect(h.get("X-API-Key"), content="None")
}

///|
test "build_default_headers with api_key" {
  let h = build_default_headers(Some("test-key"))
  inspect(h.get("Content-Type"), content="Some(\"application/json\")")
  inspect(h.get("X-API-Key"), content="Some(\"test-key\")")
}

///|
test "Client construction" {
  let client = Client::new(base_url="http://example.com:9000", api_key="key123")
  inspect(client.base_url, content="http://example.com:9000")
  inspect(client.api_key, content="Some(\"key123\")")
  let default_client = Client::new()
  inspect(default_client.base_url, content="http://localhost:8000")
  inspect(default_client.api_key, content="None")
}
