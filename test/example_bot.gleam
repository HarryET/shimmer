import gleam/io
import gleam/string
import gleam/erlang/process
import gleam/erlang/os
import gleam/result
import shimmer
import shimmer/handlers.{on_message, on_ready}
import shimmer/builders/presence_activity_builder
import shimmer/builders/presence_builder
import shimmer/types/presence
import shimmer/intents

pub fn main() {
  let handlers =
    handlers.new_builder()
    |> on_ready(fn(data, client) {
      io.println(
        ["Logged in as ", data.user.username, " (", data.user.id, ")"]
        |> string.join(with: ""),
      )

      assert Ok(presence) =
        presence_builder.new()
        |> presence_builder.add_activity_from_builder(presence_activity_builder.new(
          "with Gleam!",
          presence.Game,
        ))

      let _ =
        client
        |> shimmer.update_client_presence_from_builder(presence)

      Nil
    })
    |> on_message(fn(message, _client) {
      io.debug(message)
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
