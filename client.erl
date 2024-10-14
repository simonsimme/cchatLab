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

% Join channel
handle(St = #client_st{server = ServerAtom}, {join, Channel}) ->
    % TODO: Implement this function
    % {reply, ok, St} ;
    Nick = St#client_st.nick,
    {reply, genserver:request(ServerAtom, {join, Channel, Nick}), St} ;
    %{reply, {error, not_implemented, "join not implemented"}, St} ;

% Leave channel
handle(St  = #client_st{server = ServerAtom}, {leave, Channel}) ->
    % TODO: Implement this function
    % {reply, ok, St} ;
    Nick = St#client_st.nick,
    {reply,  genserver:request(ServerAtom,
    {leave, Channel, Nick}), St} ;


% Sending message (from GUI, to channel)
handle(St = #client_st{server = ServerAtom}, {message_send, Channel, Msg}) ->
    % TODO: Implement this function
    % {reply, ok, St} ;
    Nick = St#client_st.nick,

    {reply,  genserver:request(Channel,
    {message_send,Msg,Nick}), St} ;

% This case is only relevant for the distinction assignment!
% Change nick (no check, local only)
handle(St = #client_st{server = ServerAtom, nick = OldNick}, {nick, NewNick}) ->
    {reply, genserver:request(ServerAtom, {nick, St#client_st.nick, NewNick}), St#client_st{nick = NewNick}} ;

% ---------------------------------------------------------------------------
% The cases below do not need to be changed...
% But you should understand how they work!

% Get current nick
handle(St, whoami) ->
    {reply, St#client_st.nick, St} ;

% Incoming message (from channel, to GUI)
handle(St = #client_st{gui = GUI, server = ServerAtom}, {message_receive, Channel, Nick, Msg}) ->
    gen_server:call(GUI, {message_receive, Channel, Nick++"> "++Msg}),
    {reply, {genserver:request(ServerAtom,
   {message_receive,Channel,St#client_st.nick,Msg} 
)}, St} ;

% Quit client via GUI
handle(St, quit) ->
    % Any cleanup should happen here, but this is optional
    {reply, ok, St} ;

% Catch-all for any unhandled requests
handle(St, Data) ->
    {reply, {error, not_implemented, "Client does not handle this command"}, St} .
