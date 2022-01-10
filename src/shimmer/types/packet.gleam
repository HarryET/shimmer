import gleam/option.{None, Option, Some}
import shimmer/internal/error
import gleam/json
import gleam/dynamic
import gleam/result

pub type Packet {
  Packet(op: Int, s: Option(Int), t: Option(String), d: Option(dynamic.Dynamic))
}

pub fn from_json_string(encoded: String) -> Result(Packet, error.ShimmerError) {
  try data =
    json.decode(encoded)
    |> result.map_error(error.InvalidJson)

  let data = dynamic.from(data)
  try packet =
    {
      try op_code = dynamic.field(data, "op")
      try op_code = dynamic.int(op_code)

      let sequence = case dynamic.field(data, "s") {
        Ok(seq) ->
          case dynamic.int(seq) {
            Ok(seq) -> Some(seq)
            Error(error) -> None
          }
        Error(error) -> None
      }

      let name = case dynamic.field(data, "t") {
        Ok(t) ->
          case dynamic.string(t) {
            Ok(t) -> Some(t)
            Error(error) -> None
          }
        Error(error) -> None
      }

      let data = case dynamic.field(data, "d") {
        Ok(d) -> Some(d)
        Error(error) -> None
      }

      Ok(Packet(op: op_code, s: sequence, t: name, d: data))
    }
    |> result.map_error(error.InvalidFormat)

  Ok(packet)
}
