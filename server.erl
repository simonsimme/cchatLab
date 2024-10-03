-module(server).
-export([start/1,stop/1]).

% Start a new server process with the given name
% Do not change the signature of this function.
%start comand server:start/1

    % TODO Implement function
    % - Spawn a new process which waits for a message, handles it, then loops infinitely
    % - Register this process to ServerAtom
    % - Return the process ID
start(ServerAtom) ->
    Handler = fun(State, Request) -> % Define your handler logic here
        % Example handler logic
        {reply, State, Request}
    end,
    Pid = spawn(fun () -> server_loop(initial, Handler) end),
    register(ServerAtom, Pid),
    Pid.

server_loop(State, Handler) ->
    receive
        {request, From, Ref, Request} ->
            case Handler(State, Request) of
                {reply, NewState, Result} ->
                    From ! {response, Ref, Result},
                    server_loop(NewState, Handler);
                {noreply, NewState} ->
                    server_loop(NewState, Handler)
            end;
        {stop, From} ->
            From ! stopped,
            ok
    end.

request(Server, Request) ->
    Ref = make_ref(),
    Server ! {request, self(), Ref, Request},
    receive
        {response, Ref, Result} -> Result
    end.

% Stop the server process registered to the given name,
% together with any other associated processes
stop(ServerAtom) ->
    Server = whereis(ServerAtom),
    Server ! {stop, self()},
    receive
        stopped -> ok
    end.