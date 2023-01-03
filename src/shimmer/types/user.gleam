import gleam/map
import gleam/dynamic.{field}
import shimmer/internal/map_helpers.{dyn_atom, get_field_safe}
import shimmer/internal/error
import gleam/option.{Option}
import gleam/json
import gleam/result
import shimmer/snowflake.{Snowflake}

pub type User {
  User(
    avatar: Option(String),
    bot: Bool,
    discriminator: String,
    email: Option(String),
    flags: Int,
    id: Snowflake,
    mfa_enabled: Bool,
    username: String,
    verified: Bool,
  )
}

pub fn from_map(
  map: map.Map(dynamic.Dynamic, dynamic.Dynamic),
) -> Result(User, error.ShimmerError) {
  try avatar =
    map
    |> get_field_safe(dyn_atom("avatar"), dynamic.optional(dynamic.string))

  try bot =
    map
    |> get_field_safe(dyn_atom("bot"), dynamic.bool)

  try discriminator =
    map
    |> get_field_safe(dyn_atom("discriminator"), dynamic.string)

  try email =
    map
    |> get_field_safe(dyn_atom("email"), dynamic.optional(dynamic.string))

  try flags =
    map
    |> get_field_safe(dyn_atom("flags"), dynamic.int)

  try id =
    map
    |> get_field_safe(dyn_atom("id"), snowflake.from_dynamic)

  try mfa_enabled =
    map
    |> get_field_safe(dyn_atom("mfa_enabled"), dynamic.bool)

  try username =
    map
    |> get_field_safe(dyn_atom("username"), dynamic.string)

  try verified =
    map
    |> get_field_safe(dyn_atom("verified"), dynamic.bool)

  Ok(User(
    avatar,
    bot,
    discriminator,
    email,
    flags,
    id,
    mfa_enabled,
    username,
    verified,
  ))
}

pub fn from_json_string(encoded: String) -> Result(User, error.ShimmerError) {
  let user_decoder =
    dynamic.decode9(
      User,
      field("avatar", of: dynamic.optional(dynamic.string)),
      field("bot", of: dynamic.bool),
      field("discriminator", of: dynamic.string),
      field("email", of: dynamic.optional(dynamic.string)),
      field("flags", of: dynamic.int),
      field("id", of: snowflake.from_dynamic),
      field("mfa_enabled", of: dynamic.bool),
      field("username", of: dynamic.string),
      field("verified", of: dynamic.bool),
    )
  json.decode(from: encoded, using: user_decoder)
  |> result.map_error(error.InvalidJson)
}
