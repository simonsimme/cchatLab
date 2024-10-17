-module(channel).
-export([new_state/0, handle/2]).

-record(channel_st, {
nickWpids = dict:new()
}).

new_state() ->
    #channel_st{nickWpids = dict:new()}.


handle(St, start) ->
    {reply, ok, St};

handle(St, stop) ->
    {reply, ok, St};

handle(St = #channel_st{nickWpids = NP}, {join, Nick, Pid}) ->
    NewNP = dict:store(Nick,Pid, NP),
    NewState = St#channel_st{nickWpids = NewNP},
    {reply, ok, NewState};

handle(St = #channel_st{nickWpids = NP}, {leave, Nick}) ->
        NewNickWpids = dict:erase(Nick, NP),
        NewState = St#channel_st{nickWpids = NewNickWpids},
        {reply, ok, NewState};

handle(St = #channel_st{nickWpids = NP}, {message_send, Msg, Nick}) ->
    lists:foreach(fun (Nick,Pid) ->
        genserver:request(Pid,{message_receive,self(),Nick,Msg})
    end, dict:to_list(NP)),
    {reply , ok, St}.
    
    
