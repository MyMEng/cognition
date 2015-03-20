%% use ... evaluation function
:- set(evalfn, wracc).
%% allow at most ... negatives to be covered by rule
:- set(noise, 3).
%% allow rules which cover at least ... positives
:- set(minpos, 1).
%% don't reduce(search) - dirty workaround
%% :- set(search, false).

% EXPERIMENTAL
%% do not remove redundant clauses form hypothesis' body
%% :- set(check_redundant, false).
%% :- set(check_useless, false).
%% %% dump the output to file - WONT WORK WITH workflow SCRIPT
%% :- set(record, true).
%% :- set(recordfile, dumpster).

%% :- set(clauselength,2).
%% :- set(gsamplesize,20).
%% :- set(gsamplesize, 20).

% Determinations
%% :- determination( activity/2, sensor_state/3 ).
:- determination( activity/2, device/2 ).
:- determination( activity/2, location/2 ).
:- determination( activity/2, getDeviceList/2 ).
:- determination( activity/2, recordRoom/2 ).
:- determination( activity/2, recordDevices/2 ).

% Mode declarations: modeHead; modeBody
:- modeh( *, activity(#activityIDs, +integer) ).
%% :- modeb( *, device(+integer, #deviceIDs) ).
%% :- modeb( *, location(+integer, #roomIDs) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% :- modeh( 1, activity(#activity, +integer) ).
%% :- modeb( 1, sensor_state(#sensorID, #sensorMode, +number) ).
%% :- modeb( *, location(+integer, #rooms, #sensorMode) ).
%% :- modeb( *, device(+integer, #devices, #sensorMode) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% :- modeh( *, activity(#activityIDs, +integer) ).
:- modeb( *, device(+integer, -deviceIDs) ).
:- modeb( *, location(+integer, -roomIDs) ).
%% :- modeb( *, roomIDs(+roomIDs) ).

:- modeb( *, getDeviceList(+integer, [#deviceIDs|#list]) ).

:- modeb( *, recordRoom(+roomIDs, #roomIDs) ).
:- modeb( *, recordDevices(+deviceIDs, #deviceIDs) ).



%%%% write location and device recorders
recordRoom(IO, IO):-true.
recordDevices(IO, IO):-true.

getDeviceList(Time, List) :-
  findall(L, device(Time, L), List).

getTimeIncrement(T0, T1) :-
  T1 is T0 + 1.

getTimeDecrement(T0, T1) :-
  T1 is T0 - 1.

% Set constrains
%% no 2 activities at the same time
%% false :-
%%   activity(Activity1, T),
%%   activity(Activity2, T),
%%   not(Activity1 = Activity2).
