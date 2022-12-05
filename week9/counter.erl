-module(counter).
-export([start/0, inc/1, get_value/1, loop/1]).

loop(State)->
    receive
        inc -> loop(State+1);
        {get, From} -> From ! State, loop(State)
    end.


start()->
    spawn_link(?MODULE, loop, [0]).

inc(Pid) ->
    Pid ! inc.

get_value(Pid) ->
    Pid ! {get, self()},
    receive
        Res -> Res
    end.