import gleam/io
import gleam/option.{None, Option, Some}
import shimmer/types/message.{Message}
import shimmer/internal/error.{ShimmerError}
import nerf/websocket
import nerf/websocket.{Text}

const gateway_host = "wss://gateway.discord.gg"

const gateway_path = "/?v=9&encoding=json"

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
  Client(token: String, handlers: Handlers)
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

pub fn connect(client: Client) -> Result(Nil, ShimmerError) {
  // TODO Need to finish implementation. However, basic connection works.
  todo

  assert Ok(conn) = websocket.connect(gateway_host, gateway_path, 443, [])
  assert Ok(hello_packet_frame) = websocket.receive(conn, 1000)
  assert Text(hello_packet_raw) = hello_packet_frame
  io.print(hello_packet_raw)

  Ok(Nil)
}
