-module(server).
-export([start/1, stop/1]).

-record(server_st, {
channels = []
}).


start(ServerAtom) ->
    genserver:start(ServerAtom,#server_st{}, fun handle/2).



handle(State, {join, Channel, Nick,Pid}) ->
    case lists:member(Channel, State#server_st.channels) of
        true ->
             
             Resp = genserver:request(list_to_atom(Channel), {join, Nick,Pid}),
             NewState = #server_st{channels = [Channel | State#server_st.channels]},
               {reply, Resp, NewState};
        false ->
            genserver:start(list_to_atom(Channel), channel:new_state(Channel), fun channel:handle/2),
           % genserver:start(list_to_atom(Channel), channel:state, fun yrdy/2),
            NewState = #server_st{channels = [Channel | State#server_st.channels]},
            genserver:request(list_to_atom(Channel), {join, Nick,Pid}),
            {reply, ok, NewState};
        error ->
            {reply, {error, server_not_reached,"E"}, State}
            
    end;
handle(State, delete_all_channels) ->
    lists:foreach(
        fun(Ch) -> genserver:stop(list_to_atom(Ch)) end,  % Stop each channel process
        State#server_st.channels
    ),
    {reply, ok, State#server_st{ channels = []}};

handle(State, {leave, Channel, Nick}) ->
    
    case lists:member(Channel, State#server_st.channels) of
        true ->
            Resp = genserver:request(list_to_atom(Channel), {leave, Nick}),
            List = lists:delete(Channel, State#server_st.channels),
            NewState = #server_st{channels = List},
            {reply, Resp, NewState};
        false ->
            {reply, {error, user_not_joined, "Not Joined"}, State}
    end.


stop(ServerAtom) ->
genserver:request(ServerAtom, delete_all_channels), 
genserver:stop(ServerAtom).

    
