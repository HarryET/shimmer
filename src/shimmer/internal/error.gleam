import gleam/json
import gleam/dynamic
import gleam/hackney
import gleam/otp/actor

pub type ShimmerError {
  UnknownAccount
  EmptyOptionWhenRequired
  InvalidJson(json.DecodeError)
  InvalidDynamicList(List(dynamic.DecodeError))
  InvalidFormat(dynamic.DecodeError)
  WebsocketError(Nil)
  HttpError(hackney.Error)
  ActorError(actor.StartError)
  NilMapEntry(Nil)
}
