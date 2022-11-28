-module(ppc).
-export([start_game/0, handle/0, game/3, random/1, random_loop/1, player/1]).
-import(lists, [nth/2]).
-define(MOVES, [pierre, papier, ciseaux]).

start_game()->
    spawn_link(?MODULE, handle, []).

handle()->
    receive
        {play, Pid, Move} -> 
            receive 
                {play, Pid2, Move2} when Pid /= Pid2 -> Pid ! {you, play(Move, Move2)}, Pid2 ! {you, play(Move2, Move)}, handle()
            end
    end.

game(Pid, Printer, Move)->
    Pid ! {play, Printer, Move}.

random(Pid) ->
    spawn_link(?MODULE, random_loop, [Pid]).

random_loop(Pid)->
    Pid ! {play, self(), random_move()},
    receive 
        _ -> random_loop(Pid)
    end.


player(Name)->
    spawn_link(fun Y() -> receive X -> io:format("~p received ~p~n", [Name, X]), Y() end end).


random_move() ->
    lists:nth(rand:uniform(length(?MOVES)), ?MOVES).

play(pierre, pierre) -> tie;
play(pierre, papier) -> lost;
play(pierre, ciseaux) -> won;
play(papier, pierre) -> won;
play(papier, papier) -> tie;
play(papier, ciseaux) -> lost;
play(ciseaux, pierre) -> lost;
play(ciseaux, papier) -> won;
play(ciseaux, ciseaux) -> tie.