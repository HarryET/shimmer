import gleam/io
import gleam/string
import gleam/erlang/process
import shimmer
import shimmer/handlers.{on_message, on_ready}

pub fn main() {
  let handlers =
    handlers.new_builder()
    |> on_ready(fn(data, _client) {
      io.println(
        ["Logged in as ", data.user.username, " (", data.user.id, ")"]
        |> string.join(with: ""),
      )
    })
    |> on_message(fn(_message, _client) { io.print("Message Received!") })

  let _client =
    shimmer.new("TOKEN")
    |> shimmer.connect(handlers)

  process.sleep_forever()
}
