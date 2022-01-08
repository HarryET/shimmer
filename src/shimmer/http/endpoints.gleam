import gleam/result
import gleam/hackney
import gleam/result
import gleam/http.{Get}
import gleeunit/should
import shimmer/types/user
import shimmer/http/request
import shimmer/internal/error

pub fn me(token: String) -> Result(user.User, error.ShimmerError) {
  let req = request.new_with_auth(Get, "/users/@me", token)

  // Send the HTTP request to the server
  try resp =
    hackney.send(req)
    |> result.map_error(error.HttpError)

  resp
  |> http.get_resp_header("content-type")
  |> should.equal(Ok("application/json"))

  try me_user = user.from_json_string(resp.body)

  Ok(me_user)
}
