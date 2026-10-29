///|
pub(all) suberror PowerMemError {
  HttpError(status_code~ : Int32, body~ : String)
  ApiError(String)
  ParseError(String)
  RequestError(String)
} derive(Debug)
