import gleam/json
import gleam/dynamic

pub type ShimmerError {
  UnknownAccount
  InvalidJson(json.DecodeError)
  InvalidFormat(dynamic.DecodeError)
}