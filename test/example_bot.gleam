import gleam/io
import gleam/string
import gleam/erlang/process
import gleam/erlang/os
import gleam/result
import shimmer
import shimmer/handlers.{on_message, on_ready}
import shimmer/intents
import gleam/option

pub fn main() {
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

  let token =
    os.get_env("TEST_DISCORD_TOKEN")
    |> result.unwrap(or: "set.a.token")

  let _client =
    shimmer.new_sharded_with_opts(
      token,
      shimmer.ClientOptions(intents: intents.all()),
    )
    |> shimmer.connect_sharded(handlers)

  process.sleep_forever()
}
