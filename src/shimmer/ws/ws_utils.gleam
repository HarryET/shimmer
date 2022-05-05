import nerf/websocket
import gleam/string
import gleam/int
import shimmer/ws/packet.{IdentifyPacket, IdentifyPacketData, Packet}
import shimmer/internal/error.{ShimmerError}
import gleam/option.{None}

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
pub fn gateway_identify(payload: IdentifyPacketData, conn: websocket.Connection) {
  let identify_packet = IdentifyPacket(op: 2, s: None, t: None, d: payload)
  websocket.send(conn, packet.json_string(identify_packet))
}
