import gleam/option.{Option}
import shimmer/internal/error
import gleam/json
import gleam/dynamic.{dynamic, field, int, optional, string}
import gleam/result

pub type Packet {
  Packet(op: Int, s: Option(Int), t: Option(String), d: Option(dynamic.Dynamic))
}

pub fn from_json_string(encoded: String) -> Result(Packet, error.ShimmerError) {
  let packet_decoded =
    dynamic.decode4(
      Packet,
      field("op", of: int),
      field("s", of: optional(int)),
      field("t", of: optional(string)),
      field("d", of: optional(dynamic)),
    )

  json.decode(from: encoded, using: packet_decoded)
  |> result.map_error(error.InvalidJson)
}

pub fn to_json_string(packet: Packet) -> String {
  packet
  |> json.to_string
}
