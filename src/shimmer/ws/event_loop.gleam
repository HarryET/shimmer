import shimmer/internal/network/websocket.{Connection}
import shimmer/client.{Client}
import gleam/otp/actor.{InitResult, Next}
import shimmer/http/endpoints
import shimmer/internal/erl/uri
import gleam/io
import gleam/result
import gleam/erlang/process.{Selector, Subject}
import gleam/option.{None, Option, Some}
import shimmer/ws/ws_utils

pub type Message {
  /// Used for the Websocket actor to update the state value
  Sync(ActorState)
  /// Heartbeat Message Only
  Beat
  /// Websocket Message Only
  Next
  /// Kill the Actor
  Halt
}

pub type WebsocketMeta {
  WebsocketMeta(token: String, intents: Int)
}

pub type Selectors {
  Selectors(websocket: Selector(Message), heartbeat: Selector(Message))
}

pub type Subjects {
  Subjects(
    to_websocket: Subject(Message),
    to_heartbeat: Option(Subject(Message)),
  )
}

pub type ActorState {
  ActorState(
    heartbeat_interval: Int,
    sequence: Int,
    conn: Connection,
    meta: WebsocketMeta,
    selectors: Selectors,
    subjects: Subjects,
  )
}

pub fn ws_actor_setup(client: Client) -> fn() -> InitResult(ActorState, Message) {
  fn() {
    let setup = fn(inner_client: Client) {
      // 1. Fetch Websocket URL for Bot
      try gateway_settings =
        endpoints.bot_gateway(inner_client.token)
        |> result.replace_error(actor.Failed(
          "Couldn't get bot gateway information",
        ))

      let url =
        uri.parse(gateway_settings.url)
        |> io.debug

      // 2. Open Websocket
      try conn =
        websocket.connect(url.host, "/?v=10&encoding=json", 443, [])
        |> result.replace_error(actor.Failed("Failed to open websocket"))

      let to_websocket_subject = process.new_subject()
      let websocket_selector =
        process.new_selector()
        |> process.selecting(to_websocket_subject, fn(a) { a })

      let heartbeat_selector = process.new_selector()

      Ok(actor.Ready(
        ActorState(
          heartbeat_interval: -1,
          sequence: -1,
          conn: conn,
          meta: WebsocketMeta(
            token: inner_client.token,
            intents: inner_client.intents,
          ),
          selectors: Selectors(
            websocket: websocket_selector,
            heartbeat: heartbeat_selector,
          ),
          subjects: Subjects(
            to_websocket: to_websocket_subject,
            to_heartbeat: None,
          ),
        ),
        websocket_selector,
      ))
    }

    case setup(client) {
      Ok(ready) -> ready
      Error(failed) -> failed
    }
  }
}

pub fn ws_actor_loop(msg: Message, _state: ActorState) -> Next(ActorState) {
  case msg {
    Sync(new_state) -> actor.Continue(new_state)
    _ ->
      actor.Stop(process.Abnormal("Heartbeat actor recieved unknown message"))
  }
}

pub fn heartbeat_actor_setup(
  inital_state: ActorState,
) -> fn() -> InitResult(ActorState, Message) {
  fn() {
    let to_heartbeat_subject = process.new_subject()
    let new_heartbeat_selector =
      inital_state.selectors.heartbeat
      |> process.selecting(to_heartbeat_subject, fn(a) { a })
    let new_state =
      ActorState(
        ..inital_state,
        selectors: Selectors(
          ..inital_state.selectors,
          heartbeat: new_heartbeat_selector,
        ),
        subjects: Subjects(
          ..inital_state.subjects,
          to_heartbeat: Some(to_heartbeat_subject),
        ),
      )

    // Update the main Websocket Actor
    process.send(new_state.subjects.to_websocket, Sync(new_state))

    actor.Ready(new_state, new_state.selectors.heartbeat)
  }
}

pub fn heartbeat_actor_loop(msg: Message, state: ActorState) -> Next(ActorState) {
  case msg {
    Sync(new_state) -> actor.Continue(new_state)
    Beat -> {
      case state.sequence {
        -1 -> ws_utils.gateway_heartbeat_null(state.conn)
        _ -> ws_utils.gateway_heartbeat(state.sequence, state.conn)
      }
      // TODO send `Beat` after heartbeat interval
      case state.subjects.to_heartbeat {
        Some(subject) -> {
          process.send_after(subject, state.heartbeat_interval, Beat)
          Nil
        }
        // TODO handle better!
        None -> io.println("Failed to send next beat, bot will die!")
      }
      actor.Continue(state)
    }
    _ ->
      actor.Stop(process.Abnormal("Heartbeat actor recieved unknown message"))
  }
}
