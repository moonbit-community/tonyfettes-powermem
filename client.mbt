///|
pub struct Client {
  base_url : String
  api_key : String?
}

///|
pub fn Client::new(
  base_url? : String = "http://localhost:8000",
  api_key? : String,
) -> Client {
  { base_url, api_key }
}

///|
fn build_query_string(params : Array[(String, String)]) -> String {
  if params.is_empty() {
    return ""
  }
  "?" + params.map(fn(p) { "\{p.0}=\{p.1}" }).join("&")
}

///|
fn json_obj(entries : Array[(String, Json?)]) -> Json {
  let map : Map[String, Json] = {}
  for entry in entries {
    match entry {
      (key, Some(value)) => map[key] = value
      _ => ()
    }
  }
  Json::object(map)
}

///|
fn add_param(
  params : Array[(String, String)],
  key : String,
  value : String?,
) -> Unit {
  match value {
    Some(v) => params.push((key, v))
    None => ()
  }
}

///|
fn add_int_param(
  params : Array[(String, String)],
  key : String,
  value : Int?,
) -> Unit {
  match value {
    Some(v) => params.push((key, v.to_string()))
    None => ()
  }
}

///|
fn extract_response_data(json : Json) -> Json raise PowerMemError {
  match json {
    Object({ "success": False, "message": String(msg), .. }) =>
      raise ApiError(msg)
    Object({ "success": False, .. }) => raise ApiError("API request failed")
    Object({ "data": data, .. }) => data
    _ => json
  }
}

///|
fn[T : FromJson] parse_response(json : Json) -> T raise PowerMemError {
  @json.from_json(json) catch {
    e => raise ParseError("\{e}")
  }
}

///|
fn build_default_headers(api_key : String?) -> Map[String, String] {
  let headers : Map[String, String] = { "Content-Type": "application/json" }
  match api_key {
    Some(key) => headers["X-API-Key"] = key
    None => ()
  }
  headers
}

///|
async fn Client::do_json_request(
  self : Client,
  meth : @http.RequestMethod,
  path : String,
  query : Array[(String, String)],
  body : Json?,
) -> Json raise PowerMemError {
  let full_path = "/api/v1" + path + build_query_string(query)
  let headers = build_default_headers(self.api_key)
  let http = @http.Client::new(self.base_url, headers~) catch {
    e => raise RequestError("\{e}")
  }
  let resp = try {
    match (meth, body) {
      (Get, _) => http.get(full_path)
      (Post, Some(b)) => http.post(full_path, b.stringify())
      (Post, None) => http.post(full_path, "")
      (Put, Some(b)) => http.put(full_path, b.stringify())
      (Put, None) => http.put(full_path, "")
      (_, Some(b)) => {
        http.request(meth, full_path)
        http.write(b.stringify())
        http.end_request()
      }
      (_, None) => {
        http.request(meth, full_path)
        http.end_request()
      }
    }
  } catch {
    e => raise RequestError("\{e}")
  }
  let data = http.read_all() catch { e => raise ParseError("\{e}") }
  http.close()
  let body_text = data.text() catch { e => raise ParseError("\{e}") }
  if resp.code >= 400 {
    raise HttpError(status_code=resp.code, body=body_text)
  }
  if body_text == "" {
    return Json::object({})
  }
  let json : Json = @json.parse(body_text) catch {
    e => raise ParseError("\{e}")
  }
  extract_response_data(json)
}

///|
async fn Client::do_text_request(
  self : Client,
  meth : @http.RequestMethod,
  path : String,
  query : Array[(String, String)],
) -> String raise PowerMemError {
  let full_path = "/api/v1" + path + build_query_string(query)
  let headers = build_default_headers(self.api_key)
  let http = @http.Client::new(self.base_url, headers~) catch {
    e => raise RequestError("\{e}")
  }
  let resp = try {
    match meth {
      Get => http.get(full_path)
      _ => {
        http.request(meth, full_path)
        http.end_request()
      }
    }
  } catch {
    e => raise RequestError("\{e}")
  }
  let data = http.read_all() catch { e => raise ParseError("\{e}") }
  http.close()
  let body_text = data.text() catch { e => raise ParseError("\{e}") }
  if resp.code >= 400 {
    raise HttpError(status_code=resp.code, body=body_text)
  }
  body_text
}
