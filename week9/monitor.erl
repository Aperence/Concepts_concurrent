-module(monitor).
-behaviour(supervisor).

%% API
-export([start_link/0, get_child/1]).
-export([init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init(_Args) ->
    SupervisorSpecification = #{
        strategy => one_for_one, % one_for_one | one_for_all | rest_for_one | simple_one_for_one
        intensity => 10,
        period => 60},

    ChildSpecifications = [
        #{
            id => counter,
            start => {gen_counter, start, []},
            restart => permanent, % permanent | transient | temporary
            shutdown => 2000,
            type => worker, % worker | supervisor
            modules => [gen_counter]
        }
    ],

    {ok, {SupervisorSpecification, ChildSpecifications}}.

get_child(Sup) ->
    element(2, hd(supervisor:which_children(Sup))).

