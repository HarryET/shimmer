import gleam/option.{Option}
import shimmer/internal/error
import gleam/json
import gleam/dynamic.{dynamic, field, int, optional, string}
import gleam/result

pub type Packet {
  Packet(op: Int, s: Option(Int), t: Option(String), d: Option(dynamic.Dynamic))
}

pub fn from_json_string(encoded: String) -> Result(Packet, error.ShimmerError) {
  let packet_decoded =
    dynamic.decode4(
      Packet,
      field("op", of: int),
      field("s", of: optional(int)),
      field("t", of: optional(string)),
      field("d", of: optional(dynamic)),
    )

  json.decode(from: encoded, using: packet_decoded)
  |> result.map_error(error.InvalidJson)
}
// pub fn from_json_string(encoded: String) -> Result(Packet, error.ShimmerError) {
//   try data =
//     json.decode(encoded)
//     |> result.map_error(error.InvalidJson)
//   let data = dynamic.from(data)
//   try packet =
//     {
//       try op_code = dynamic.field(data, "op")
//       try op_code = dynamic.int(op_code)
//       let sequence = case dynamic.field(data, "s") {
//         Ok(seq) ->
//           case dynamic.int(seq) {
//             Ok(seq) -> Some(seq)
//             Error(_error) -> None
//           }
//         Error(_error) -> None
//       }
//       let name = case dynamic.field(data, "t") {
//         Ok(t) ->
//           case dynamic.string(t) {
//             Ok(t) -> Some(t)
//             Error(_error) -> None
//           }
//         Error(_error) -> None
//       }
//       let data = case dynamic.field(data, "d") {
//         Ok(d) -> Some(d)
//         Error(_error) -> None
//       }
//       Ok(Packet(op: op_code, s: sequence, t: name, d: data))
//     }
//     |> result.map_error(error.InvalidFormat)
//   Ok(packet)
// }
