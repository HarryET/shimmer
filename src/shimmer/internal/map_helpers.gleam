import gleam/map
import gleam/dynamic
import shimmer/internal/error
import gleam/erlang/atom
import gleam/result

pub fn dyn_atom(val: String) -> dynamic.Dynamic {
  dynamic.from(atom.create_from_string(val))
}

pub fn get_map_field_safe(
  map: map.Map(a, dynamic.Dynamic),
  key: a,
) -> Result(map.Map(dynamic.Dynamic, dynamic.Dynamic), error.ShimmerError) {
  try dyn =
    map
    |> map.get(key)
    |> result.map_error(error.NilMapEntry)

  try safe =
    dyn
    |> dynamic.map(dynamic.dynamic, dynamic.dynamic)
    |> result.map_error(error.InvalidDynamicList)

  Ok(safe)
}

pub fn get_field_safe(
  map: map.Map(a, dynamic.Dynamic),
  key: a,
  decoder: dynamic.Decoder(c),
) -> Result(c, error.ShimmerError) {
  try dyn =
    map
    |> map.get(key)
    |> result.map_error(error.NilMapEntry)
  try safe =
    dyn
    |> decoder
    |> result.map_error(error.InvalidDynamicList)

  Ok(safe)
}
