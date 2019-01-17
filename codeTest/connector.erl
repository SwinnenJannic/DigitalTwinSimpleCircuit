-module(connector).

-export([create/2, connect/2, disconnect/1, discard/1]).
-export([get_connected/1, get_ResInst/1, set_ResInst/2, get_type/1]).

-export([init/2, test/0]). % for internal use only.

create(HostInst, ConnectTyp_Pid) ->
	spawn(?MODULE, init, [HostInst, ConnectTyp_Pid]).

init(HostInst, ConnectTyp_Pid) ->
	survivor:entry({connector_created, self()}),
	loop(HostInst, disconnected, ConnectTyp_Pid).

connect(HostInst, ParasiteInst) ->
	msg:get(HostInst, connect, [ParasiteInst]).

disconnect(HostInst) ->
	HostInst ! disconnect.

get_connected(HostInst) ->
	msg:get(HostInst, get_connected).

get_ResInst(HostInst) ->
	msg:get(HostInst, get_ResInst).

set_ResInst(Location_Pid, NewResInst) ->
	msg:get(Location_Pid, set_ResInst, [NewResInst]).

get_type(HostInst) ->
	msg:get(HostInst, get_type ).


discard(HostInst) ->
	HostInst ! discard.

% Connectors do not survive their ResInst, nor do they
% move/change from one ResInst to another.

loop(HostInst, Connected_Pid, ConnectTyp_Pid) ->
	receive
		{connect, [ParasiteInst], ReplyFn} ->
			survivor:entry({connection_made, self(), ParasiteInst}),
			ReplyFn(ParasiteInst),
			loop(HostInst, ParasiteInst, ConnectTyp_Pid);
		disconnect ->
			loop(HostInst, disconnected, ConnectTyp_Pid);
		{get_connected, ReplyFn} ->
			ReplyFn(Connected_Pid),
			loop(HostInst, Connected_Pid, ConnectTyp_Pid);
		{get_ResInst, ReplyFn} ->
			ReplyFn(HostInst),
			loop(HostInst, Connected_Pid, ConnectTyp_Pid);
		{set_ResInst, [NewResInst], ReplyFn} ->
			ReplyFn(NewResInst),
			loop(NewResInst, Connected_Pid, ConnectTyp_Pid);
		{get_type, ReplyFn} ->
			ReplyFn(ConnectTyp_Pid),
			loop(HostInst, Connected_Pid, ConnectTyp_Pid);
		discard ->
			survivor:entry(connector_discarded),
			stopped
	end.

test() ->
	C1_Pid = create(dummy1, simplePipe),
	C2_Pid = create(dummy2, simplePipe),
	connect(dummy1, dummy2),
	{C1_Pid, C2_Pid}.
