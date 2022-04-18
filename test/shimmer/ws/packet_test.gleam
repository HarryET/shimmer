import gleeunit/should
import shimmer/ws/packet

pub fn packet_from_json_test() {
  assert Ok(pac) =
    packet.from_json_string(
      "{\"t\":null,\"s\":null,\"op\":10,\"d\":{\"heartbeat_interval\":41250,\"_trace\":[\"[\\\"gateway-prd-main-ks32\\\",{\\\"micros\\\":0.0}]\"]}}",
    )

  pac.op
  |> should.equal(10)

  Ok("Passed!")
}
