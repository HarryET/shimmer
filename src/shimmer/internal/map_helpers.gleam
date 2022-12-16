import gleam/map
import gleam/dynamic
import shimmer/internal/error
import gleam/erlang/atom
import gleam/result

pub fn dyn_atom(val: String) -> dynamic.Dynamic {
  dynamic.from(atom.create_from_string(val))
}

pub fn get_field_safe(
  map: map.Map(a, b),
  key: a,
  mapper: fn(b) -> Result(c, List(dynamic.DecodeError)),
) -> Result(c, error.ShimmerError) {
  try dyn =
    map
    |> map.get(key)
    |> result.map_error(error.NilMapEntry)
  try safe =
    dyn
    |> mapper
    |> result.map_error(error.InvalidDynamicList)

  Ok(safe)
}
