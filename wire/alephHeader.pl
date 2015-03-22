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
:- determination( activity/2, getTimeIncrement/2 ).
:- determination( activity/2, getTimeDecrement/2 ).
:- determination( activity/2, roomRangers/2 ).
:- determination( activity/2, nextActivity/2 ).
:- determination( activity/2, previousActivity/2 ).


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
:- modeh( *, activity(#activityIDs, +integer) ).
:- modeh( *, activity(-activityIDs, +integer) ).
%%%%
:- modeb( *, device(+integer, #deviceIDs) ).
:- modeb( *, location(+integer, #roomIDs) ).
:- modeb( *, device(+integer, -deviceIDs) ).
:- modeb( *, location(+integer, -roomIDs) ).
%%
:- modeb( *, aPriori(+deviceIDs, -activityIDs) ).
:- modeb( *, aPriori(-deviceIDs, +activityIDs) ).
%%
:- modeb( *, getTimeIncrement(+integer, -integer) ).
:- modeb( *, getTimeDecrement(+integer, -integer) ).
%%
:- modeb( *, roomRangers(+roomIDs, +roomIDs) ).
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
% knowledge 'a priori'
aPriori(tv    , watchTV   ) :- true.
aPriori(burner, cook      ) :- true.
aPriori(phone , phone_call) :- true.

% what devices are turned on at Time
getDeviceList(Time, List) :-
  findall(L, device(Time, L), List).

% what other devices are turned on while X is on
otherDevices(Time, Device, OtherDevices) :-
  % get all devices currently on
  getDeviceList(Time, DeviceList),
  % remove the one of interest and return the remaining
  delete(DeviceList, Device, OtherDevices).

% increment time
getTimeIncrement(T0, T1) :-
  T1 is T0 + 1.

% decrement time
getTimeDecrement(T0, T1) :-
  T1 is T0 - 1.

% restriction to Range (1) room distance during activity
roomRangers(CentralRoom, CurrentRoom) :-
  roomRangers(CentralRoom, 1, CurrentRoom).

roomRangers(CentralRoom, Range, CurrentRoom) :-
  % get path form central room to current room
  connected(CentralRoom, CurrentRoom, Path),
  % get the length inclusive bot rooms
  length(Path, Length),
  % get the distance
  Distance is Length - 1,
  % enforce the distance
  Distance =< Range.

% find upper bound on time
timeUB(UB) :-
  findall(Rand, activity(_, Rand), V),
  max_list(V, UB).

% find lower bound on time
timeLB(LB) :-
  findall(Rand, activity(_, Rand), V),
  min_list(V, LB).

% get next/previous activity
nextActivity(Time, NextActivity) :-
  timeUB(TimeBound),
  queuedActivity(Time, forward, TimeBound, NextActivity).

previousActivity(Time, NextActivity) :-
  timeLB(TimeBound),
  queuedActivity(Time, backward, TimeBound, NextActivity).

queuedActivity(Time, TimeDirection, TimeBound, NextActivity) :-
  % get current activity; if none put none
  (activity(CurrentActivity, Time) ->
    true;
    CurrentActivity = none
  ),
  % find next activity
  queuedActivity_(Time, TimeDirection, TimeBound, CurrentActivity, NextActivity).

queuedActivity_(Time, TimeDirection, TimeBound, CurrentActivity, NextActivity) :-
  % increment time
  (TimeDirection = forward,  T1 is Time + 1, T1 =< TimeBound -> Bounded = true;
   TimeDirection = backward, T1 is Time - 1, T1 >= TimeBound -> Bounded = true;
   Bounded = false
  ),
  % get future activity; if it is still old activity jump
  (Bounded ->
    

  (activity(CurrentActivity, T1) ->
    queuedActivity_(T1, TimeDirection, TimeBound, CurrentActivity, NextActivity);

    (activity(NewActivity, T1) ->
      NextActivity = NewActivity;
      queuedActivity_(T1, TimeDirection, TimeBound, CurrentActivity, NextActivity)
    ));

    NextActivity = none
  ).

max_list([H|L],Max) :-
  max_list(L,H,Max).

max_list([],Max,Max).
max_list([H|L],Max0,Max) :-
  (
    H > Max0 
  ->
    max_list(L,H,Max)
  ;
    max_list(L,Max0,Max)
  ).

min_list([H|L],Max) :-
  min_list(L,H,Max).

min_list([],Max,Max).
min_list([H|L],Max0,Max) :-
  (
    H < Max0 
  ->
    min_list(L, H, Max)
  ;
    min_list(L, Max0, Max)
  ).


% devices that have closed cycle during given device
% get duration of selected sensor
%% getDuration() :- .
% how long is it on?
% major time criterion
