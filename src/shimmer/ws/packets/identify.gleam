import gleam/dynamic
import gleam/map
import gleam/erlang

pub type IdentifyPacketData {
  IdentifyPacketData(token: String, intents: Int)
}

pub fn to_etf(data: IdentifyPacketData) -> BitString {
  // TODO make dynamic
  let properties =
    map.new()
    |> map.insert("os", dynamic.from("unix"))
    |> map.insert("broswer", dynamic.from("shimmer"))
    |> map.insert("device", dynamic.from("shimmer"))

  let data =
    map.new()
    |> map.insert("token", dynamic.from(data.token))
    |> map.insert("intents", dynamic.from(data.intents))
    |> map.insert("properties", dynamic.from(properties))

  map.new()
  |> map.insert("op", dynamic.from(2))
  |> map.insert("d", dynamic.from(data))
  |> erlang.term_to_binary
}
