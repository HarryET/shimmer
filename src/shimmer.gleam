import shimmer/ws/event_loop.{IdentifyInfo, websocket_actor}
import shimmer/handlers.{Handlers}

pub type Client {
  Client(token: String, handlers: Handlers, intents: Int)
}

pub fn connect(client: Client) -> Bool {
  let _ = websocket_actor(IdentifyInfo(token: client.token, intents: client.intents))
  True
}
