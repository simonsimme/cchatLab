-module(server).
-export([start/1, stop/1]).

-record(server_st, {
nicks = []
}).


start(ServerAtom) ->
    genserver:start(ServerAtom,#server_st{}, fun handle/2).



handle(State, {join, Channel, Nick}) ->
    case whereis(Channel) of
        {ok, Pid} ->
            genserver:request(Channel, {join, Nick}),
            {reply, ok, State};
        error ->
            genserver:start({Channel, channel:new_state(), fun channel:handle/2}),
            genserver:request(Channel, start),
            {reply, ok, State}
    end;

handle(State, {leave, Channel, Nick}) ->
    case whereis(Channel) of
        {ok, Pid} ->
            genserver:request(Channel, {leave, Nick}),
            {reply, ok, State};
        error ->
            {reply, {error, not_found}, State}
    end.


stop(ServerAtom) ->
genserver:stop(ServerAtom).