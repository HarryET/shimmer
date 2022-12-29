import gleam/map
import gleam/dynamic
// import shimmer/internal/map_helpers.{dyn_atom, get_field_safe}
import shimmer/internal/error

pub type Message {
  Message
}

pub fn from_map(
  _map: map.Map(dynamic.Dynamic, dynamic.Dynamic),
) -> Result(Message, error.ShimmerError) {
  Ok(Message)
}
