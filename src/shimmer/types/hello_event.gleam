import gleam/json
import gleam/dynamic
import gleam/result
import shimmer/internal/error

pub type HelloEventData {
  HelloEventData(heartbeat_interval: Int)
}

pub type HelloEvent {
  HelloEvent(op: String, d: HelloEventData)
}

pub fn from_json_string(
  encoded: String,
) -> Result(HelloEvent, error.ShimmerError) {
  try data =
    json.decode(encoded)
    |> result.map_error(error.InvalidJson)

  let data = dynamic.from(data)
  try event =
    {
      try op_code = dynamic.field(data, "op")
      try op_code = dynamic.string(op_code)

      // TODO access heatbeat interval from $.d.heartbeat_interval
      Ok(HelloEvent(op: op_code, d: HelloEventData(heartbeat_interval: 41250)))
    }
    |> result.map_error(error.InvalidFormat)

  Ok(event)
}
