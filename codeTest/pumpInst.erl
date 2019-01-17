-module(pumpInst).
-export([create/3, init/3, switch_on/1, switch_off/1, is_on/1, flow_influence/1]).
% -export([commission/1, activate/1]).
% -export([deactivate/1, decommission/1]).

% Pump is a pipe and more; this pipe instance is passed to the create function.
% RealWorldCmdFn is a function to transfer commands to the real-world pump.

create(PumpTyp, PipeInst, RealWorldCmdFn) -> spawn(?MODULE, init, [PumpTyp, PipeInst, RealWorldCmdFn]). %Hier staat normaal-> {ok, spawn(...)}

init(PumpTyp, PipeInst, RealWorldCmdFn) ->
	State = apply(resource_type, get_initial_state, [PumpTyp, self(), [PipeInst, RealWorldCmdFn]]),
									%  get_initial_state  (ResTyp_Pid,  ResInst_Pid, TypeOptions)
	survivor:entry({pumpInst_created, self()}, State),
	[H1|T] = pipeInst:get_connectors(PipeInst),
	[H2] = T,
	connector:set_ResInst(H1, self()),
	connector:set_ResInst(H2, self()),
	loop(State, PumpTyp, PipeInst).

switch_off(PumpInst) ->
	PumpInst ! switchOff.

switch_on(PumpInst) ->
	PumpInst ! switchOn.

is_on(PumpInst) ->
	msg:get(PumpInst, isOn).

flow_influence(PumpInst) ->
	msg:get(PumpInst, get_flow_influence).


loop(State, PumpTyp, PipeInst) ->
	receive
		switchOn ->
			NewState = msg:set_ack(PumpTyp, switchOn, State),
			loop(NewState, PumpTyp, PipeInst);
		switchOff ->
			 NewState = msg:set_ack(PumpTyp, switchOff, State),
			loop(NewState, PumpTyp, PipeInst);
		{isOn, ReplyFn} ->
			Answer = msg:get(PumpTyp, isOn, State),
			ReplyFn(Answer),
			loop(State, PumpTyp, PipeInst);
		{get_type, ReplyFn} ->
			ReplyFn(PumpTyp),
			loop(State, PumpTyp, PipeInst);
		{get_flow_influence, ReplyFn} ->
			InfluenceFn = msg:get(PumpTyp, flow_influence, State),
			ReplyFn(InfluenceFn),
			loop(State, PumpTyp, PipeInst);
		OtherMessage ->
			PipeInst ! OtherMessage,
			loop(State, PumpTyp, PipeInst)
	end.
