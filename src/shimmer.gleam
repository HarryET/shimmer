import gleam/io
import gleam/string
import gleam/dynamic
import gleam/erlang
import gleam/result
import gleam/option.{None, Option, Some}
import gleam/int
import gleam/otp/process
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
  assert Ok(_) =
    websocket_actor(IdentifyInfo(token: client.token, intents: client.intents))
  Nil
}

pub fn main() {
  let handlers =
    handlers_builder()
    |> on_ready(fn() { io.print("Ready") })
    |> handlers_from_builder

  Client(
    token: "OTI5MzU5MDY5NjQ1NTI1MDAy.YdmLFA._2_x99OB1yfqxvvY8DSzoNMJp_Q",
    intents: 0,
    handlers: handlers,
  )
  |> connect

  erlang.sleep_forever()
}
