import gleam/io
import gleam/otp/process.{
  Sender, bare_message_receiver, map_receiver, merge_receiver,
}
import gleam/otp/actor.{Continue, Ready, Spec, StartError}
import gleam/option.{Some}
import gleam/dynamic.{Dynamic}
import shimmer/ws/ws_utils
import gleam/int
import gleam/order.{Gt, Order}
import nerf/websocket.{Connection}

pub type Message {
  Bare(Dynamic)
  HeartbeatNow
}

pub type State {
  State(
    self_sender: Sender(Message),
    heartbeat_interval: Int,
    sequence: Int,
    conn: Connection,
  )
}

pub fn websocket_actor() -> Result(Sender(Message), StartError) {
  let init = fn() {
    let #(heartbeat_sender, heartbeat_reciever) = process.new_channel()
    process.send(heartbeat_sender, HeartbeatNow)

    assert Ok(conn) = ws_utils.open_gateway()

    let bare_reciever = bare_message_receiver()
    let mapped_bare_reciever =
      map_receiver(bare_reciever, fn(msg) { Bare(msg) })

    Ready(
      State(
        self_sender: heartbeat_sender,
        heartbeat_interval: 41250,
        sequence: -1,
        conn: conn,
      ),
      Some(merge_receiver(heartbeat_reciever, mapped_bare_reciever)),
    )
  }

  let loop = fn(msg: Message, state: State) {
    case msg {
      HeartbeatNow -> {
        // Send a message to itself in the future
        process.send_after(
          state.self_sender,
          state.heartbeat_interval,
          HeartbeatNow,
        )
        case int.compare(state.sequence, -1) {
          Gt -> ws_utils.gateway_heartbeat(state.sequence, state.conn)
          _ -> ws_utils.gateway_heartbeat_null(state.conn)
        }
      }

      Bare(packet) -> io.println("Packet?!")
    }

    // We're done, await the next message
    Continue(state)
  }

  // Start the actor
  actor.start_spec(Spec(init: init, loop: loop, init_timeout: 50))
}
