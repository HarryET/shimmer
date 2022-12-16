import shimmer/handlers.{Handlers}

pub type Client {
  Client(token: String, handlers: Handlers, intents: Int)
}
