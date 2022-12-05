-module(monitor_test).
-export([main/0]).
-import(gen_counter, [inc/1, watch/1, get_value/1]).
-import(monitor, [start_link/0, get_child/1]).

main()->
    {ok, Sup} = start_link(),
    Pid = get_child(Sup), 
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