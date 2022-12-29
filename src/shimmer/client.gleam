import gleam/erlang/process.{Subject}

pub type Client(message) {
  Client(token: String, intents: Int, to_self: Subject(message))
}
