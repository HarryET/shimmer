import gleam/json
import gleam/dynamic
import gleam/result
import shimmer/internal/error

pub type User {
  User(id: String, username: String, discriminator: String, bot: Bool)
}

pub fn from_json_string(encoded: String) -> Result(User, error.ShimmerError) {
  try data =
    json.decode(encoded)
    |> result.map_error(error.InvalidJson)

  let data = dynamic.from(data)
  try user =
    {
      try id = dynamic.field(data, "id")
      try id = dynamic.string(id)

      try username = dynamic.field(data, "username")
      try username = dynamic.string(username)

      try discriminator = dynamic.field(data, "discriminator")
      try discriminator = dynamic.string(discriminator)

      try is_bot = dynamic.field(data, "bot")
      try is_bot = dynamic.bool(is_bot)
      Ok(User(
        id: id,
        username: username,
        discriminator: discriminator,
        bot: is_bot,
      ))
    }
    |> result.map_error(error.InvalidFormat)

  Ok(user)
}
