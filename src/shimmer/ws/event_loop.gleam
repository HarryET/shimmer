import shimmer/internal/network/websocket.{Connection}
import shimmer/client.{Client}
import gleam/otp/actor.{InitResult, Next}
import shimmer/http/endpoints
import shimmer/internal/erl/uri
import gleam/io
import gleam/result
import gleam/erlang/process

pub type WebsocketMeta {
  WebsocketMeta(token: String, intents: Int)
}

pub type ActorState {
  ActorState(
    heartbeat_interval: Int,
    sequence: Int,
    conn: Connection,
    meta: WebsocketMeta,
  )
}

pub fn actor_setup(client: Client) -> fn() -> InitResult(ActorState, msg) {
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

      let selector = process.new_selector()

      Ok(actor.Ready(
        ActorState(
          heartbeat_interval: -1,
          sequence: -1,
          conn: conn,
          meta: WebsocketMeta(
            token: inner_client.token,
            intents: inner_client.intents,
          ),
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

pub fn actor_loop(_msg: msg, state: ActorState) -> Next(ActorState) {
  actor.Continue(state)
}
