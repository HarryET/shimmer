import gleam/json
import gleam/dynamic.{field, int, string}
import gleam/result
import shimmer/internal/error

pub type BotGatewayResponse {
  BotGatewayResponse(url: String, shards: Int)
}

pub fn from_json_string(
  encoded: String,
) -> Result(BotGatewayResponse, error.ShimmerError) {
  let user_decoder =
    dynamic.decode2(
      BotGatewayResponse,
      field("url", of: string),
      field("shards", of: int),
    )

  json.decode(from: encoded, using: user_decoder)
  |> result.map_error(error.InvalidJson)
}
