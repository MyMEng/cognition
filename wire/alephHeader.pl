%% :- set(evalfn, posonly).
%% :- set(clauselength,2).
%% :- set(gsamplesize,20).

% Determinations
:- determination( activity/2, sensor_state/3 ).
%% :- determination( activity/2, location/3 ).
%% :- determination( activity/2, device/3 ).

% Mode declarations: modeHead; modeBody
:- modeh( 1, activity(#activity, +integer) ).
%% :- modeb( 1, sensor_state(#sensorID, #sensorMode, +number) ).
:- modeb( *, location(+integer, #rooms, #sensorMode) ).
:- modeb( *, device(+integer, #devices, #sensorMode) ).


% Set constrains
%% no 2 activities at the same time
false :-
  activity(Activity, T1),
  activity(Activity, T2),
  T1 = T2.