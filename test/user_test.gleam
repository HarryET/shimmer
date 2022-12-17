import gleeunit/should
import shimmer/types/user

pub fn user_from_json_test() {
  try decoded_user =
    user.from_json_string(
      "{\"id\":\"929359069645525002\",\"username\":\"Running on Gleam\",\"avatar\":\"67d6a33c194f0bd2d03c97ac1c03b0d9\",\"discriminator\":\"9900\",\"public_flags\":0,\"flags\":0,\"bot\":true,\"banner\":null,\"banner_color\":null,\"accent_color\":null,\"bio\":\"\"}",
    )
  decoded_user.id
  |> should.equal(929359069645525002)
  decoded_user.username
  |> should.equal("Running on Gleam")

  Ok("Passed!")
}
