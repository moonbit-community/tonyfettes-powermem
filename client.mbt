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
/// Parse `base_url` with `@url.Url`, set the API pathname, and attach query
/// parameters. Returns (origin, path_with_query) for the async HTTP client
/// which takes those two components separately.
fn build_request_target(
  base_url : String,
  path : String,
  query : Array[(String, String)],
) -> (String, String) raise PowerMemError {
  let url = @url.Url::parse(base_url) catch {
    e => raise RequestError("invalid base_url: \{e}")
  }
  url.set_pathname("/api/v1" + path)
  if !query.is_empty() {
    url.set_search_params(@url.UrlSearchParams::from_pairs(query))
  }
  (url.origin(), url.pathname() + url.search())
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
  let (origin, req_path) = build_request_target(self.base_url, path, query)
  let headers = build_default_headers(self.api_key)
  let http = @http.Client::new(origin, headers~) catch {
    e => raise RequestError("\{e}")
  }
  let resp = try {
    match (meth, body) {
      (Get, _) => http.get(req_path)
      (Post, Some(b)) => http.post(req_path, b.stringify())
      (Post, None) => http.post(req_path, "")
      (Put, Some(b)) => http.put(req_path, b.stringify())
      (Put, None) => http.put(req_path, "")
      (_, Some(b)) => {
        http.request(meth, req_path)
        http.write(b.stringify())
        http.end_request()
      }
      (_, None) => {
        http.request(meth, req_path)
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
  let (origin, req_path) = build_request_target(self.base_url, path, query)
  let headers = build_default_headers(self.api_key)
  let http = @http.Client::new(origin, headers~) catch {
    e => raise RequestError("\{e}")
  }
  let resp = try {
    match meth {
      Get => http.get(req_path)
      _ => {
        http.request(meth, req_path)
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
