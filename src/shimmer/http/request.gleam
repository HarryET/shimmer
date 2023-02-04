import gleam/http.{Method}
import gleam/http/request.{Request}
import gleam/string

pub fn new(method: Method, path: String) -> Request(String) {
  request.new()
  |> request.set_method(method)
  |> request.set_host("discord.com")
  |> request.set_path(string.append(to: "/api/v10", suffix: path))
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

pub fn set_body(request: Request(String), body: String) -> Request(String) {
  request
  |> request.set_body(body)
  |> request.prepend_header("content-type", "application/json")
}
