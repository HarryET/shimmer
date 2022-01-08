import gleam/http.{Method, Request}
import gleam/string

pub fn new(method: Method, path: String) -> Request(String) {
  http.default_req()
  |> http.set_method(method)
  |> http.set_host("https://discord.com")
  |> http.set_path(string.append(to: "/api/v9", suffix: path))
  |> http.prepend_req_header("accept", "application/json")
}

pub fn new_with_auth(
  method: Method,
  path: String,
  token: String,
) -> Request(String) {
  new(method, path)
  |> http.prepend_req_header(
    "authorization",
    string.append(to: "Bot ", suffix: token),
  )
}
