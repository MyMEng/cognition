:- set(evalfn, wracc).
:- set(noise, 3).
:- set(minpos, 2).
%% :- set(clauselength,2).
%% :- set(gsamplesize,20).
%% :- set(gsamplesize, 20).

% Determinations
%% :- determination( activity/2, sensor_state/3 ).
:- determination( activity/2, location/2 ).
:- determination( activity/2, device/2 ).

% Mode declarations: modeHead; modeBody
%% :- modeh( 1, activity(#activity, +integer) ).
:- modeh( *, activity(#activityIDs, +integer) ).
%% :- modeb( 1, sensor_state(#sensorID, #sensorMode, +number) ).
%% :- modeb( *, location(+integer, #rooms, #sensorMode) ).
%% :- modeb( *, device(+integer, #devices, #sensorMode) ).
:- modeb( *, location(+integer, #roomIDs) ).
:- modeb( *, device(+integer, #deviceIDs) ).


% Set constrains
%% no 2 activities at the same time
%% false :-
%%   activity(Activity1, T),
%%   activity(Activity2, T),
%%   not(Activity1 = Activity2).
