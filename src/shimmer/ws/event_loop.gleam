import gleam/io
import gleam/string
import gleam/otp/process.{Sender, map_receiver}
import gleam/option.{Some}
import gleam/dynamic.{Dynamic}
import shimmer/ws/ws_utils
import gleam/int
import gleam/order.{Gt, Order}
import nerf/websocket.{Connection}

pub type Message {
  HeartbeatNow
  Frame(String)
}

pub type State {
  State(heartbeat_interval: Int, sequence: Int, conn: Connection)
}

fn init() {
  assert Ok(conn) = ws_utils.open_gateway()

  // Send a message in the future to trigger the next heartbeat
  erlang_send_after(0, HeartbeatNow, process.self())

  State(heartbeat_interval: 41250, sequence: -1, conn: conn)
}

fn heartbeat(state: State) -> State {
  // Send a message in the future to trigger the next heartbeat
  erlang_send_after(state.heartbeat_interval, HeartbeatNow, process.self())

  case int.compare(state.sequence, -1) {
    Gt -> ws_utils.gateway_heartbeat(state.sequence, state.conn)
    _ -> ws_utils.gateway_heartbeat_null(state.conn)
  }
  state
}

fn handle_frame(frame: String, state: State) -> State {
  "Got frame: "
  |> string.append(frame)
  |> io.println
  state
}

fn handle_message(msg: Message, state: State) -> State {
  case msg {
    HeartbeatNow -> heartbeat(state)
    Frame(frame) -> handle_frame(frame, state)
  }
}

// conn: Connection,
pub fn websocket_actor() -> Result(process.Pid, Dynamic) {
  // Start the actor
  start_erlang_event_loop(Spec(init: init, handle_message: handle_message))
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
