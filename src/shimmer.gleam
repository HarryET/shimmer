import shimmer/internal/error
import shimmer/ws/event_loop
import gleam/otp/actor.{Spec}
import shimmer/client.{Client}
import gleam/result
import shimmer/handlers

pub type ClientOptions {
  ClientOptions(intents: Int)
}

/// Create a new client with the defualt setup, reccomended for most users
pub fn new(token: String, handler_builder: handlers.HandlersBuilder) -> Client {
  Client(
    token: token,
    handlers: handler_builder
    |> handlers.handlers_from_builder,
    // Default intents, all un-privalidged events
    intents: 3243773,
  )
}

/// Create a new Shimmer Client with more control over the options
pub fn new_with_opts(
  token: String,
  handler_builder: handlers.HandlersBuilder,
  opts: ClientOptions,
) -> Client {
  Client(
    token: token,
    handlers: handler_builder
    |> handlers.handlers_from_builder,
    intents: opts.intents,
  )
}

/// Opens a websocket connection to the Discord Gateway. Passes this off to an actor to listen to messages.
pub fn connect(client: Client) -> Result(Bool, error.ShimmerError) {
  let actor_spec =
    Spec(
      init: event_loop.actor_setup(client),
      // 30 seconds
      init_timeout: 30 * 1000,
      loop: event_loop.actor_loop,
    )

  try _ =
    actor.start_spec(actor_spec)
    |> result.map_error(error.ActorError)

  Ok(True)
}
