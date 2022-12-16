pub type UriMap {
  UriMap(host: String, scheme: String, path: String, query: String)
}

pub external fn parse(uri: String) -> UriMap =
  "uri_ffi" "parse"
