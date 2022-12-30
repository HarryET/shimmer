import gleam/erlang/process.{Subject}
import shimmer/intents.{Intent}

pub type Shard(message) {
  Shard(id: Int, total: Int, to_all: Subject(message))
}

pub type Client(message) {
  Client(
    token: String,
    intents: List(Intent),
    to_self: Subject(message),
    shard: Shard(message),
  )
}
