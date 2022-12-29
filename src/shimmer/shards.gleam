import gleam/erlang/process.{Subject}
import shimmer/client.{Client}

pub type ShardsManager(message) {
  ShardsManager(
    token: String,
    intents: Int,
    to_clients: Subject(message),
    clients: List(Client(message)),
  )
}
