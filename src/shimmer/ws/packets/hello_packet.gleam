import gleam/json
import gleam/dynamic.{Dynamic}
import gleam/result
import shimmer/internal/error

pub type HelloPacketData {
  HelloPacketData(heartbeat_interval: Int)
}

pub fn from_json_string(
  encoded: String,
) -> Result(HelloPacketData, error.ShimmerError) {
  let decoder = dynamic.field("heartbeat_interval", of: dynamic.int)
  try interval =
    json.decode(encoded, decoder)
    |> result.map_error(error.InvalidJson)
  Ok(HelloPacketData(heartbeat_interval: interval))
}

pub fn from_dynamic(
  data: Dynamic,
) -> Result(HelloPacketData, error.ShimmerError) {
  try interval =
    dynamic.field("heartbeat_internal", of: dynamic.int)(data)
    |> result.map_error(error.InvalidDynamicList)

  Ok(HelloPacketData(heartbeat_interval: interval))
}
