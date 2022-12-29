import gleam/map
import gleam/dynamic
import gleam/list
import gleam/option.{None, Option}
import shimmer/internal/map_helpers.{
  dyn_atom, get_field_safe, get_map_field_safe,
}
import shimmer/internal/error
import shimmer/types/message.{Message}
import shimmer/types/user.{User}
import shimmer/types/member.{Member}

pub type MessageCreate {
  MessageCreate(
    message: Message,
    guild_id: Option(String),
    member: Option(Member),
    mentions: List(User),
  )
}

pub fn from_map(
  map: map.Map(dynamic.Dynamic, dynamic.Dynamic),
) -> Result(MessageCreate, error.ShimmerError) {
  try message_map =
    map
    |> get_map_field_safe(dyn_atom("message"))

  try message =
    message_map
    |> message.from_map

  try guild_id =
    map
    |> get_field_safe(dyn_atom("guild_id"), dynamic.optional(dynamic.string))

  try mentions_raw =
    map
    |> get_field_safe(
      dyn_atom("mentions"),
      dynamic.list(dynamic.map(dynamic.dynamic, dynamic.dynamic)),
    )

  try mentions =
    mentions_raw
    |> list.try_map(fn(user_map) {
      try user_cast =
        user_map
        |> user.from_map
      Ok(user_cast)
    })

  Ok(MessageCreate(message, guild_id, member: None, mentions: mentions))
}
