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
%%
:- determination( activity/2, aPriori/2 ).
:- determination( activity/2, act/2 ).
%% :- determination( activity/2, getTimeIncrement/2 ).
%% :- determination( activity/2, getTimeDecrement/2 ).
:- determination( activity/2, roomRangers/2 ).
%% :- determination( activity/2, nextActivity/2 ).
%% :- determination( activity/2, previousActivity/2 ).


% Mode declarations: modeHead; modeBody
%% :- modeh( *, activity(#activityIDs, +integer) ).
%% :- modeb( *, device(+integer, #deviceIDs) ).
%% :- modeb( *, location(+integer, #roomIDs) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% :- modeh( 1, activity(#activity, +integer) ).
%% :- modeb( 1, sensor_state(#sensorID, #sensorMode, +number) ).
%% :- modeb( *, location(+integer, #rooms, #sensorMode) ).
%% :- modeb( *, device(+integer, #devices, #sensorMode) ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% :- modeh( *, activity(-activityIDs, +integer) ).
:- modeh( *, activity(#activityIDs, +integer) ).
%%%%
:- modeb( *, act(#activityIDs, -activityIDs) ).
%%
:- modeb( *, device(+integer, #deviceIDs) ).
:- modeb( *, location(+integer, #roomIDs) ).
:- modeb( *, device(+integer, -deviceIDs) ).
:- modeb( *, location(+integer, -roomIDs) ).
:- modeb( *, device(+integer, +deviceIDs) ).
:- modeb( *, location(+integer, +roomIDs) ).
%%
:- modeb( *, aPriori(+deviceIDs, -activityIDs) ).
:- modeb( *, aPriori(-deviceIDs, +activityIDs) ).
%%
:- modeb( *, getTimeIncrement(+integer, -integer) ).
:- modeb( *, getTimeDecrement(+integer, -integer) ).
%%
:- modeb( *, roomRangers(+roomIDs, +roomIDs) ).
:- modeb( *, roomRangers(+roomIDs, #roomIDs) ).
:- modeb( *, roomRangers(#roomIDs, +roomIDs) ).
%%
:- modeb( *, nextActivity(+integer, -activityIDs) ).
:- modeb( *, nextActivity(+integer, #activityIDs) ).
:- modeb( *, previousActivity(+integer, -activityIDs) ).
:- modeb( *, previousActivity(+integer, #activityIDs) ).
%%
:- modeb( *, getDeviceList(+integer, [#deviceIDs|#list]) ).
%%

% Set constrains
%% no 2 activities at the same time
%% false :-
%%   activity(Activity1, T),
%%   activity(Activity2, T),
%%   not(Activity1 = Activity2).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
