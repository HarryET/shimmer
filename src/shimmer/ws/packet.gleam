import gleam/option.{None, Option, Some}
import shimmer/internal/error
import gleam/dynamic.{Dynamic, dynamic}
import gleam/result
import gleam/map
import shimmer/internal/map_helpers.{dyn_atom, get_field_safe}
import gleam/erlang/atom

pub fn from_dynamic(
  encoded: Dynamic,
) -> Result(
  #(Int, Option(Int), Option(String), Option(map.Map(Dynamic, Dynamic))),
  error.ShimmerError,
) {
  try packet =
    encoded
    |> dynamic.map(dynamic.dynamic, dynamic.dynamic)
    |> result.map_error(error.InvalidDynamicList)

  try op =
    packet
    |> get_field_safe(dyn_atom("op"), dynamic.int)

  try s =
    packet
    |> get_field_safe(dyn_atom("s"), dynamic.optional(dynamic.int))

  try t_atom =
    packet
    |> get_field_safe(dyn_atom("t"), dynamic.optional(atom.from_dynamic))
  let t = case t_atom {
    Some(a) -> Some(atom.to_string(a))
    _ -> None
  }

  try d =
    packet
    |> get_field_safe(
      dyn_atom("d"),
      dynamic.optional(dynamic.map(dynamic.dynamic, dynamic.dynamic)),
    )

  Ok(#(op, s, t, d))
}
