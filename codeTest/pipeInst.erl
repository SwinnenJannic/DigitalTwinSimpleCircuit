-module(pipeInst).
-export([create/1, init/1, get_flow_influence/1, get_connectors/1, get_location/1]).


create(PipeTyp_Pid) -> spawn(?MODULE, init, [PipeTyp_Pid]).

init(PipeTyp_Pid) ->
%	{ok, State} = apply(resource_type, get_initial_state, [PipeTyp_Pid, self(), []]),
	State = resource_type:get_initial_state(PipeTyp_Pid, self()),
	survivor:entry({pipeInst_created, self()}, State),
	loop(State, PipeTyp_Pid).

get_flow_influence(PipeInst_Pid) ->
	msg:get(PipeInst_Pid, get_flow_influence).

get_connectors(PipeInst_Pid) ->
	resource_instance:list_connectors(PipeInst_Pid). %returned {ok, []}

get_location(PipeInst_Pid) ->
	resource_instance:list_locations(PipeInst_Pid). %returned {ok, []}

loop(State, PipeTyp_Pid) ->
	receive
		{get_connectors, ReplyFn} ->
			C_List = resource_type:get_connections_list(PipeTyp_Pid, State),
			ReplyFn(C_List),
			loop(State, PipeTyp_Pid);
		{get_locations, ReplyFn} ->
			List = resource_type:get_locations_list(PipeTyp_Pid, State),
			ReplyFn(List),
			loop(State, PipeTyp_Pid);
		{get_type, ReplyFn} ->
			ReplyFn(PipeTyp_Pid),
			loop(State, PipeTyp_Pid);
		{get_ops, ReplyFn} ->
			ReplyFn([]),
			loop(State, PipeTyp_Pid);
		{get_state, ReplyFn} ->
			ReplyFn(State),
			loop(State, PipeTyp_Pid);
		{get_flow_influence, ReplyFn} ->
			InfluenceFn = msg:get(PipeTyp_Pid, flow_influence, State),
			ReplyFn(InfluenceFn),
			loop(State, PipeTyp_Pid)
	end.
