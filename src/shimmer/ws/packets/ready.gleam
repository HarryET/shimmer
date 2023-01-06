import shimmer/types/user.{User}
import gleam/map
import gleam/dynamic
import shimmer/internal/map_helpers.{
  dyn_atom, get_field_safe, get_map_field_safe,
}
import shimmer/internal/error

pub type ReadyPacket {
  ReadyPacket(user: User, session_id: String, resume_gateway_url: String)
}

pub fn from_map(
  map: map.Map(dynamic.Dynamic, dynamic.Dynamic),
) -> Result(ReadyPacket, error.ShimmerError) {
  try user_map =
    map
    |> get_map_field_safe(dyn_atom("user"))

  try user =
    user_map
    |> user.from_map(dyn_atom)

  try session_id =
    map
    |> get_field_safe(dyn_atom("session_id"), dynamic.string)

  try resume_gateway_url =
    map
    |> get_field_safe(dyn_atom("resume_gateway_url"), dynamic.string)

  Ok(ReadyPacket(user, session_id, resume_gateway_url))
}
