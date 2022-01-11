import gleam/json
import gleam/dynamic.{Dynamic}
import gleam/result
import shimmer/internal/error
import shimmer/types/user.{User}

pub type ReadyPacketData {
  ReadyPacketData(user: User)
}

pub fn from_dynamic(
  data: Dynamic,
) -> Result(ReadyPacketData, error.ShimmerError) {
  try user_raw =
    dynamic.field("user", of: dynamic.string)(data)
    |> result.map_error(error.InvalidDynamicList)

  try user = user.from_json_string(user_raw)

  Ok(ReadyPacketData(user: user))
}
