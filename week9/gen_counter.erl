-module(gen_counter).
-export([start/0, inc/1, inc/2, get_value/1, watch/1, handle_call/3, handle_cast/2, init/1]).
-behaviour(gen_server).

start()->
    gen_server:start_link(?MODULE, {0, []}, []).

init(X) -> {ok, X}.

handle_call(get_value, _From, {Count, Watcher}) ->
    {reply, Count, {Count, Watcher}}.


handle_cast(inc, {Count, Watcher}) ->
    lists:foreach(fun(Pid) -> Pid ! incremented end, Watcher),
    {noreply, {Count+1, Watcher}};

handle_cast({watch, Pid}, {Count, Watcher}) ->
    {noreply, {Count, [Pid | Watcher]}}.

inc(_Pid, 0) -> ok;
inc(Pid, N) when N > 0 ->
    gen_server:cast(Pid, inc),
    inc(Pid, N-1).
    
inc(Pid) ->
    gen_server:cast(Pid, inc).

get_value(Pid) ->
    gen_server:call(Pid, get_value).

watch(Pid) ->
    gen_server:cast(Pid, {watch, self()}).