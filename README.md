# Shimmer

A Gleam library for interacting with the Discord API

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
    |> handlers.handlers_from_builder

  let client =
    shimmer.new("TOKEN", 0, handlers)
    |> shimmer.connect

  erlang.sleep_forever()
}
```

## Notes

- Currently, we bundle [nerf](https://github.com/lpil/nerf), this will be removed once this [pull request](https://github.com/lpil/nerf/pull/1) is merged.
