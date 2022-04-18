import gleam/option.{None, Option}
import shimmer/internal/error
import gleam/dynamic.{Dynamic, dynamic, field, int, optional, string}
import gleam/result
import gleam/json.{Json}
import shimmer/types/user.{User}

pub type HelloPacketData {
  HelloPacketData(heartbeat_interval: Int)
}

pub type ReadyPacketData {
  ReadyPacketData(user: User)
}

pub type IdentifyPacketData {
  IdentifyPacketData(token: String, intents: Int, properties: Option(Dynamic))
}

pub type PurePacket {
  PurePacket(op: Int, s: Option(Int), t: Option(String))
}

pub type Packet {
  RawPacket(op: Int, s: Option(Int), t: Option(String), d: Option(Dynamic))
  HelloPacket(op: Int, s: Option(Int), t: Option(String), d: HelloPacketData)
  ReadyPacket(op: Int, s: Option(Int), t: Option(String), d: ReadyPacketData)
  IdentifyPacket(
    op: Int,
    s: Option(Int),
    t: Option(String),
    d: IdentifyPacketData,
  )
}

pub fn from_json_string(encoded: String) -> Result(Packet, error.ShimmerError) {
  let packet_decoded =
    dynamic.decode4(
      RawPacket,
      field("op", of: int),
      field("s", of: optional(int)),
      field("t", of: optional(string)),
      field("d", of: optional(dynamic)),
    )

  json.decode(from: encoded, using: packet_decoded)
  |> result.map_error(error.InvalidJson)
}

pub fn get_data_as_json(packet: Packet) -> json.Json {
  case packet {
    IdentifyPacket(_, _, _, d) ->
      json.object([
        #("token", json.string(d.token)),
        #("intents", json.int(d.intents)),
      ])
    _ -> json.object([])
  }
}

pub fn to_pure_packet(packet: Packet) -> PurePacket {
  case packet {
    IdentifyPacket(op, s, t, _) -> PurePacket(op: op, s: s, t: t)
    _ -> PurePacket(op: 0, s: None, t: None)
  }
}

pub fn json_string(
  op: Int,
  s: Option(Int),
  t: Option(String),
  d: json.Json,
) -> String {
  json.object([
    #("op", json.int(op)),
    #("s", json.nullable(s, of: json.int)),
    #("t", json.nullable(t, of: json.string)),
    #("d", d),
  ])
  |> json.to_string
}
