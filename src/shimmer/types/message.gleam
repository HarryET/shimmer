import gleam/map
import gleam/dynamic
import shimmer/internal/map_helpers.{
  dyn_atom, get_field_safe, get_map_field_safe,
}
import shimmer/internal/error
import shimmer/snowflake.{Snowflake}
import shimmer/types/user.{User}
import gleam/option.{Option}

pub type Message {
  Message(
    id: Snowflake,
    channel_id: Snowflake,
    author: User,
    content: Option(String),
    timestamp: String,
  )
}

pub fn from_map(
  map: map.Map(dynamic.Dynamic, dynamic.Dynamic),
) -> Result(Message, error.ShimmerError) {
  try id =
    map
    |> get_field_safe(dyn_atom("id"), snowflake.from_dynamic)

  try channel_id =
    map
    |> get_field_safe(dyn_atom("channel_id"), snowflake.from_dynamic)

  try author_map =
    map
    |> get_map_field_safe(dyn_atom("author"))

  try author =
    author_map
    |> user.from_map

  try content =
    map
    |> get_field_safe(dyn_atom("content"), dynamic.optional(dynamic.string))

  try timestamp =
    map
    |> get_field_safe(dyn_atom("timestamp"), dynamic.string)

  Ok(Message(id, channel_id, author, content, timestamp))
}
