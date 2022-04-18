import gleam/option.{Option}
import shimmer/internal/error
import gleam/dynamic.{dynamic, field, int, optional, string}
import gleam/result
import gleam/json.{Json}

pub type Packet {
  Packet(op: Int, s: Option(Int), t: Option(String), d: Option(json.Json))
}

pub fn from_json_string(encoded: String) -> Result(Packet, error.ShimmerError) {
  let packet_decoded =
    dynamic.decode4(
      Packet,
      field("op", of: int),
      field("s", of: optional(int)),
      field("t", of: optional(string)),
      field("d", of: optional(Json)),
    )

  json.decode(from: encoded, using: packet_decoded)
  |> result.map_error(error.InvalidJson)
}

pub fn to_json_string(packet: Packet) -> String {
  json.object([
    #("op", json.int(packet.op)),
    #("s", json.nullable(packet.s, of: json.int)),
    #("t", json.nullable(packet.t, of: json.string)),
    #("d", json.nullable(packet.d, of: json.object)),
  ])
  |> json.to_string
}
