import gleam/io
import gleam/string
import gleam/dynamic
import gleam/erlang
import gleam/result
import gleam/option.{None, Option, Some}
import gleam/int
import shimmer/types/message.{Message}
import shimmer/types/hello_event
import shimmer/internal/error.{ShimmerError}
import shimmer/internal/periodic_actor.{periodic_actor}
import nerf/websocket
import nerf/websocket.{Text}

let sequence = 0

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

fn ws_recieve_string(
  timeout: Int,
  conn: websocket.Connection,
) -> Result(String, ShimmerError) {
  try packet_frame =
    websocket.receive(conn, timeout)
    |> result.map_error(error.WebsocketError)
  assert Text(packet_raw) = packet_frame
  Ok(packet_raw)
}

fn ws_recieve_packet(client: Client, timeout: Int, conn: websocket.Connection) {
  case ws_recieve_string(timeout, conn) {
    Ok(packet) -> io.print(packet)
    _ -> io.println("Invalid Packet...")
  }

  ws_recieve_packet(client, conn)
}

pub fn connect(client: Client) -> Result(Nil, ShimmerError) {
  assert Ok(conn) =
    websocket.connect("gateway.discord.gg", "/?v=9&encoding=json", 443, [])

  // TODO move to function
  let identify_payload =
    "{\"op\":2,\"d\":{\"token\":\""
    |> string.append(client.token)
    |> string.append("\",\"intents\":")
    |> string.append(int.to_string(0))
    |> string.append(
      ",\"properties\":{\"$os\":\"macos\",\"$browser\":\"shimmer\",\"$device\":\"shimmer\"}}}",
    )

  websocket.send(conn, identify_payload)

  // Heartbeat every x secconds
  // TODO recieve value from gateway
  periodic_actor(every: 41250, run: fn () {
    let payload =
      string.append("{\"op\": 1, \"d\": ", string.append(int.to_string(seq), "}"))

    io.println("Beat.")
    websocket.send(conn, payload)
  })

  Ok(Nil)
}
