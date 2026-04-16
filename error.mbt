///|
pub(all) suberror PowerMemError {
  HttpError(status_code~ : Int, body~ : String)
  ApiError(String)
  ParseError(String)
  RequestError(String)
} derive(Debug)
