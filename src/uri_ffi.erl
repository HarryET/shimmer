-module(uri_ffi).

-export([parse/1]).
-record(url, {host, port, path}).

parse(Url) ->
    Uri = uri_string:parse(Url),
    #url{host=maps:get(host, Uri, nil), port=maps:get(port, Uri, nil), path=maps:get(path, Uri, nil)}.
