import gleam/map
import gleam/dynamic.{field}
import shimmer/internal/map_helpers.{get_field_safe}
import shimmer/internal/error
import gleam/option.{Option}
import gleam/json
import gleam/result
import shimmer/snowflake.{Snowflake}

pub type User {
  PartialUser(
    id: Snowflake,
    username: String,
    discriminator: String,
    avatar: Option(String),
  )
  FullUser(
    id: Snowflake,
    username: String,
    discriminator: String,
    avatar: Option(String),
    bot: Bool,
    system: Bool,
    mfa_enabled: Bool,
    banner: Option(String),
    accent_color: Option(Int),
    verified: Bool,
    email: Option(String),
    flags: Int,
    premium_type: Int,
    public_flags: Int,
  )
}

pub fn from_map(
  map: map.Map(dynamic.Dynamic, dynamic.Dynamic),
  key_func: fn(String) -> dynamic.Dynamic,
) -> Result(User, error.ShimmerError) {
  // try bot =
  //   map
  //   |> get_field_safe(key_func("bot"), dynamic.bool)

  // try email =
  //   map
  //   |> get_field_safe(key_func("email"), dynamic.optional(dynamic.string))

  // try flags =
  //   map
  //   |> get_field_safe(key_func("flags"), dynamic.int)

  // try verified =
  //   map
  //   |> get_field_safe(key_func("verified"), dynamic.bool)

  // try mfa_enabled =
  //   map
  //   |> get_field_safe(key_func("mfa_enabled"), dynamic.bool)

  // TODO detect if full user and return that

  try id =
    map
    |> get_field_safe(key_func("id"), snowflake.from_dynamic)

  try username =
    map
    |> get_field_safe(key_func("username"), dynamic.string)

  try discriminator =
    map
    |> get_field_safe(key_func("discriminator"), dynamic.string)

  try avatar =
    map
    |> get_field_safe(key_func("avatar"), dynamic.optional(dynamic.string))

  Ok(PartialUser(id, username, discriminator, avatar))
}

pub fn from_json_string(encoded: String) -> Result(User, error.ShimmerError) {
  // field("bot", of: dynamic.bool),
  // field("email", of: dynamic.optional(dynamic.string)),
  // field("flags", of: dynamic.int),
  // field("mfa_enabled", of: dynamic.bool),
  // field("verified", of: dynamic.bool),
  let user_decoder =
    dynamic.decode4(
      PartialUser,
      field("id", of: snowflake.from_dynamic),
      field("username", of: dynamic.string),
      field("discriminator", of: dynamic.string),
      field("avatar", of: dynamic.optional(dynamic.string)),
    )

  json.decode(from: encoded, using: user_decoder)
  |> result.map_error(error.InvalidJson)
}
