# Shimmer

A Gleam library for interacting with the Discord API

> **Warning**
> This Library is pre-alpha and being worked on.

## Talks
- [FOSDEM 2023](https://fosdem.org/2023/schedule/event/beam_gleam_intro/) ([Harry Bairstow](https://github.com/HarryET))

## Basic Example

```
shimmer = "~> 0.0.6"
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
    |> handlers.on_ready(fn(data, _client) {
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
    |> handlers.on_message(fn(message, _client) { io.print("Received: " <> message) })

  let client =
    shimmer.new("TOKEN")
    |> shimmer.connect(handlers)

  process.sleep_forever()
}
```

## Supported Events
- [x] Ready
- [ ] Resumed
- [ ] Channel Create
- [ ] Channel Update
- [ ] Channel Delete
- [ ] Channel Pins Update
- [ ] Guild Create
- [ ] Guild Update
- [ ] Guild Delete
- [ ] Guild Ban Add
- [ ] Guild Ban Remove
- [ ] Guild Emoji Update
- [ ] Guild Integrations Update
- [ ] Guild Member Add
- [ ] Guild Member Remove
- [ ] Guild Member Update
- [ ] Guild Members Chunk
- [ ] Guild Role Create
- [ ] Guild Role Update
- [ ] Guild Role Delete
- [ ] Invite Create
- [ ] Invite Delete
- [x] Message Create
- [ ] Message Update
- [ ] Message Delete
- [ ] Message Delete Bulk
- [ ] Message Reaction Add
- [ ] Message Reaction Remove
- [ ] Message Reaction Remove All
- [ ] Message Reaction Remove Emoji
- [ ] Presence Update
- [ ] Typing Start
- [ ] User Update
- [ ] Voice State Update
- [ ] Voice Server Update
- [ ] Webhooks Update
