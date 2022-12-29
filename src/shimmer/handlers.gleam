import gleam/option.{None, Option, Some}
import shimmer/types/message.{Message}
import shimmer/ws/packets/ready.{ReadyPacket}

// Types

pub type HandlersBuilder {
  HandlersBuilder(
    /// When the bot is online and ready.
    on_ready: Option(fn(ReadyPacket) -> Nil),
    /// When a new message is recieved.
    on_message: Option(fn(Message) -> Nil),
    /// Send when the internal heartbeats are acknowlaged by the gateway.
    on_heartbeat_ack: Option(fn() -> Nil),
    /// Called when the gateway connection is closed for any reason. The function is given the close code we recieved from discord.
    on_disconnect: Option(fn(Int) -> Nil),
  )
}

pub type Handlers {
  Handlers(
    on_ready: fn(ReadyPacket) -> Nil,
    on_message: fn(Message) -> Nil,
    on_heartbeat_ack: fn() -> Nil,
    on_disconnect: fn(Int) -> Nil,
  )
}

// Events

pub fn on_ready(
  builder: HandlersBuilder,
  f: fn(ReadyPacket) -> Nil,
) -> HandlersBuilder {
  HandlersBuilder(..builder, on_ready: Some(f))
}

pub fn on_message(
  builder: HandlersBuilder,
  f: fn(Message) -> Nil,
) -> HandlersBuilder {
  HandlersBuilder(..builder, on_message: Some(f))
}

pub fn on_heartbeat_ack(
  builder: HandlersBuilder,
  f: fn() -> Nil,
) -> HandlersBuilder {
  HandlersBuilder(..builder, on_heartbeat_ack: Some(f))
}

pub fn on_disconnect(
  builder: HandlersBuilder,
  f: fn(Int) -> Nil,
) -> HandlersBuilder {
  HandlersBuilder(..builder, on_disconnect: Some(f))
}

// Utils

pub fn new_builder() -> HandlersBuilder {
  HandlersBuilder(
    on_ready: None,
    on_message: None,
    on_heartbeat_ack: None,
    on_disconnect: None,
  )
}

pub fn handlers_from_builder(builder: HandlersBuilder) -> Handlers {
  Handlers(
    on_ready: builder.on_ready
    |> option.unwrap(or: fn(_) { Nil }),
    on_message: builder.on_message
    |> option.unwrap(or: fn(_) { Nil }),
    on_heartbeat_ack: builder.on_heartbeat_ack
    |> option.unwrap(or: fn() { Nil }),
    on_disconnect: builder.on_disconnect
    |> option.unwrap(or: fn(_) { Nil }),
  )
}
