-module(week8).
-export([start/0, stop/1, handle/0]).

handle()->
    receive
        print -> io:fwrite("Hello, world\n"), handle();
        stop -> ok;
        _ -> handle()  % => skip if no match
    end.

start()->
    spawn_link(?MODULE, handle, []).

stop(Pid)->
    Pid ! stop.

