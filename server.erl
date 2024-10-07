-module(server).
-export([start/1, stop/1]).

-record(server_st, {
chanels = dict:new(), % channel, list of nicknames in the channel
nicks = []
}).


start(ServerAtom) ->
    genserver:start(ServerAtom,#server_st{}, fun handle/2).
    

handle (State, {join,Channel,Nick}) ->  
    NewState = State#server_st{chanels = [Channel,Nick|State#server_st.chanels], nicks = [Nick|State#server_st.nicks]},
    {reply, ok, NewState};

handle (State, {leave,Channel,Nick}) ->
    NewState = State#server_st{chanels = dict:update(Channel, fun (List1) -> lists:delete(Nick, List1) end,State#server_st.chanels)},
    {reply, ok, NewState};

handle (State, {message_send, Channel, Msg, Nick}) ->
    case dict:find(Channel, State#server_st.chanels) of
        {ok, Pid} -> Pid ! {message, Msg, Nick};
        error -> ok
    end,
    
    {reply, ok, State}.

stop(ServerAtom) ->
    genserver:stop(ServerAtom).