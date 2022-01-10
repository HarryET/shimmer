import gleam/json
import gleam/dynamic.{Dynamic}
import gleam/result
import shimmer/internal/error

pub type HelloEvent {
  HelloEvent(heartbeat_interval: Int)
}

pub fn from_json_string(
  encoded: String,
) -> Result(HelloEvent, error.ShimmerError) {
  try data =
    json.decode(encoded)
    |> result.map_error(error.InvalidJson)

  let data = dynamic.from(data)
  try event = from_dynamic(data)

  Ok(event)
}

pub fn from_dynamic(data: Dynamic) -> Result(HelloEvent, error.ShimmerError) {
  try event =
    {
      try heartbeat_interval = dynamic.field(data, "heartbeat_interval")
      try heartbeat_interval = dynamic.int(heartbeat_interval)
      Ok(HelloEvent(heartbeat_interval: heartbeat_interval))
    }
    |> result.map_error(error.InvalidFormat)

  Ok(event)
}
