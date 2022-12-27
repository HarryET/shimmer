import shimmer/handlers.{Handlers}
import gleam/erlang/process.{Subject}

pub type Client(message) {
  Client(
    token: String,
    handlers: Handlers,
    intents: Int,
    to_self: Subject(message),
  )
}
