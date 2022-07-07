import gleam/http.{Method}
import gleam/http/request.{Request}
import gleam/string

pub fn new(method: Method, path: String) -> Request(String) {
  request.new()
  |> request.set_method(method)
  |> request.set_host("https://discord.com")
  |> request.set_path(string.append(to: "/api/v9", suffix: path))
  |> request.prepend_header("accept", "application/json")
}

pub fn new_with_auth(
  method: Method,
  path: String,
  token: String,
) -> Request(String) {
  new(method, path)
  |> request.prepend_header(
    "authorization",
    string.append(to: "Bot ", suffix: token),
  )
}
