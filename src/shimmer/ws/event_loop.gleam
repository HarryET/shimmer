import shimmer/internal/network/websocket.{Connection}
import shimmer/client.{Client, Shard}
import shimmer/intents.{Intent}
import gleam/otp/actor.{InitResult, Next}
import shimmer/internal/erl/uri
import gleam/io
import gleam/result
import gleam/erlang/atom
import gleam/erlang/process.{Selector, Subject}
import gleam/option.{None, Option, Some}
import shimmer/ws/packet
import gleam/dynamic
import shimmer/ws/packets/hello
import shimmer/ws/packets/ready
import shimmer/ws/packets/identify
import shimmer/ws/packets/message_create
import gleam/map
import gleam/erlang
import gleam/int
import gleam/string
import shimmer/handlers.{Handlers}
import shimmer/types/presence.{Presence}
import shimmer/internal/error
import shimmer/http

pub type Message {
  /// Frames from Gun
  WebsocketFrame(websocket.Frame)
  /// Send a request to update the Bot's presence
  UpdatePresence(Presence)
  /// Heartbeat Message Only
  Beat
  /// Kill the Actor
  Halt
}

pub type WebsocketMeta {
  WebsocketMeta(
    token: String,
    intents: List(Intent),
    handlers: Handlers(Message),
  )
}

pub type GatewaySession {
  GatewaySession(session_id: String, resume_gateway_url: String)
}

pub type ActorState {
  ActorState(
    heartbeat_interval: Int,
    sequence: Int,
    conn: Connection,
    meta: WebsocketMeta,
    selector: Selector(Message),
    subject: Subject(Message),
    shard: Shard(Message),
    session: Option(GatewaySession),
  )
}

pub fn actor_setup(
  client: Client(Message),
  gateway_url: String,
  handlers: Handlers(Message),
) -> fn() -> InitResult(ActorState, Message) {
  fn() {
    let setup = fn(inner_client: Client(Message)) {
      let url = uri.parse(gateway_url)

      // 2. Open Websocket
      try conn =
        websocket.connect(url.host, "/?v=10&encoding=etf", 443, [])
        |> result.replace_error(actor.Failed("Failed to open websocket"))

      let to_self_subject = process.new_subject()
      let selector =
        process.new_selector()
        |> process.selecting(inner_client.to_self, fn(a) { a })
        |> process.selecting(to_self_subject, fn(a) { a })
        |> process.selecting_record4(
          atom.create_from_string("gun_ws"),
          fn(_pid, _ref, dyn_frame) {
            let map = fn(frame: websocket.Frame) { WebsocketFrame(frame) }

            map(dynamic.unsafe_coerce(dyn_frame))
          },
        )

      Ok(actor.Ready(
        ActorState(
          heartbeat_interval: -1,
          sequence: -1,
          conn: conn,
          meta: WebsocketMeta(
            token: inner_client.token,
            intents: inner_client.intents,
            handlers: handlers,
          ),
          selector: selector,
          subject: to_self_subject,
          shard: inner_client.shard,
          session: None,
        ),
        selector,
      ))
    }

    case setup(client) {
      Ok(ready) -> ready
      Error(failed) -> failed
    }
  }
}

fn internal_error_handler(
  state: ActorState,
  error: Result(a, error.ShimmerError),
) -> Next(ActorState) {
  // TODO actually handle errors
  io.debug(error)
  actor.Continue(state)
}

pub fn actor_loop(msg: Message, state: ActorState) -> Next(ActorState) {
  let client =
    Client(
      token: state.meta.token,
      intents: state.meta.intents,
      to_self: state.subject,
      shard: state.shard,
      http_client: http.new_client(state.meta.token),
    )

  case msg {
    WebsocketFrame(websocket.Binary(etf_bitstring)) -> {
      let dynamic_payload = parse_etf(etf_bitstring)
      case packet.from_dynamic(dynamic_payload) {
        Ok(#(0, seq, Some("READY"), Some(data))) ->
          case ready.from_map(data) {
            Ok(packet) -> {
              state.meta.handlers.on_ready(packet, client)
              actor.Continue(
                ActorState(
                  ..update_state(seq, state),
                  session: Some(GatewaySession(
                    session_id: packet.session_id,
                    resume_gateway_url: packet.resume_gateway_url,
                  )),
                ),
              )
            }
            Error(e) ->
              internal_error_handler(update_state(seq, state), Error(e))
          }
        Ok(#(0, seq, Some("MESSAGE_CREATE"), Some(data))) ->
          case message_create.from_map(data) {
            Ok(packet) -> {
              state.meta.handlers.on_message(packet, client)
              actor.Continue(update_state(seq, state))
            }
            Error(e) ->
              internal_error_handler(update_state(seq, state), Error(e))
          }
        // Hello
        Ok(#(10, seq, _, Some(data))) ->
          case hello.from_map(data) {
            Ok(packet) -> {
              let new_state =
                ActorState(
                  ..update_state(seq, state),
                  heartbeat_interval: packet.heartbeat_interval,
                )
              // Send initial heartbeat
              websocket.send(
                new_state.conn,
                map.new()
                |> map.insert("op", dynamic.from(1))
                |> map.insert("d", dynamic.from(Nil))
                |> erlang.term_to_binary,
              )
              // Identify
              websocket.send(
                new_state.conn,
                identify.IdentifyPacketData(
                  token: state.meta.token,
                  intents: intents.intents_to_int(state.meta.intents),
                  shard_id: state.shard.id,
                  total_shards: state.shard.total,
                )
                |> identify.to_etf,
              )
              process.send_after(
                new_state.subject,
                new_state.heartbeat_interval,
                Beat,
              )
              actor.Continue(new_state)
            }
            Error(e) ->
              internal_error_handler(update_state(seq, state), Error(e))
          }
        // Heartbeat Ack
        Ok(#(11, seq, _, _)) -> {
          state.meta.handlers.on_heartbeat_ack(client)
          actor.Continue(update_state(seq, state))
        }
        Ok(#(_, seq, _, _)) -> actor.Continue(update_state(seq, state))
        Error(e) -> internal_error_handler(state, Error(e))
        _ -> actor.Continue(state)
      }
    }
    WebsocketFrame(websocket.Close(code, message)) -> {
      // TODO handle reconnect
      io.println(
        [
          "Websocket Closed with code: ",
          int.to_string(code),
          " and message \"",
          message,
          "\"",
        ]
        |> string.join(with: ""),
      )
      state.meta.handlers.on_disconnect(code, client)
      actor.Stop(process.Abnormal(message))
    }
    UpdatePresence(new_presence) -> {
      let payload =
        map.new()
        |> map.insert("op", dynamic.from(3))
        |> map.insert(
          "d",
          new_presence
          |> presence.to_map
          |> dynamic.from,
        )
        |> erlang.term_to_binary
      websocket.send(state.conn, payload)
      actor.Continue(state)
    }
    Beat -> {
      let payload =
        case state.sequence {
          -1 ->
            map.new()
            |> map.insert("op", dynamic.from(1))
            |> map.insert("d", dynamic.from(Nil))
          seq ->
            map.new()
            |> map.insert("op", dynamic.from(1))
            |> map.insert("d", dynamic.from(int.to_string(seq)))
        }
        |> erlang.term_to_binary
      websocket.send(state.conn, payload)
      process.send_after(state.subject, state.heartbeat_interval, Beat)
      actor.Continue(state)
    }
    _ ->
      actor.Stop(process.Abnormal("event loop's actor recieved unknown message"))
  }
}

fn update_state(seq: Option(Int), old_state: ActorState) -> ActorState {
  ActorState(
    ..old_state,
    sequence: seq
    |> option.unwrap(old_state.sequence),
  )
}

external fn parse_etf(etf: BitString) -> dynamic.Dynamic =
  "shimmer_ws" "parse_etf"
