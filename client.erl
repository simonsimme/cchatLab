-module(client).
-export([handle/2, initial_state/3]).

% This record defines the structure of the state of a client.
% Add whatever other fields you need.
-record(client_st, {
    gui, % atom of the GUI process
    nick, % nick/username of the client
    server % atom of the chat server
}).

% Return an initial state record. This is called from GUI.
% Do not change the signature of this function.
initial_state(Nick, GUIAtom, ServerAtom) ->
    #client_st{
        gui = GUIAtom,
        nick = Nick,
        server = ServerAtom
    }.

% handle/2 handles each kind of request from GUI
% Parameters:
%   - the current state of the client (St)
%   - request data from GUI
% Must return a tuple {reply, Data, NewState}, where:
%   - Data is what is sent to GUI, either the atom `ok` or a tuple {error, Atom, "Error message"}
%   - NewState is the updated state of the client

error_hand_server(StA, Data) ->
    try
            genserver:request(StA, Data)
       % {reply,genserver:request(St#client_st.server, Data),St}
    catch
        error:E ->
            case E of
                timeout_error ->
                    {error, server_not_reached, "timeout1"};
                badarg ->
                    {error, server_not_reached, "timeout"};
                _ ->
                    {error, E, "not known"}
            end;
        E ->
            case E of
                timeout_error ->
                    {error, server_not_reached, "timeout2"};
                _ ->
                    {error, E, "not known"}   
            end
    end.


% Join channel
handle(St = #client_st{server = ServerAtom}, {join, Channel}) ->
    % TODO: Implement this function
    % {reply, ok, St} ;
    Nick = St#client_st.nick,
    A = error_hand_server(ServerAtom,{join, Channel,Nick, self()}),
    {reply, A, St} ;
    %{reply, {error, not_implemented, "join not implemented"}, St} ;

% Leave channel
handle(St  = #client_st{server = ServerAtom}, {leave, Channel}) ->
    % TODO: Implement this function
    % {reply, ok, St} ;
    Nick = St#client_st.nick,
    A = error_hand_server(list_to_atom(Channel),{leave, Nick} ),
    {reply, A, St};


% Sending message (from GUI, to channel)
handle(St, {message_send, Channel, Msg}) ->
    % TODO: Implement this function
    % {reply, ok, St} ;
    Nick = St#client_st.nick,
    try
case whereis(list_to_atom(Channel)) of
    undefined ->
        {reply, {error, server_not_reached, "Server not reached"}, St};
    Pid when is_pid(Pid) ->
        A = error_hand_server(Pid, {message_send, Channel, Msg, Nick}),
        {reply, A, St}
end
catch
_:E ->
    {reply, {error, E, ""}, St}
end;
 
    

% This case is only relevant for the distinction assignment!
% Change nick (no check, local only)
handle(St = #client_st{server = ServerAtom, nick = OldNick}, {nick, NewNick}) ->
    A = error_hand_server(ServerAtom,{nick, St#client_st.nick, NewNick} ),
    {reply, A, St#client_st{nick = NewNick}} ;

% ---------------------------------------------------------------------------
% The cases below do not need to be changed...
% But you should understand how they work!

% Get current nick
handle(St, whoami) ->
    {reply, St#client_st.nick, St} ;

% Incoming message (from channel, to GUI)
handle(St = #client_st{gui = GUI}, {message_receive, Channel, Nick, Msg}) ->
    gen_server:call(GUI, {message_receive, Channel, Nick++"> "++Msg}),

    {reply,ok,St};

% Quit client via GUI
handle(St, quit) ->
    % Any cleanup should happen here, but this is optional
    {reply, ok, St} ;

% Catch-all for any unhandled requests
handle(St, Data) ->
    {reply, {error, not_implemented, "Client does not handle this command"}, St} .
