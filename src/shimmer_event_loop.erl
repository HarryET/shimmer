-module(shimmer_event_loop).

-behaviour(gen_server).

% Public API
-export([start_link/1]).

% Private API
-export([init/1, handle_call/3, handle_cast/2, handle_info/2]).

-record(state, {gleam_state, handle_message}).

% Start the gen_server process
start_link(Spec) ->
    gen_server:start_link(?MODULE, Spec, []).

init({spec, Init, HandleMessage}) ->
    {ok, #state{
        gleam_state = Init(),
        handle_message = HandleMessage
    }}.

handle_call(_Msg, _From, State) ->
    {noreply, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(Msg, State) ->
    #state{gleam_state = GleamState, handle_message = HandleMessage} = State,
    NewGleamState = case Msg of
        heartbeat_now ->
            HandleMessage(Msg, GleamState);

        {gun_ws, _Pid, _Ref, {text, Text}} ->
            HandleMessage({frame, Text}, GleamState);

        _ -> 
            error({unexpected_event_loop_message, Msg})
    end,
    {noreply, State#state{gleam_state = NewGleamState}}.
