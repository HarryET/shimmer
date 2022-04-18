import nerf/websocket
import gleam/result
import gleam/string
import gleam/int
import gleam/io
import shimmer/ws/packet.{IdentifyPacket, IdentifyPacketData, Packet, PurePacket}
import shimmer/internal/error.{ShimmerError}
import gleam/erlang/atom
import gleam/option.{None, Some}

pub fn ws_frame_to_packet(frame: String) -> Result(Packet, ShimmerError) {
  packet.from_json_string(frame)
}

pub fn ws_frame_to_pure_packet(
  frame: String,
) -> Result(PurePacket, ShimmerError) {
  case packet.from_json_string(frame) {
    Ok(pac) -> Ok(packet.to_pure_packet(pac))
    Error(e) -> Error(e)
  }
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
  let pure_identify_packet = packet.to_pure_packet(identify_packet)
  websocket.send(
    conn,
    packet.json_string(
      pure_identify_packet.op,
      pure_identify_packet.s,
      pure_identify_packet.t,
      packet.get_data_as_json(identify_packet),
    ),
  )
}
