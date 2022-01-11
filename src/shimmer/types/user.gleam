import gleam/json
import gleam/dynamic.{bool, field, string}
import gleam/result
import shimmer/internal/error

pub type User {
  User(id: String, username: String, discriminator: String, bot: Bool)
}

pub fn from_json_string(encoded: String) -> Result(User, error.ShimmerError) {
  let user_decoder =
    dynamic.decode4(
      User,
      field("id", of: string),
      field("username", of: string),
      field("discriminator", of: string),
      field("bot", of: bool),
    )

  json.decode(from: encoded, using: user_decoder)
  |> result.map_error(error.InvalidJson)
}
