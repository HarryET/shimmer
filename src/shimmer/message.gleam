import shimmer/client.{Client}
import shimmer/snowflake.{Snowflake}
import shimmer/ws/event_loop
import shimmer/http/endpoints
import shimmer/internal/error.{ShimmerError}

pub fn send(
  client: Client(event_loop.Message),
  content: String,
  channel_id: Snowflake,
) -> Result(Bool, ShimmerError) {
  endpoints.send_message(client.token, channel_id, content)
}
