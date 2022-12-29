import gleam/io
import gleam/string
import shimmer
import shimmer.{on_message, on_ready}

pub fn main() {
  let handlers =
    shimmer.handlers_builder()
    |> on_ready(fn(data) {
      io.println(
        ["Logged in as ", data.user.username, " (", data.user.id, ")"]
        |> string.join(with: ""),
      )
    })
    |> on_message(fn(message) { io.print("Message Received!") })

  let client =
    shimmer.new("TOKEN")
    |> shimmer.connect(handlers)

  erlang.sleep_forever()
}
