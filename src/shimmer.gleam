import gleam/io
import gleam/erlang
import gleam/option.{None, Option, Some}
import shimmer/types/message.{Message}
import shimmer/ws/event_loop.{IdentifyInfo, websocket_actor}

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
  Client(token: String, handlers: Handlers, intents: Int)
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

pub fn connect(client: Client) -> Nil {
  let _ =
    websocket_actor(IdentifyInfo(token: client.token, intents: client.intents))
  Nil
}

pub fn main() {
  let handlers =
    handlers_builder()
    |> on_ready(fn() { io.print("Ready") })
    |> on_message(fn(_message) { io.print("Message Received!") })
    |> handlers_from_builder

  let _ =
    Client(token: "", handlers: handlers, intents: 513)
    |> connect

  erlang.sleep_forever()
}
