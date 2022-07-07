import gleam/option.{None, Option, Some}
import shimmer/types/message.{Message}

// Types

pub type HandlersBuilder {
  HandlersBuilder(
    on_ready: Option(fn() -> Nil),
    on_message: Option(fn(Message) -> Nil),
    on_heartbeat_ack: Option(fn() -> Nil),
  )
}

pub type Handlers {
  Handlers(on_ready: fn() -> Nil, on_message: fn(Message) -> Nil, on_heartbeat_ack: fn() -> Nil,)
}

// Events

pub fn on_ready(builder: HandlersBuilder, f: fn() -> Nil) -> HandlersBuilder {
  HandlersBuilder(..builder, on_ready: Some(f))
}

pub fn on_message(
  builder: HandlersBuilder,
  f: fn(Message) -> Nil,
) -> HandlersBuilder {
  HandlersBuilder(..builder, on_message: Some(f))
}

pub fn on_heartbeat_ack(builder: HandlersBuilder, f: fn() -> Nil) -> HandlersBuilder {
  HandlersBuilder(..builder, on_heartbeat_ack: Some(f))
}

// Utils

pub fn new_builder() -> HandlersBuilder {
  HandlersBuilder(on_ready: None, on_message: None, on_heartbeat_ack: None)
}

pub fn handlers_from_builder(builder: HandlersBuilder) -> Handlers {
  Handlers(
    on_ready: builder.on_ready
    |> option.unwrap(or: fn() { Nil }),
    on_message: builder.on_message
    |> option.unwrap(or: fn(_) { Nil }),
    on_heartbeat_ack: builder.on_heartbeat_ack
    |> option.unwrap(or: fn() { Nil }),
  )
}
