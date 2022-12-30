import gleam/erlang/process.{Subject}
import shimmer/client.{Client}
import shimmer/intents.{Intent}

pub type ShardsManager(message) {
  ShardsManager(
    token: String,
    intents: List(Intent),
    to_clients: Subject(message),
    clients: List(Client(message)),
  )
}
