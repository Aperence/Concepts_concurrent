-module(week8).
-export([start/0, stop/1, handle/0, sorted/2]).

% erl -noshell -s MODULE FUNCTION ARGS
%       to run FUNCTION of MODULE without getting in cmdline 

handle()->
    receive
        print ->
            io:fwrite("Hello, world\n"), 
            handle();
        {sort, From, L} -> 
            From ! sort(L),
            handle();
        stop -> ok;
        _ -> handle()  % => skip if no match
    end.

start()->
    spawn_link(?MODULE, handle, []).

stop(Pid)->
    Pid ! stop.

sort([]) -> [];
sort([H|T]) ->
    sort([ X || X <- T, X =< H]) ++ [H] ++ sort([ X || X <- T, X > H]).

sorted(Pid, L)->
    Pid ! {sort, self(), L},
    receive 
        X -> X 
    end.

