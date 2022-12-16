# Shimmer

A Gleam library for interacting with the Discord API

> **Warning**
> This Library is pre-alpha and being worked on.

## Basic Example

```gleam
import gleam/io
import shimmer
import shimmer/handlers

pub fn main() {
  let handlers =
    handlers.new_builder()
    |> handlers.on_ready(fn() { io.print("Ready") })
    |> handlers.on_message(fn(message) { io.print("Message Received!") })

  let client =
    shimmer.new("TOKEN", handlers)
    |> shimmer.connect

  erlang.sleep_forever()
}
```
