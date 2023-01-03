import gleam/dynamic
import gleam/int

pub type Snowflake =
  String

pub fn from_dynamic(
  dyn: dynamic.Dynamic,
) -> Result(Snowflake, List(dynamic.DecodeError)) {
  case dynamic.classify(dyn) {
    "String" -> {
      try str = dynamic.string(dyn)
      Ok(str)
    }
    "Int" -> {
      try num = dynamic.int(dyn)
      Ok(int.to_string(num))
    }
    // Should be a String or Int, this should not happen
    _ -> Error([])
  }
}
