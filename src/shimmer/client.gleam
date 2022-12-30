import gleam/erlang/process.{Subject}

pub type Shard(message) {
  Shard(id: Int, total: Int, to_all: Subject(message))
}

pub type Client(message) {
  Client(
    token: String,
    intents: Int,
    to_self: Subject(message),
    shard: Shard(message),
  )
}
