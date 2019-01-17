-module(main).
-export([start/1, ordered/1, prop_ordered/0]).
-include_lib("eqc/include/eqc.hrl"). %moet boven eunit staan
-include_lib("eunit/include/eunit.hrl").

%c(main), c(calculate_flow), c(flow_test), c(survivor), c(fluidumTyp), c(fluidumInst), c(pipeTyp),	c(pipeInst),	c(resource_type), c(resource_instance),	c(msg),	c(location), c(connector), c(pumpTyp), c(pumpInst), c(flowMeterTyp), c(flowMeterInst).

start(Parameter) ->
  %Maak een tabel aan
  survivor:start(),

  %Maak een pipeTyp aan
  PipeTyp = pipeTyp:create(),
  PumpTyp = pumpTyp:create(),
  FlowMeterTyp = flowMeterTyp:create(),
  FluidumTyp = fluidumTyp:create(),

  %Maak een aantal pipeInst aan
  Pipe1 = pipeInst:create(PipeTyp),
  Pipe2 = pipeInst:create(PipeTyp),
  Pipe3 = pipeInst:create(PipeTyp),
  Pipe4 = pipeInst:create(PipeTyp),

  %Haal connectoren op
  [Pipe1_In, Pipe1_Out] = pipeInst:get_connectors(Pipe1),
  [Pipe2_In, Pipe2_Out] = pipeInst:get_connectors(Pipe2),
  [Pipe3_In, Pipe3_Out] = pipeInst:get_connectors(Pipe3),
  [Pipe4_In, Pipe4_Out] = pipeInst:get_connectors(Pipe4),

  %Maak een circuit
  connector:connect(Pipe1_Out, Pipe2_In),
  connector:connect(Pipe2_Out, Pipe3_In),
  connector:connect(Pipe3_Out, Pipe4_In),
  connector:connect(Pipe4_Out, Pipe1_In),

  %Haal locaties op
  Pipe1_Location = pipeInst:get_location(Pipe1),
  %Pipe2_Location = pipeInst:get_location(Pipe2),
  %Pipe3_Location = pipeInst:get_location(Pipe3),
  %Pipe4_Location = pipeInst:get_location(Pipe4),

  %Loc = pipeInst:get_location(Pipe1),

  %Stel componenten in
  FluidumInst = fluidumInst:create(Pipe1_Out, FluidumTyp),
  pumpInst:create(PumpTyp, Pipe1, []),

  %Laat het water vloeien door middel van location, maak een location aan met type water en verplaats deze doorheen het Circuit
  %de instance die wordt gebruikt heeft geen invloed, worden geen ! dingen naar verstuurd

  fluidumInst:next_location(FluidumInst, Pipe1_Location),
  FlowMeter1 = flowMeterInst:create(FlowMeterTyp, Pipe1, []),
  Result = flowMeterInst:estimate_flow(Parameter, FlowMeter1),
  calculate_flow:calculate_flow([element(2, Parameter)|Result], 250, PumpTyp, FlowMeter1).
  %fluidumInst:leave_location(Pipe1_Location).
  main_test_() ->
      [test_two(), test_four(), test_six(), test_eight(), test_ten()]. %eunit:test(main).

  test_two() ->
      ?_assertEqual(-0.01125, start({0, 2})). % notice underscore
  test_four() ->
      ?_assertEqual(-0.03, start({0, 4})).
  test_six() ->
      ?_assertEqual(-0.045, start({0, 6})).
  test_eight() ->
      ?_assertEqual(-0.06, start({0, 8})).
  test_ten() ->
      ?_assertEqual(-0.075, start({0, 10})).

    ordered(A) -> A < 0.

    prop_ordered() ->
        ?FORALL(L, choose(1, 10), ordered(start({0, L}))). %eqc:quickcheck(main:prop_ordered()).
  %fluidumInst:next_location(FluidumInst, Pipe2_Location),
  %FlowMeter2 = flowMeterInst:create(FlowMeterTyp, Pipe2, []),
  %flowMeterInst:estimate_flow(FlowMeter2),

  %fluidumInst:next_location(FluidumInst, Pipe3_Location),
  %FlowMeter3 = flowMeterInst:create(FlowMeterTyp, Pipe3, []),
  %flowMeterInst:estimate_flow(FlowMeter3),

  %fluidumInst:next_location(FluidumInst, Pipe4_Location),
  %FlowMeter4 = flowMeterInst:create(FlowMeterTyp, Pipe4, []),
  %flowMeterInst:estimate_flow(FlowMeter4).
  %fluidumInst:next_location(FluidumInst, Pipe2_Location),
  %fluidumInst:next_location(FluidumInst, Pipe3_Location),
  %fluidumInst:next_location(FluidumInst, Pipe4_Location).

  %pipeInst:get_flow_influence(Pipe1).
