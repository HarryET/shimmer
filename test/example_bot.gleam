import gleam/io
import gleam/string
import gleam/erlang/process
import shimmer
import shimmer/handlers.{on_message, on_ready}
import shimmer/intents
import gleam/option

pub fn main(token: String) {
  let handlers =
    handlers.new_builder()
    |> on_ready(fn(data, _client) {
      io.println(
        ["Logged in as ", data.user.username, " (", data.user.id, ")"]
        |> string.join(with: ""),
      )
    })
    |> on_message(fn(event, _client) {
      let content =
        event.message.content
        |> option.unwrap(or: "nil")

      io.println("New Message: " <> content)
      Nil
    })

  let _client =
    shimmer.new_sharded_with_opts(
      token,
      shimmer.ClientOptions(intents: intents.all()),
    )
    |> shimmer.connect_sharded(handlers)

  process.sleep_forever()
}
