import shimmer/internal/error
import shimmer/ws/event_loop
import gleam/otp/actor
import gleam/otp/supervisor
import gleam/erlang/process
import shimmer/client.{Client, Shard}
import shimmer/intents.{Intent}
import gleam/result
import shimmer/handlers
import shimmer/types/presence.{Presence}
import shimmer/builders/presence_builder.{PresenceBuilder}
import shimmer/shards.{ShardsManager}
import shimmer/http/endpoints
import shimmer/internal/types/responses/bot_gateway.{BotGatewayResponse}

pub type ClientOptions {
  ClientOptions(intents: List(Intent))
}

/// Create a new client with the defualt setup, reccomended for most users
pub fn new(token: String) -> Client(event_loop.Message) {
  let subject = process.new_subject()

  Client(
    token: token,
    intents: intents.default(),
    to_self: subject,
    shard: Shard(id: 0, total: 1, to_all: subject),
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

/// Create a sharding manager to support larger bots, uses Client under the hood
pub fn new_sharded(token: String) -> ShardsManager(event_loop.Message) {
  ShardsManager(
    token: token,
    intents: intents.default(),
    to_clients: process.new_subject(),
    clients: [],
  )
}

/// Create a new sharding manager with more control over the options, uses Client under the hood
pub fn new_sharded_with_opts(
  token: String,
  opts: ClientOptions,
) -> ShardsManager(event_loop.Message) {
  let default = new_sharded(token)

  ShardsManager(..default, intents: opts.intents)
}

/// Opens a websocket connection to the Discord Gateway. Passes this off to an actor to listen to messages.
pub fn connect(
  client: Client(event_loop.Message),
  handlers_builder: handlers.HandlersBuilder(event_loop.Message),
) -> Result(Client(event_loop.Message), error.ShimmerError) {
  try gateway_settings = endpoints.bot_gateway(client.token)

  let actor_spec =
    actor.Spec(
      init: event_loop.actor_setup(
        client,
        gateway_settings.url,
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

/// Internal function that adds a child to the supervisor tree for each shard
fn add_child(
  shards: ShardsManager(event_loop.Message),
  gateway_settings: BotGatewayResponse,
  client_handlers: handlers.Handlers(event_loop.Message),
  children: supervisor.Children(a),
  current_n: Int,
  max_n: Int,
) -> supervisor.Children(a) {
  children
  |> supervisor.add(supervisor.worker(fn(_name) {
    let actor_spec =
      actor.Spec(
        init: event_loop.actor_setup(
          Client(
            token: shards.token,
            intents: shards.intents,
            to_self: process.new_subject(),
            shard: Shard(id: current_n, total: max_n, to_all: shards.to_clients),
          ),
          gateway_settings.url,
          client_handlers,
        ),
        // 30 seconds
        init_timeout: 30 * 1000,
        loop: event_loop.actor_loop,
      )

    actor.start_spec(actor_spec)
  }))

  let add_more = current_n + 1 > max_n
  case add_more {
    True ->
      add_child(
        shards,
        gateway_settings,
        client_handlers,
        children,
        current_n + 1,
        max_n,
      )
    False -> children
  }
}

/// Opens a sharded websocket connection to the Discord Gateway. Passes this off to an actor to listen to messages.
pub fn connect_sharded(
  shards: ShardsManager(event_loop.Message),
  handlers_builder: handlers.HandlersBuilder(event_loop.Message),
) -> Result(ShardsManager(event_loop.Message), error.ShimmerError) {
  let client_handlers = handlers.handlers_from_builder(handlers_builder)

  try gateway_settings = endpoints.bot_gateway(shards.token)

  let supervisor_spec =
    supervisor.Spec(
      argument: 1,
      frequency_period: 1,
      max_frequency: 5,
      init: fn(children) {
        add_child(
          shards,
          gateway_settings,
          client_handlers,
          children,
          1,
          gateway_settings.shards,
        )
      },
    )

  try _ =
    supervisor.start_spec(supervisor_spec)
    |> result.map_error(error.ActorError)

  Ok(shards)
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

/// Update the presence of every client managed by the shards manager, returns the client to be used for future operations
/// > **Note** you must call `connect` before calling this function and do-not know if it has succeeded
pub fn update_all_shards_presence(
  shards: ShardsManager(event_loop.Message),
  presence: Presence,
) -> ShardsManager(event_loop.Message) {
  shards.to_clients
  |> process.send(event_loop.UpdatePresence(presence))

  shards
}

/// Update the presence of every client managed by the shards manager, returns the client to be used for future operations
/// > **Note** you must call `connect` before calling this function and do-not know if it has succeeded
/// Builds the presence from the builder and calls `update_client_presence`
pub fn update_all_shards_presence_from_builder(
  shards: ShardsManager(event_loop.Message),
  builder: PresenceBuilder,
) -> Result(ShardsManager(event_loop.Message), error.ShimmerError) {
  try built_presence = presence_builder.build(builder)
  Ok(update_all_shards_presence(shards, built_presence))
}
