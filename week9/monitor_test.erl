-module(gen_test).
-export([main/0]).
-import(monitor, [start/0, inc/1, get_value/1, watch/1]).

main()->
    {ok, Pid} = start(), 
    inc(Pid),
    watch(Pid),
    inc(Pid),
    receive
        incremented -> io:format("Got incremented~n")
    after 
        5000 -> io:format("Didn't receive anything~n")
    end,
    Res = get_value(Pid),
    io:format("~p~n", [Res]).