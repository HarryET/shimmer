import gleeunit
import gleam/erlang/os
import example_bot

pub fn main() {
  case os.get_env("TEST_DISCORD_TOKEN") {
    Ok(token) -> example_bot.main(token)
    Error(_) -> gleeunit.main()
  }
}
