import shimmer/types/user.{User}
import shimmer/http/endpoints
import shimmer/internal/error
import gleam/result

pub type Bot {
  Bot(token: String, account: User)
}

pub fn new_bot(token: String) -> Result(Bot, error.ShimmerError) {
  try me = endpoints.me(token)

  Ok(Bot(token: token, account: me))
}
