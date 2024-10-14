-module(channel).
-export([new_state/0, handle/2]).

-record(channel_st, {
nicks = []
}).

new_state() ->
    #channel_st{nicks = []}.


handle(St, start) ->
    {reply, ok, St};

handle(St, stop) ->
    {reply, ok, St};

handle(St = #channel_st{nicks = Nicks}, {join, Nick}) ->
    NewState = St#channel_st{nicks = [Nick | St#channel_st.nicks]},
    {reply, ok, NewState};

handle(St = #channel_st{nicks = Nicks}, {leave, Nick}) ->
       lists:delete(Nick, St#channel_st.nicks),
        {reply, ok, St};

handle(St = #channel_st{nicks = Nicks}, {message_send, Msg, Nick}) ->
    lists:foreach(fun (Nick) ->
        io:format("sent to every User")
    end, Nicks),
    {reply , ok, St}.
    
    
