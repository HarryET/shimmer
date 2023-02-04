import gleam/result
import gleam/hackney
import gleam/http.{Get, Post}
import gleam/http/response
import gleeunit/should
import shimmer/types/user
import shimmer/http/request
import shimmer/internal/error
import shimmer/internal/types/responses/bot_gateway

pub fn me(token: String) -> Result(user.User, error.ShimmerError) {
  let req = request.new_with_auth(Get, "/users/@me", token)

  // Send the HTTP request to the server
  try resp =
    hackney.send(req)
    |> result.map_error(error.HttpError)

  resp
  |> response.get_header("content-type")
  |> should.equal(Ok("application/json"))

  user.from_json_string(resp.body)
}

pub fn bot_gateway(
  token: String,
) -> Result(bot_gateway.BotGatewayResponse, error.ShimmerError) {
  let req = request.new_with_auth(Get, "/gateway/bot", token)

  // Send the HTTP request to the server
  try resp =
    hackney.send(req)
    |> result.map_error(error.HttpError)

  resp
  |> response.get_header("content-type")
  |> should.equal(Ok("application/json"))

  bot_gateway.from_json_string(resp.body)
}

pub fn send_message(
  token: String,
  channel_id: String,
  content: String,
) -> Result(Bool, error.ShimmerError) {
  let json_body =
    "
    {
      \"content\": " <> content <> "\"
    }
    "

  let req =
    request.new_with_auth(
      Post,
      "/channels/" <> channel_id <> "/messages",
      token,
    )
    |> request.set_body(json_body)

  // Send the HTTP request to the server
  try _ =
    hackney.send(req)
    |> result.map_error(error.HttpError)

  // TODO return new message e.g.
  // resp
  // |> response.get_header("content-type")
  // |> should.equal(Ok("application/json"))
  // message.from_json_string(resp.body)
  Ok(True)
}
