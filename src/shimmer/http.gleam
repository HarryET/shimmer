import transparent_http
import gleam/hackney
import gleam/http/request
import gleam/option.{Some}
import gleam/string

pub type HttpClient =
  transparent_http.TransparentHttp(String, hackney.Error)

fn base_req(token: String) {
  request.new()
  |> request.set_host("discord.com")
  |> request.prepend_header("accept", "application/json")
  |> request.prepend_header(
    "authorization",
    string.append(to: "Bot ", suffix: token),
  )
}

fn setup_req(req: request.Request(String)) -> request.Request(String) {
  // TODO logging?
  req
}

pub fn new_client(token: String) -> HttpClient {
  let builder =
    transparent_http.TransparentHttpBuilder(
      ..transparent_http.new_builder(hackney.send, ""),
      base_request: Some(base_req(token)),
      setup_request: Some(setup_req),
    )

  transparent_http.new(builder)
}
