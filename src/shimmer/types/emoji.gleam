import gleam/map
import gleam/dynamic
import gleam/string
import shimmer/snowflake.{Snowflake}

pub type Emoji {
  UnicodeEmoji(emoji: String)
  CustomEmoji(id: Snowflake, name: String, animated: Bool)
}

pub fn to_map(self: Emoji) -> map.Map(String, dynamic.Dynamic) {
  case self {
    CustomEmoji(id, name, animated) ->
      map.new()
      |> map.insert("id", dynamic.from(id))
      |> map.insert("name", dynamic.from(name))
      |> map.insert("animated", dynamic.from(animated))
    _ -> map.new()
  }
}

pub fn encode(self: Emoji) -> String {
  case self {
    UnicodeEmoji(emoji) -> emoji
    CustomEmoji(id, name, _) ->
      name
      |> string.append(":")
      |> string.append(id)
  }
}
