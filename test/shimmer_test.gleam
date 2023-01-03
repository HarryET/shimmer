import gleeunit
import gleam/erlang/os
import example_bot

pub fn main() {
  case os.get_env("UNIT_TEST") {
    Ok(_) -> gleeunit.main()
    Error(_) -> example_bot.main()
  }
}
