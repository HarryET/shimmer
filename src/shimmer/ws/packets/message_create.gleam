import gleam/map
import gleam/dynamic
import gleam/list
import gleam/option.{None, Option}
import shimmer/internal/map_helpers.{dyn_atom, dyn_key, get_field_safe}
import shimmer/internal/error
import shimmer/types/message.{Message}
import shimmer/types/user.{User}
import shimmer/types/member.{Member}
import shimmer/snowflake.{Snowflake}

pub type MessageCreate {
  MessageCreate(
    message: Message,
    guild_id: Option(Snowflake),
    member: Option(Member),
    mentions: List(User),
  )
}

pub fn from_map(
  map: map.Map(dynamic.Dynamic, dynamic.Dynamic),
) -> Result(MessageCreate, error.ShimmerError) {
  try message =
    map
    |> message.from_map

  try guild_id =
    map
    |> get_field_safe(
      dyn_atom("guild_id"),
      dynamic.optional(snowflake.from_dynamic),
    )

  try mentions_raw =
    map
    |> get_field_safe(
      dyn_key("mentions"),
      dynamic.list(dynamic.map(dynamic.dynamic, dynamic.dynamic)),
    )

  try mentions =
    mentions_raw
    |> list.try_map(fn(user_map) {
      try user_cast =
        user_map
        |> user.from_map(dyn_key)
      Ok(user_cast)
    })

  Ok(MessageCreate(message, guild_id, member: None, mentions: mentions))
}
