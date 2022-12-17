import shimmer/internal/network/websocket.{Connection}
import shimmer/client.{Client}
import gleam/otp/actor.{InitResult, Next}
import shimmer/http/endpoints
import shimmer/internal/erl/uri
import gleam/io
import gleam/result
import gleam/erlang/atom
import gleam/erlang/process.{Selector, Subject}
import gleam/option.{Option, Some}
import shimmer/ws/packet
import gleam/dynamic
import shimmer/ws/packets/hello
import shimmer/ws/packets/ready
import shimmer/ws/packets/identify
import gleam/map
import gleam/erlang
import gleam/int
import gleam/string
import shimmer/handlers.{Handlers}

pub type Message {
  /// Frames from Gun
  WebsocketFrame(websocket.Frame)
  /// Heartbeat Message Only
  Beat
  /// Kill the Actor
  Halt
}

pub type WebsocketMeta {
  WebsocketMeta(token: String, intents: Int, handlers: Handlers)
}

pub type ActorState {
  ActorState(
    heartbeat_interval: Int,
    sequence: Int,
    conn: Connection,
    meta: WebsocketMeta,
    selector: Selector(Message),
    subject: Subject(Message),
  )
}

pub fn actor_setup(client: Client) -> fn() -> InitResult(ActorState, Message) {
  fn() {
    let setup = fn(inner_client: Client) {
      // 1. Fetch Websocket URL for Bot
      try gateway_settings =
        endpoints.bot_gateway(inner_client.token)
        |> result.replace_error(actor.Failed(
          "Couldn't get bot gateway information",
        ))

      let url = uri.parse(gateway_settings.url)

      // 2. Open Websocket
      try conn =
        websocket.connect(url.host, "/?v=10&encoding=etf", 443, [])
        |> result.replace_error(actor.Failed("Failed to open websocket"))

      let to_self_subject = process.new_subject()
      let selector =
        process.new_selector()
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
            handlers: inner_client.handlers,
          ),
          selector: selector,
          subject: to_self_subject,
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

pub fn actor_loop(msg: Message, state: ActorState) -> Next(ActorState) {
  case msg {
    WebsocketFrame(websocket.Binary(etf_bitstring)) -> {
      let dynamic_payload = parse_etf(etf_bitstring)
      case packet.from_dynamic(dynamic_payload) {
        Ok(#(0, seq, Some("READY"), Some(data))) ->
          case ready.from_map(data) {
            Ok(packet) -> {
              state.meta.handlers.on_ready(packet)
              actor.Continue(update_state(seq, state))
            }
            _ ->
              // TODO handle errors better!
              actor.Continue(update_state(seq, state))
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
                  intents: state.meta.intents,
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
            _ ->
              // TODO handle errors better!
              actor.Continue(update_state(seq, state))
          }
        // Heartbeat Ack
        Ok(#(11, seq, _, _)) -> {
          state.meta.handlers.on_heartbeat_ack()
          actor.Continue(update_state(seq, state))
        }
        _ ->
          // TODO handle errors better!
          actor.Continue(state)
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
      actor.Stop(process.Abnormal(message))
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
      actor.Stop(process.Abnormal("Heartbeat actor recieved unknown message"))
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
