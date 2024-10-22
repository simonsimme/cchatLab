-module(channel).
-export([new_state/1, handle/2]).

-record(channel_st, {
    name,
nickWpids = dict:new()
}).

new_state(Name) ->
    #channel_st{nickWpids = dict:new(), name = Name}.



handle(St = #channel_st{nickWpids = NP}, {join, Nick, Pid}) ->
    case dict:find(Nick, NP) of
        {ok, _} ->
            {reply, {error, user_already_joined, "Already joined " ++ St#channel_st.name}, St};
        _ ->
            NewNP = dict:store(Nick, Pid, NP),
            NewState = St#channel_st{nickWpids = NewNP},
            {reply, ok, NewState}
    end;

handle(St = #channel_st{nickWpids = NP}, {leave, Nick}) ->
    case dict:find(Nick, NP) of
        {ok, _} ->
            NewNickWpids = dict:erase(Nick, NP),
            NewState = St#channel_st{nickWpids = NewNickWpids},
            {reply, ok, NewState};
        error ->
            {reply, {error, user_not_joined, "User not joined1"}, St}
    end;

    handle(St = #channel_st{nickWpids = NP}, {nick_change, OldNick, NewNick}) ->
        case dict:find(OldNick, NP) of
        {ok, Pid} ->
            case dict:find(NewNick, NP) of
                {ok, _} ->
                    {reply, {error, nick_taken, "Nickname already taken"}, St};
                error ->
                    NewNP = dict:erase(OldNick, NP),
                    NewNP2 = dict:store(NewNick, Pid, NewNP),
                    NewState = St#channel_st{nickWpids = NewNP2},
                    {reply, ok, NewState}
            end;
        error ->
            {reply, {error, user_not_found, "User not found"}, St}
    end;


handle(St = #channel_st{nickWpids = NP, name = Name}, {message_send, Channel,Msg, Nick}) ->
case dict:find(Nick, NP) of
    {ok, _} ->
        lists:foreach(fun ({UserNick, Pid}) ->
            case UserNick == Nick of
                true ->
                    ok; % Skip sending the message to the sender
                false ->
                    Data = {request, self(), make_ref(), {message_receive, Name, Nick, Msg}},
                    Pid ! Data,
                 {reply, ok, St}
            end
        end, dict:to_list(NP)),
        {reply, ok, St};

    error ->
        {reply, {error, user_not_joined, "Not a member of channel " ++ Name}, St}
end.

