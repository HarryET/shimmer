import gleam/io
import gleam/string
import gleam/dynamic
import gleam/erlang
import gleam/result
import gleam/option.{None, Option, Some}
import gleam/int
import gleam/otp/process
import shimmer/types/message.{Message}
import shimmer/ws/event_loop.{websocket_actor}
import shimmer/ws/ws_utils.{open_gateway}

pub type HandlersBuilder {
  HandlersBuilder(
    on_ready: Option(fn() -> Nil),
    on_message: Option(fn(Message) -> Nil),
  )
}

pub type Handlers {
  Handlers(on_ready: fn() -> Nil, on_message: fn(Message) -> Nil)
}

pub type Client {
  Client(token: String, handlers: Handlers, sequence: Int, intents: Int)
}

pub fn new(token: String, intents: Int, handlers: Handlers) -> Client {
  Client(token: token, handlers: handlers, sequence: 0, intents: intents)
}

pub fn handlers_builder() -> HandlersBuilder {
  HandlersBuilder(on_ready: None, on_message: None)
}

pub fn on_ready(builder: HandlersBuilder, f: fn() -> Nil) -> HandlersBuilder {
  HandlersBuilder(..builder, on_ready: Some(f))
}

pub fn on_message(
  builder: HandlersBuilder,
  f: fn(Message) -> Nil,
) -> HandlersBuilder {
  HandlersBuilder(..builder, on_message: Some(f))
}

pub fn handlers_from_builder(builder: HandlersBuilder) -> Handlers {
  Handlers(
    on_ready: builder.on_ready
    |> option.unwrap(or: fn() { Nil }),
    on_message: builder.on_message
    |> option.unwrap(or: fn(_) { Nil }),
  )
}

pub fn connect(_client: Client) -> Nil {
  websocket_actor()
  Nil
}

pub fn main() {
  let handlers =
    handlers_builder()
    |> on_ready(fn() { io.print("Ready") })
    |> on_message(fn(message) { Nil })
    |> handlers_from_builder

  new("TOKEN", 0, handlers)
  |> connect

  erlang.sleep_forever()
}
