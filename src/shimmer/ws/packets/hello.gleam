import gleam/map
import gleam/dynamic
import shimmer/internal/map_helpers.{dyn_atom, get_field_safe}
import shimmer/internal/error

pub type HelloPacketData {
  HelloPacketData(heartbeat_interval: Int)
}

pub fn from_map(
  map: map.Map(dynamic.Dynamic, dynamic.Dynamic),
) -> Result(HelloPacketData, error.ShimmerError) {
  try interval =
    map
    |> get_field_safe(dyn_atom("heartbeat_interval"), dynamic.int)

  Ok(HelloPacketData(heartbeat_interval: interval))
}
