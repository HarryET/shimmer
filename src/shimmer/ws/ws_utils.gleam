import nerf/websocket
import nerf/websocket.{Text}
import gleam/result
import gleam/string
import gleam/int
import gleam/io
import shimmer/types/packet.{Packet}
import shimmer/internal/error.{ShimmerError}
import gleam/erlang/atom

pub fn ws_frame_to_packet(frame: String) -> Result(Packet, ShimmerError) {
  packet.from_json_string(frame)
}

/// Opens a connection to the gateway.
pub fn open_gateway() -> Result(websocket.Connection, Nil) {
  assert Ok(conn) =
    websocket.connect("gateway.discord.gg", "/?v=9&encoding=json", 443, [])

  Ok(conn)
}

pub fn gateway_heartbeat(sequence: Int, conn: websocket.Connection) {
  let payload =
    string.append(
      "{\"op\": 1, \"d\": ",
      string.append(int.to_string(sequence), "}"),
    )
  websocket.send(conn, payload)
}

pub fn gateway_heartbeat_null(conn: websocket.Connection) {
  let payload = "{\"op\": 1, \"d\": null}"
  websocket.send(conn, payload)
}

/// Sends an identify packet to the gateway
pub fn gateway_identify(token: String, intents: Int, conn: websocket.Connection) {
  let identify_payload =
    "{\"op\":2,\"d\":{\"token\":\""
    |> string.append(token)
    |> string.append("\",\"intents\":")
    |> string.append(int.to_string(intents))
    // TODO don't hardcode the OS, make it dynamic ya know
    |> string.append(
      ",\"properties\":{\"$os\":\"macos\",\"$browser\":\"shimmer\",\"$device\":\"shimmer\"}}}",
    )

  websocket.send(conn, identify_payload)
}
