import shimmer/internal/error
import shimmer/ws/event_loop
import gleam/otp/actor.{Spec}
import shimmer/client.{Client}
import gleam/result

/// Opens a websocket connection to the Discord Gateway. Passes this off to an actor to listen to messages.
pub fn connect(client: Client) -> Result(String, error.ShimmerError) {
  let actor_spec =
    Spec(
      init: event_loop.ws_actor_setup(client),
      // 30 seconds
      init_timeout: 30 * 1000,
      loop: event_loop.ws_actor_loop,
    )

  try _ =
    actor.start_spec(actor_spec)
    |> result.map_error(error.ActorError)

  Ok("ok")
}
