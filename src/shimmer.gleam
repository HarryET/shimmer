import shimmer/internal/error
import shimmer/ws/event_loop
import gleam/otp/actor.{Spec}
import gleam/erlang/process
import shimmer/client.{Client}
import gleam/result
import shimmer/handlers
import shimmer/types/presence.{Presence}
import shimmer/builders/presence_builder.{PresenceBuilder}

pub type ClientOptions {
  ClientOptions(intents: Int)
}

/// Create a new client with the defualt setup, reccomended for most users
pub fn new(token: String) -> Client(event_loop.Message) {
  Client(
    token: token,
    // Default intents, all un-privalidged events
    intents: 3_243_773,
    to_self: process.new_subject(),
  )
}

/// Create a new Shimmer Client with more control over the options
pub fn new_with_opts(
  token: String,
  opts: ClientOptions,
) -> Client(event_loop.Message) {
  let default = new(token)

  Client(..default, intents: opts.intents)
}

/// Opens a websocket connection to the Discord Gateway. Passes this off to an actor to listen to messages.
pub fn connect(
  client: Client(event_loop.Message),
  handlers_builder: handlers.HandlersBuilder(event_loop.Message),
) -> Result(Client(event_loop.Message), error.ShimmerError) {
  let actor_spec =
    Spec(
      init: event_loop.actor_setup(
        client,
        handlers.handlers_from_builder(handlers_builder),
      ),
      // 30 seconds
      init_timeout: 30 * 1000,
      loop: event_loop.actor_loop,
    )

  try _ =
    actor.start_spec(actor_spec)
    |> result.map_error(error.ActorError)

  Ok(client)
}

/// Update the presence of the client, returns the client to be used for future operations
/// > **Note** you must call `connect` before calling this function and do-not know if it has succeeded
pub fn update_client_presence(
  client: Client(event_loop.Message),
  presence: Presence,
) -> Client(event_loop.Message) {
  client.to_self
  |> process.send(event_loop.UpdatePresence(presence))

  client
}

/// Update the presence of the client, returns the client to be used for future operations
/// > **Note** you must call `connect` before calling this function and do-not know if it has succeeded
/// Builds the presence from the builder and calls `update_client_presence`
pub fn update_client_presence_from_builder(
  client: Client(event_loop.Message),
  builder: PresenceBuilder,
) -> Result(Client(event_loop.Message), error.ShimmerError) {
  try built_presence = presence_builder.build(builder)
  Ok(update_client_presence(client, built_presence))
}
