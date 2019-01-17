-module(calculate_flow).
-export([calculate_flow/4, calculate_force/4]).

calculate_flow(Parameter, Prev_Pump_force, PumpTyp, FlowMeterInst) ->
  [H|T] = Parameter,
  Actual_flow = H + T,
  Pump_force = msg:get(PumpTyp, next_flow, Actual_flow),
  Next_flow = 10-(-(5/4)+ math:sqrt((2025-8*Pump_force)/16)),
  Result = flowMeterInst:estimate_flow({0, Next_flow}, FlowMeterInst),
  if
    erlang:abs(Actual_flow - Next_flow + Result) > 0.5  ->
      calculate_flow([Next_flow|Result], Pump_force, PumpTyp, FlowMeterInst);
    true ->
      calculate_force(Prev_Pump_force, Pump_force, T, Result)
  end.

calculate_force(Prev_Pump_force, Pump_force, T, Result) ->
  Last_Pump_force = (Prev_Pump_force + Pump_force)/2,
  Last_Loss = -(T + Result)/2,
  file:write_file("output.dat",
    io_lib:fwrite("De pomp zal uiteindelijk een kracht van ~p moeten leveren om het fluidum een ronde te laten maken. \nDit komt overeen met een debietvermindering van ~p per ronde", [Last_Pump_force, Last_Loss])).
