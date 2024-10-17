-module(server).
-export([start/1, stop/1]).

-record(server_st, {
channels = []
}).


start(ServerAtom) ->
    genserver:start(ServerAtom,#server_st{}, fun handle/2).



handle(State, {join, Channel, Nick}) ->
    case lists:member(Channel, State#server_st.channels) of
        true ->
            genserver:request(Channel, {join, Nick}),
            {reply, ok, State};
        false ->
            genserver:start({Channel, channel:new_state(), fun channel:handle/2}),
            genserver:request(Channel, start),
            NewState = #server_st{channels = [Channel | State#server_st.channels]},
            {reply, ok, NewState}
    end;

handle(State, {leave, Channel, Nick}) ->
    case lists:member(Channel, State#server_st.channels) of
        true ->
            genserver:request(Channel, {leave, Nick}),
            {reply, ok, State};
        false ->
            {reply, {error, not_found}, State}
    end.


stop(ServerAtom) ->
genserver:stop(ServerAtom).