//// Based upon github.com/lpil/nerf

import gleam/http.{Header}
import gleam/erlang/charlist.{Charlist}
import gleam/dynamic.{Dynamic}

pub external type StreamReference

pub external type ConnectionPid

pub fn open(host: String, port: Int) -> Result(ConnectionPid, Dynamic) {
  open_erl(charlist.from_string(host), port)
}

pub external fn open_erl(Charlist, Int) -> Result(ConnectionPid, Dynamic) =
  "shimmer_net" "ws_open"

pub external fn await_up(ConnectionPid) -> Result(Dynamic, Dynamic) =
  "gun" "await_up"

pub external fn ws_upgrade(
  ConnectionPid,
  String,
  List(Header),
) -> StreamReference =
  "gun" "ws_upgrade"

pub type Frame {
  Close
  Text(String)
  Binary(BitString)
}

external type OkAtom

external fn ws_send_erl(ConnectionPid, Frame) -> OkAtom =
  "gun" "ws_send"

pub fn ws_send(pid: ConnectionPid, frame: Frame) -> Nil {
  ws_send_erl(pid, frame)
  Nil
}
