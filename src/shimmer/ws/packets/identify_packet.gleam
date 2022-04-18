import gleam/dynamic.{Dynamic}
import shimmer/ws/packet.{Packet}
import gleam/json

pub type IdentifyPacketData {
  IdentifyPacketData(token: String, intents: Int, properties: Dynamic)
}

pub fn to_json_string(packet: Packet, d: IdentifyPacketData) -> String {
  json.object([
    #("op", json.int(packet.op)),
    #("s", json.nullable(packet.s, of: json.int)),
    #("t", json.nullable(packet.t, of: json.string)),
    #(
      "d",
      json.object([
        #("token", json.string(d.token)),
        #("intents", json.int(d.intents)),
      ]),
    ),
  ])
  |> json.to_string
}
