import gleam/io
import gleam/erlang
import gleam/option.{None, Option, Some}
import shimmer/types/message.{Message}
import shimmer/ws/event_loop.{IdentifyInfo, websocket_actor}

pub type Client {
  Client(token: String, handlers: Handlers, intents: Int)
}

pub fn connect(client: Client) -> Bool {
  let _ = websocket_actor(IdentifyInfo(token: client.token, intents: client.intents), client.handlers)
  True
}
