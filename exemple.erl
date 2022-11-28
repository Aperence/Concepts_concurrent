-module(exemple).
-export([start/1, loop/1, get/1]).

start(Start_state)->
    spawn_link(?MODULE, loop, [Start_state]).

loop(State) ->
    receive
        {get, Pid} -> Pid ! State,  
                        loop(State);
        {set, X} -> loop(X);
        close -> ok
    end.

get(Pid) -> 
    Pid ! {get, self()}, 
    receive 
        X -> X 
    end.