-module(nerf_ffi).

-export([ws_receive/2, ws_await_upgrade/2, ws_open/2]).

% TODO: make the protocols a param that can be specified in gleam
ws_open(Host, Port) -> gun:open(Host, Port, #{protocols => [http]}).

ws_receive({connection, Ref, Pid}, Timeout)
    when is_reference(Ref) andalso is_pid(Pid) ->
    receive
        {gun_ws, Pid, Ref, close} -> {ok, close};
        {gun_ws, Pid, Ref, {close, _}} -> {ok, close};
        {gun_ws, Pid, Ref, {close, _, _}} -> {ok, close};
        {gun_ws, Pid, Ref, {text, _} = Frame} -> {ok, Frame};
        {gun_ws, Pid, Ref, {binary, _} = Frame} -> {ok, Frame}
    after Timeout ->
      {error, nil}
    end.

ws_await_upgrade({connection, Ref, Pid}, Timeout) 
    when is_reference(Ref) andalso is_pid(Pid) ->
    receive
        {gun_upgrade, Pid, Ref, [<<"websocket">>], _} ->
            {ok, nil};

        {gun_response, Pid, _, _, Status, Headers} ->
            % TODO: return an error
            exit({ws_upgrade_failed, Status, Headers});

        {gun_error, Pid, Ref, Reason} ->
            % TODO: return an error
            exit({ws_upgrade_failed, Reason})

        % TODO: Are other cases required?
    after Timeout ->
        % TODO: return an error
        exit(timeout)
    end.
