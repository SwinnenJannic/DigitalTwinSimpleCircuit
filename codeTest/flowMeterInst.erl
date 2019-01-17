-module(flowMeterInst).
-export([create/3, init/3, estimate_flow/2, measure_flow/1]).
% -export([commission/1, activate/1]).
% -export([deactivate/1, decommission/1]).

% FlowMeter is a pipe and possibly a more complex resource;
% this resource instance is passed to the create function.
% RealWorldCmdFn is a function to read out the real-world flowMeter.

create(FlowMeterTyp, ResInst, RealWorldCmdFn) ->
	spawn(?MODULE, init, [FlowMeterTyp, ResInst, RealWorldCmdFn]).

init(FlowMeterTyp, ResInst, RealWorldCmdFn) ->
	State = apply(resource_type, get_initial_state, [FlowMeterTyp, self(), [ResInst, RealWorldCmdFn]]),
									%  get_initial_state  (ResTyp_Pid,       ThisResInst, TypeOptions)
	survivor:entry(flowMeterInst_created, State),
	loop(State, FlowMeterTyp, ResInst).

estimate_flow(Interval, FlowMeterInst) ->
	msg:get(FlowMeterInst, estimate_flow, Interval).

measure_flow(FlowMeterInst) ->
	msg:get(FlowMeterInst, measure_flow).


loop(State, FlowMeterTyp, ResInst) ->
	receive
		{measure_flow, ReplyFn} ->
			Answer = msg:get(FlowMeterTyp, measure_flow, State),
			ReplyFn(Answer),
			loop(State, FlowMeterTyp, ResInst);
		{estimate_flow, Interval, ReplyFn} ->
			InfluenceFn = msg:get(FlowMeterTyp, estimate_flow, [State, Interval]),
			ReplyFn(InfluenceFn),
			loop(State, FlowMeterTyp, ResInst);
		{get_type, ReplyFn} ->
			ReplyFn(FlowMeterTyp),
			loop(State, FlowMeterTyp, ResInst);
		OtherMessage ->
			ResInst ! OtherMessage,
			loop(State, FlowMeterTyp, ResInst)
	end.
