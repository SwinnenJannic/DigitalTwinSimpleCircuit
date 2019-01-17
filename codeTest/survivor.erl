-module(survivor).
-export([start/0, entry/1, entry/2, init/0, read/1, find/2]).

start() ->
	(whereis(survivor) =:= undefined) orelse unregister(survivor),
	register(survivor, spawn(?MODULE, init, [])).

entry(Data)->
	io:format("~w~n", [Data]),
	ets:insert(logboek, {Data, erlang:timestamp(), self()}).
	%io:format("~w~n", [read(Data)]).

entry(Data, State)->
	io:format("~w~n", [Data]),
	ets:insert(logboek, {Data, erlang:timestamp(), self(), State}).
	%io:format("~w~n", [read(Data)]).

init() ->
	(ets:info(logboek) =:= undefined) orelse ets:delete(logboek),
	ets:new(logboek, [named_table, ordered_set, public]),
	loop().

read(Data)->
	ets:lookup(logboek, Data).

find(Data, Element)->
	ets:lookup_element(logboek, Data, Element).

loop() ->
	receive
		stop -> ok
	end.
