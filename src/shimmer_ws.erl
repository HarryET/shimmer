-module(shimmer_ws).

-export([parse_etf/1]).

parse_etf(BitString) -> erlang:binary_to_term(BitString).
