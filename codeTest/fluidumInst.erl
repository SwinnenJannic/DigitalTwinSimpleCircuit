-module(fluidumInst).

-export([create/2, init/2, get_resource_circuit/1, next_location/2, leave_location/1]).

create(Root_ConnectorPid, ResTyp_Pid) ->
	spawn(?MODULE, init, [Root_ConnectorPid, ResTyp_Pid]).

init(Root_ConnectorPid, ResTyp_Pid) ->
	State = apply(resource_type, get_initial_state, [ResTyp_Pid, self(), [Root_ConnectorPid, plain_water]]),
	survivor:entry({fluidInst_created, self()}, State),
	loop(State, ResTyp_Pid).

get_resource_circuit(ResInstPid) ->
	msg:get(ResInstPid, get_resource_circuit).

next_location(FluidumInst, NextInst) ->
	%FluidumInst ! {next_location, NextInst}.
	msg:get(FluidumInst, next_location, [NextInst]).

leave_location(Inst) ->
	location:departure(Inst).
%flow_fluidum(Location, [L|L_List]) ->


loop(State, ResTyp_Pid) ->
	receive
		{get_locations, ReplyFn} ->
			L_List = resource_type:get_locations_list(ResTyp_Pid, State),
			ReplyFn(L_List),
			loop(State, ResTyp_Pid);
		{next_location, [NextInst], ReplyFn} ->
			location:arrival(NextInst, self()),
			ReplyFn(NextInst),
			loop(State, ResTyp_Pid);
		{get_type, ReplyFn} ->
			ReplyFn(ResTyp_Pid),
			loop(State, ResTyp_Pid);
		{get_resource_circuit, ReplyFn} ->
			C = fluidumTyp:get_resource_circuit(ResTyp_Pid, State),
			ReplyFn(C),
			loop(State, ResTyp_Pid)
	end.
