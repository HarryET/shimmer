import gleam/option.{None, Option, Some}
import shimmer/internal/error

pub type Packet {
  Packet(op: Int, s: Option(Int), t: Option(String), d: Option(Dynamic))
}

pub fn from_json_string(encoded: String) -> Result(Packet, error.ShimmerError) {
  try data =
    json.decode(encoded)
    |> result.map_error(error.InvalidJson)

  let data = dynamic.from(data)
  try packet =
    {
      try op_code = dynamic.field(data, "op")
      try op_code = dynamic.string(op_code)

      let sequence = option.from_result(dynamic.field(data, "s"))
      let name = option.from_result(dynamic.field(data, "t"))
      let data = option.from_result(dynamic.field(data, "d"))

      Ok(Packet(op: op_code, s: sequence, t: name, d: data))
    }
    |> result.map_error(error.InvalidFormat)

  Ok(packet)
}
