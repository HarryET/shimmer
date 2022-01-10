import gleam/io
import gleam/string
import gleam/otp/process.{Sender, map_receiver}
import gleam/option.{None, Some}
import gleam/dynamic.{Dynamic}
import shimmer/ws/ws_utils
import gleam/int
import gleam/order.{Gt, Order}
import nerf/websocket.{Connection}
import shimmer/types/hello_event.{HelloEvent}
import shimmer/types/packet.{Packet}

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
  erlang_send_after(state.heartbeat_interval, HeartbeatNow, process.self())

  io.println("Heartbeat.")

  case int.compare(state.sequence, -1) {
    Gt -> ws_utils.gateway_heartbeat(state.sequence, state.conn)
    _ -> ws_utils.gateway_heartbeat_null(state.conn)
  }
  state
}

fn handle_hello(packet: Packet, data: HelloEvent, state: State) -> State {
  io.println(
    "Heartbeat Interval is: "
    |> string.append(int.to_string(data.heartbeat_interval)),
  )
  erlang_send_after(1, HeartbeatNow, process.self())
  ws_utils.gateway_identify(
    state.identify_info.token,
    state.identify_info.intents,
    state.conn,
  )
  State(
    sequence: state.sequence,
    heartbeat_interval: data.heartbeat_interval,
    conn: state.conn,
    identify_info: state.identify_info,
  )
}

fn handle_frame(frame: String, state: State) -> State {
  case ws_utils.ws_frame_to_packet(frame) {
    Ok(packet) ->
      case packet.op {
        10 -> {
          io.println("Hello From Gateway! 👋")
          case packet.d {
            Some(packet_data) ->
              case hello_event.from_dynamic(packet_data) {
                Ok(hello_data) -> handle_hello(packet, hello_data, state)
                Error(_error) -> state
              }
            None -> state
          }
        }
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
    Error(_error) -> state
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
  Message,
  process.Pid,
) -> Result(process.Pid, Dynamic) =
  "erlang" "send_after"
