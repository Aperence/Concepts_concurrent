-module(test).
-export([main/0]).

main() ->
    Pid = counter:start(),
    counter:inc(Pid),
    counter:inc(Pid),
    io:format("~p~n", [counter:get(Pid)]).
