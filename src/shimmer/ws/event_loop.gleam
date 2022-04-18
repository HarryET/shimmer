import gleam/io
import gleam/string
import gleam/option.{None, Some}
import gleam/dynamic.{Dynamic}
import shimmer/ws/ws_utils
import gleam/int
import gleam/order.{Gt}
import nerf/websocket.{Connection}
import shimmer/ws/packet.{
  HelloPacket, HelloPacketData, IdentifyPacketData, Packet, ReadyPacketData,
}
import gleam/otp/process
import shimmer/internal/error.{ShimmerError}

pub type Message {
  HeartbeatNow
  Frame(String)
}

pub type IdentifyInfo {
  IdentifyInfo(token: String, intents: Int)
}

pub type State {
  State(
    heartbeat_interval: Int,
    sequence: Int,
    conn: Connection,
    identify_info: IdentifyInfo,
  )
}

// TODO fix, not being run.
fn heartbeat(state: State) -> State {
  // Send a message in the future to trigger the next heartbeat
  erlang_send_after(state.heartbeat_interval, process.self(), HeartbeatNow)

  case int.compare(state.sequence, -1) {
    Gt -> ws_utils.gateway_heartbeat(state.sequence, state.conn)
    _ -> ws_utils.gateway_heartbeat_null(state.conn)
  }
  state
}

fn handle_hello(data: HelloPacketData, state: State) -> State {
  // ? Start Heartbeats
  erlang_send_after(0, process.self(), HeartbeatNow)

  // Send Identify Payload
  ws_utils.gateway_identify(
    IdentifyPacketData(
      token: state.identify_info.token,
      intents: state.identify_info.intents,
      properties: None,
    ),
    state.conn,
  )

  // Return state with new heartbeat interval.
  State(..state, heartbeat_interval: data.heartbeat_interval)
}

fn handle_ready(_packet: Packet, _data: ReadyPacketData, state: State) -> State {
  io.println("READY!")
  state
}

fn handle_error(error: ShimmerError, state: State) -> State {
  io.debug(error)
  state
}

fn handle_frame(frame: String, state: State) -> State {
  case ws_utils.ws_frame_to_packet(frame) {
    Ok(packet) ->
      case packet.op {
        // 0 ->
        //   case packet.t {
        //     Some(event) ->
        //       case event {
        //         "READY" ->
        //           case packet.d {
        //             Some(packet_data) ->
        //               case ready_packet.from_dynamic(packet_data) {
        //                 Ok(ready_data) ->
        //                   handle_ready(packet, ready_data, state)
        //                 Error(err) -> handle_error(err, state)
        //               }
        //             None -> state
        //           }
        //         e -> {
        //           io.println(
        //             "Unknown Event: "
        //             |> string.append(e),
        //           )
        //           state
        //         }
        //       }
        //     None -> state
        //   }
        10 ->
          case packet {
            HelloPacket(d: packet_data, ..) -> handle_hello(packet_data, state)
            _ -> state
          }
        11 -> state
        _ -> {
          io.println(
            "Unknown Packet ["
            |> string.append(int.to_string(packet.op))
            |> string.append("] ")
            |> string.append(frame),
          )
          state
        }
      }
    Error(err) -> {
      io.println(
        "Invalid Packet "
        |> string.append(frame),
      )
      handle_error(err, state)
    }
  }
}

fn handle_message(msg: Message, state: State) -> State {
  case msg {
    HeartbeatNow -> heartbeat(state)
    Frame(frame) -> handle_frame(frame, state)
  }
}

// conn: Connection,
pub fn websocket_actor(
  identify_info: IdentifyInfo,
) -> Result(process.Pid, Dynamic) {
  // Start the actor
  start_erlang_event_loop(Spec(
    init: fn() {
      assert Ok(conn) = ws_utils.open_gateway()

      State(
        heartbeat_interval: 41250,
        sequence: -1,
        conn: conn,
        identify_info: identify_info,
      )
    },
    handle_message: handle_message,
  ))
}

pub type Spec {
  Spec(init: fn() -> State, handle_message: fn(Message, State) -> State)
}

external fn start_erlang_event_loop(Spec) -> Result(process.Pid, Dynamic) =
  "shimmer_event_loop" "start_link"

external fn erlang_send_after(
  Int,
  process.Pid,
  Message,
) -> Result(process.Pid, Dynamic) =
  "erlang" "send_after"
