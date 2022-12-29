import gleam/option.{None, Option, Some}
import shimmer/ws/packets/message_create.{MessageCreate}
import shimmer/ws/packets/ready.{ReadyPacket}
import shimmer/client.{Client}

// Types

pub type HandlersBuilder(message) {
  HandlersBuilder(
    /// When the bot is online and ready.
    on_ready: Option(fn(ReadyPacket, Client(message)) -> Nil),
    /// When a new message is recieved.
    on_message: Option(fn(MessageCreate, Client(message)) -> Nil),
    /// Send when the internal heartbeats are acknowlaged by the gateway.
    on_heartbeat_ack: Option(fn(Client(message)) -> Nil),
    /// Called when the gateway connection is closed for any reason. The function is given the close code we recieved from discord.
    on_disconnect: Option(fn(Int, Client(message)) -> Nil),
  )
}

pub type Handlers(message) {
  Handlers(
    on_ready: fn(ReadyPacket, Client(message)) -> Nil,
    on_message: fn(MessageCreate, Client(message)) -> Nil,
    on_heartbeat_ack: fn(Client(message)) -> Nil,
    on_disconnect: fn(Int, Client(message)) -> Nil,
  )
}

// Events

pub fn on_ready(
  builder: HandlersBuilder(message),
  f: fn(ReadyPacket, Client(message)) -> Nil,
) -> HandlersBuilder(message) {
  HandlersBuilder(..builder, on_ready: Some(f))
}

pub fn on_message(
  builder: HandlersBuilder(message),
  f: fn(MessageCreate, Client(message)) -> Nil,
) -> HandlersBuilder(message) {
  HandlersBuilder(..builder, on_message: Some(f))
}

pub fn on_heartbeat_ack(
  builder: HandlersBuilder(message),
  f: fn(Client(message)) -> Nil,
) -> HandlersBuilder(message) {
  HandlersBuilder(..builder, on_heartbeat_ack: Some(f))
}

pub fn on_disconnect(
  builder: HandlersBuilder(message),
  f: fn(Int, Client(message)) -> Nil,
) -> HandlersBuilder(message) {
  HandlersBuilder(..builder, on_disconnect: Some(f))
}

// Utils

pub fn new_builder() -> HandlersBuilder(message) {
  HandlersBuilder(
    on_ready: None,
    on_message: None,
    on_heartbeat_ack: None,
    on_disconnect: None,
  )
}

pub fn handlers_from_builder(
  builder: HandlersBuilder(message),
) -> Handlers(message) {
  Handlers(
    on_ready: builder.on_ready
    |> option.unwrap(or: fn(_, _) { Nil }),
    on_message: builder.on_message
    |> option.unwrap(or: fn(_, _) { Nil }),
    on_heartbeat_ack: builder.on_heartbeat_ack
    |> option.unwrap(or: fn(_) { Nil }),
    on_disconnect: builder.on_disconnect
    |> option.unwrap(or: fn(_, _) { Nil }),
  )
}
