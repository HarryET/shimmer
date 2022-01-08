import gleam/io
import shimmer
import shimmer.{connect, on_message, on_ready}

pub fn main() {
  let handlers =
    shimmer.handlers_builder()
    |> on_ready(fn() { io.print("Ready") })
    |> on_message(fn(message) { io.print("Message Recieved!") })
    |> shimmer.handlers_from_builder

  let client =
    shimmer.Client(token: "<TOKEN>", handlers: handlers)
    |> connect()
}
