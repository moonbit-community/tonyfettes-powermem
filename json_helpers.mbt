///|
/// Decode: extract a required string field.
fn json_require_string(
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
/// Decode: extract a required int field.
fn json_require_int(
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
/// Decode: extract a required double field.
fn json_require_double(
  obj : Map[String, Json],
  key : String,
  path : @json.JsonPath,
) -> Double raise @json.JsonDecodeError {
  match obj.get(key) {
    Some(Number(n, ..)) => n
    _ => raise @json.JsonDecodeError((path.add_key(key), "expected number"))
  }
}

///|
/// Decode: extract an optional string (null or missing → None).
fn json_opt_string(obj : Map[String, Json], key : String) -> String? {
  match obj.get(key) {
    Some(String(s)) => Some(s)
    _ => None
  }
}

///|
/// Decode: extract an optional double (null or missing → None).
fn json_opt_double(obj : Map[String, Json], key : String) -> Double? {
  match obj.get(key) {
    Some(Number(n, ..)) => Some(n)
    _ => None
  }
}

///|
/// Decode: extract an optional bool (null or missing → None).
fn json_opt_bool(obj : Map[String, Json], key : String) -> Bool? {
  match obj.get(key) {
    Some(True) => Some(true)
    Some(False) => Some(false)
    _ => None
  }
}

///|
/// Decode: extract an optional Json value (null or missing → None).
fn json_opt_json(obj : Map[String, Json], key : String) -> Json? {
  match obj.get(key) {
    Some(Null) | None => None
    Some(v) => Some(v)
  }
}

///|
/// Decode: extract a required array and parse each element.
fn[T : @json.FromJson] json_require_array(
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
/// Decode: require a JSON object, raising if the value isn't one.
fn json_as_object(
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
/// Encode: set a field only when `Some`; skip when `None`.
fn[T : ToJson] json_set_opt(
  m : Map[String, Json],
  key : String,
  value : T?,
) -> Unit {
  match value {
    Some(v) => m[key] = v.to_json()
    None => ()
  }
}
