# Shimmer

A Gleam library for interacting with the Discord API

> **Warning**
> This Library is pre-alpha and being worked on.

## Basic Example

```
shimmer = "~> 0.0.4"
gleam_stdlib = "~> 0.25"
gleam_erlang = "~> 0.17"
```

```gleam
import gleam/io
import gleam/string
import gleam/int
import gleam/erlang/process
import shimmer
import shimmer/handlers

pub fn main() {
  let handlers =
    handlers.new_builder()
    |> handlers.on_ready(fn(data) {
      io.println(
        [
          "Logged in as ",
          data.user.username,
          " (",
          int.to_string(data.user.id),
          ")",
        ]
        |> string.join(with: ""),
      )
    })
    |> handlers.on_message(fn(_message) { io.print("Message Received!") })

  let client =
    shimmer.new("TOKEN", handlers)
    |> shimmer.connect

  process.sleep_forever()
}
```
