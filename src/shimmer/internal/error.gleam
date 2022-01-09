import gleam/json
import gleam/dynamic
import gleam/hackney

pub type ShimmerError {
  UnknownAccount
  InvalidJson(json.DecodeError)
  InvalidFormat(dynamic.DecodeError)
  InvalidWsPacketFormat
  HttpError(hackney.Error)
}
