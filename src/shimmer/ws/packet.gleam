import gleam/option.{Option, Some, None}
import shimmer/internal/error
import gleam/dynamic.{Dynamic, dynamic, field, int, optional, string}
import gleam/result
import gleam/json
import shimmer/types/user.{User}

pub type HelloPacketData {
  HelloPacketData(heartbeat_interval: Int)
}

fn hello_packet_data_from_dynamic(
  data: Option(Dynamic),
) -> Result(HelloPacketData, error.ShimmerError) {
  case data {
    Some(raw_data) -> {
      try heartbeat_interval = raw_data
      |> dynamic.field("heartbeat_interval", of: int)
      |> result.map_error(error.InvalidDynamicList)
      Ok(HelloPacketData(heartbeat_interval: heartbeat_interval))
    }
    None -> Error(error.EmptyOptionWhenRequired)
  }
}

pub type ReadyPacketData {
  ReadyPacketData(user: User)
}

pub type IdentifyPacketData {
  IdentifyPacketData(token: String, intents: Int, properties: Option(Dynamic))
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

  try packet =
    json.decode(from: encoded, using: packet_decoded)
    |> result.map_error(error.InvalidJson)

  case packet.op {
    10 -> {
      case packet {
        RawPacket(_, _, _, d) -> {
          try data = hello_packet_data_from_dynamic(d)
          Ok(HelloPacket(op: packet.op, s: packet.s, t: packet.t, d: data))
        }
        _ -> Ok(packet)
      }
    }
    _ -> Ok(packet)
  }
}

pub fn get_data_as_json(packet: Packet) -> json.Json {
  case packet {
    IdentifyPacket(_, _, _, d) ->
      json.object([
        #("token", json.string(d.token)),
        #("intents", json.int(d.intents)),
        #("properties", json.object([
          #("os", json.string("Windows")), // TODO dynamic
          #("broswer", json.string("Shimmer/0.1.0")), // TODO dynamic
          #("device", json.string("Shimmer/0.1.0")), // TODO dynamic
        ])),
      ])
    _ -> json.object([])
  }
}

pub fn json_string(packet: Packet) -> String {
  let data = get_data_as_json(packet)

  json.object([
    #("op", json.int(packet.op)),
    #("s", json.nullable(packet.s, of: json.int)),
    #("t", json.nullable(packet.t, of: json.string)),
    #("d", data),
  ])
  |> json.to_string
}
