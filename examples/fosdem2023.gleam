import gleam/io
import gleam/erlang/process
import shimmer
import shimmer/handlers
import shimmer/message

fn message_handler(event, client) {
  let content = event.message.content

  case content {
    "!ping" -> {
      io.println("Pong!")
      message.send(client, "Pong!", event.message.channel_id)
    }
    message -> io.println("Message Received: " <> message)
  }
}

fn ready_handler(event, _client) {
  let id = event.user.id

  io.println("Logged in as " <> id)
}

pub fn main() {
  let handlers =
    handlers.new_builder()
    |> handlers.on_ready(ready_handler)
    |> handlers.on_message(message_handler)

  let client =
    shimmer.new("TOKEN")
    |> shimmer.connect(handlers)

  process.sleep_forever()
}
