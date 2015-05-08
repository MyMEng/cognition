connected(A, B, Path) :-
  connected(A, B, [], Path).
connected(A, B, V, Path) :-
  connected_(A, X), not( member(X, V) ),
  (
    B = X, reverse([B,A|V], Path)
  ; connected(X, B, [A|V], Path)
  ), !.

connected_(A, B) :-
  connected__(A, B); connected__(B, A).

nowAt(Room, Time, TimeType) :-
  %% there is presence in given room at some time T...
  spaceTime(Room, TimeType, T),
  %% ...which is before our time of interest...
  T =< Time,
  %% ...and we do not move to any other room between *Time* and *T*
  \+nowAt_(Room, TimeType, T, Time), !.

nowAt_(Room, TimeType, T1, T2) :-
  spaceTime(OtherRoom, TimeType, Tbound),
  \+(OtherRoom = Room),
  T1 =< Tbound, Tbound =< T2.

nowDo(Activity, Time, TimeType) :-
  %% the activity is held at some time T...
  activityTime(Activity, true, TimeType, T1),
  %% ...which started now or before our time of interest...
  T1 =< Time,
  %% ... and has not ended yet.
  \+nowDo_(Activity, Time, TimeType).

nowDo_(Activity, Time, TimeType) :-
  activityTime(Activity, false, TimeType, T),
  T =< Time.

location_(Time, Location) :-
  sensorInRoom(SensorID, Location),
  sensor_state(SensorID, true, Time), !.

location(Time, Location) :-
  (sensorInRoom(SensorID, Location),
   sensor_state(SensorID, true, Time),
   Time >= 0, !  );
  %% think about cut at the end
  ( !, Time > 0, location(Time-1, Location) ).

location(Time, Location, State) :-
  (sensorInRoom(SensorID, Location),
   sensor_state(SensorID, State, Time),
   Time >= 0, !  );
  %% think about cut at the end
  ( !, Time > 0, location(Time-1, Location) ).

%% return all activities between given times
locations(T1, T2, Loc) :-
  location(T1, Loc);
  (T1<T2, locations(T1+1, T2, Loc)).

device(Time, Device) :-
  sensorActivity(SensorID, Device),
  sensor_state(SensorID, true, Time).

device(Time, Device, State) :-
  sensorActivity(SensorID, Device),
  sensor_state(SensorID, State, Time).

devices(T1, T2, Dev) :-
  device(T1, Dev);
  (T1<T2, devices(T1+1, T2, Dev)).

sensor_state(SensorID, SensorState, Time) :-
  sensor_state(SensorID, SensorState, sequence, Time).

sensor_state(SensorID, SensorState, TimeType, Time) :-  %% there is sensor in given state...
  sensor(SensorID, SensorState, TimeType, T1),
  % ... before our time of interest...
  T1 =< Time,
  %% ...and its status does not change after that.
  negate(NotSensor, SensorState),  \+sensor_state(SensorID, NotSensor, TimeType, T1, Time),!.

%% sensor state between T1 and T2 inclusive
sensor_state(SensorID, SensorState, TimeType, T1, T2) :-
  sensor(SensorID, SensorState, TimeType, T),
  T1 =< T, T =< T2.

negate(Y, X) :-
  (X ->
   Y = false;
   Y = true).

sensorModes(true).
sensorModes(false).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% THIS CHANGES FOR REAL DATA!!!!!!!!!!!!
% knowledge 'a priori' - order of activities
%% define activity time window
activityTimeWindow(5).

% check last time activity happened in time
checkPastActivities(UpToTime, Activity, WasAtTime) :- % +,+,-
  findall(T, bactivity(Activity, T), Ts),
  highestNumberWithinRange(Ts, UpToTime, WasAtTime).

% find highest value within range
highestNumberWithinRange([H|List], UpperBound, Value) :-
  H < UpperBound,
  highestNumberWithinRange_(List, UpperBound, H, Value).
highestNumberWithinRange_([H|List], UpperBound, V, Value) :-
  (  H < UpperBound, H > V
   -> highestNumberWithinRange_(List, UpperBound, H, Value)
   ;  highestNumberWithinRange_(List, UpperBound, V, Value)
  ).
highestNumberWithinRange_([], _, Value, Value).


%% after COOKING must be EATING (within some reasonable window)
activityOrder(Time, eat) :- % +,- % #eat
  % find last time (< +Time) the activity was COOK
  checkPastActivities(Time, cook, WasAtTime),
  % and not it isn't COOKING
  \+bactivity(cook, Time),
  % check whether it is within range
  TimeDifference is Time - WasAtTime,
  activityTimeWindow(Range),
  TimeDifference =< Range.%,
  % than it's EATING
  %% CurrentActivity = eat.

%% after EATING must be WASHING-UP (within some reasonable window
activityOrder(Time, clean) :- % +,- % #eat
  % find last time (< +Time) the activity was COOK
  checkPastActivities(Time, eat, WasAtTime),
  % and not it isn't COOKING
  \+bactivity(eat, Time),
  % check whether it is within range
  TimeDifference is Time - WasAtTime,
  activityTimeWindow(Range),
  TimeDifference =< Range,
  % than it's EATING
  CurrentActivity = clean.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% only valid for generator!!!!!!!!!!!!!!!!!!!!
inCabinet(oatmeal).
inCabinet(raisins).
inCabinet(brown_sugar).
inCabinet(bowl).
inCabinet(measuring_spoon).
inCabinet(medicine_container).
inCabinet(pot).
%
deviceIDs(none).
%
outOfCabinet(Time, ItemList) :- % [pot, raisin, ...]
  findall(L, inCabinet(L), Li),
  checkItemsWithSensors(Time, Li, ItemList).

checkItemsWithSensors(Time, Li, ItemList) :-
  checkItemsWithSensors_(Time, Li, [], ItemList).
checkItemsWithSensors_(Time, [Device|Li], TempItemList, ItemList) :-
  ( device(Time, Device)
  -> checkItemsWithSensors_(Time, Li, [Device|TempItemList], ItemList)
   ; checkItemsWithSensors_(Time, Li, TempItemList, ItemList)
  ).
checkItemsWithSensors_(_, [], [I|ItemList], [I|ItemList]). % at least one element I
checkItemsWithSensors_(_, [], [], [none]). % 0 elements

medicineInList(List) :-
  inList(medicine_container, List).
inList(A, [B|Bi]) :-
    A = B, !
  ; inList(A, Bi), !.

%%%%%%%%%%
waterUsed(Time) :-
    device(Time, water_hot), !
  ; device(Time, water_cold), !.

waterType(hot).
waterType(cold).
typeOfWater(Time, WaterType) :-
  pass.

% particular direction of change
%% switvch from off to on or vice versa

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% knowledge 'a priori' - bind device with activity
aPriori(tv    , watchTV   ) :- true.
aPriori(burner, cook      ) :- true.
aPriori(phone , phone_call) :- true.

% Activity determiner
act(A, A) :- true.

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

%% % get next/previous activity
%% nextActivity(Time, NextActivity) :-
%%   timeUB(TimeBound),
%%   queuedActivity(Time, forward, TimeBound, NextActivity).

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

nonEmpty(B) :-
  B \= [none], B \= [], !.

notCooked(A) :-
  (\+cooked(A, B), !);
  (cooked(A, B), A-B < 10).

cooked(A, C) :-
  cooked(0, A, C).

cooked(Now, Up, C) :-
  (bactivity(cook, Now), C = Now, !);
  (Now < Up, !, B is Now+1, cooked(B, Up, C)).

% devices that have closed cycle during given device
% get duration of selected sensor
%% getDuration() :- .
% how long is it on?
% major time criterion

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RULES FOR MULTIPLE RESIDENTS
% define people
person(residentA).
person(residentB).

% assign bedrooms
bedroom(residentA, room_1).
bedroom(residentB, room_2).

% MR activities
activityIDs(sleep).
activityIDs(useBathroom).

% prior knowledge about room activity
roomActivity(room_1, in_room).
roomActivity(room_2, in_room).
roomActivity(hall, out_room).
roomActivity(bathroom, in_room).

% confirm a room
roomInLocations(Locations, Room) :-
  member(Room, Locations), (Room = room_1; Room = room_2).
hallbathroomLocations(Locations, Room) :-
  member(Room, Locations), (Room = bathroom; Room = hall). 

% all people but:
allPeopleBut(Person, Remaining) :-
  findall(R, (person(R), R \= Person), Re), remDu(Re, Remaining).

% number of residents
numResidents(N) :-
  findall(R, person(R), Rs),
  length(Rs, N).

% return locations
locations(T, Locators) :-
  findall(L, (sensor_state(SensorID, true, T), sensorInRoom(SensorID, L)), Locations),
  remDu(Locations, Locs),
  % find time of sensors being ON
  findall((SensorID, Tlow), sensorStill(SensorID, T, Tlow), SIDs),
  % get locations to delete
  locationsToDelete(SIDs, RemLoc),
  % if more than two location predicted remove it
  ifPossibleRemove(Locs, RemLoc, Locators).

%% locations(Time, Locations) :-
%%   (Time >= 0,
%%    findall(SensorID, sensor_state(SensorID, true, Time), SensorIDs),
%%    findall(sensorInRoom(SensorID, Location)), !  );
%%   %% think about cut at the end
%%   ( !, Time > 0, location(Time-1, Location) ).

% if less than 2 locations than recover last complete solution
metaLocations(T, L) :-
  locationsPrim(T, Locs), length(Locs, Len), !,
  ( (Len < 2, T > 0, !, T1 is T - 1, metaLocations(T1, L)) ; (Len < 2, T = 0, L = Locs, !) ; (Len >= 2, L = Locs, !) ).

locationsPrim(T, Locs) :-
  findall(L, (sensor_state(SensorID, true, T), sensorInRoom(SensorID, L)), Locations),
  remDu(Locations, Locs).

% remove locations if more than two
ifPossibleRemove(Locs, RemLoc, Locators) :-
  length(Locs, Len),
  ((Len > 2, !, del(RemLoc, Locs, Locators));
    (Len =< 2, !, Locators = Locs)).

% based on time window remove locations --- the oldest location
locationsToDelete(SIDs, RemLoc) :-
  locationsToDelete(SIDs, (none,0), (OldID, _)),
  sensorInRoom(OldID, RemLoc).
locationsToDelete([(ID, Tn)|SIDS], (IDo,T), RemLoc) :-
  (Tn >= T, !, locationsToDelete(SIDS, (ID,Tn), RemLoc));
  (Tn < T, !, locationsToDelete(SIDS, (IDo,T), RemLoc)).
locationsToDelete([], Loc, Loc).

% improve location to discard latest room reeding if hall or bathroom detected
%% % find the oldest sensor and disregard location
sensorStill(SensorID, Time, Tlow) :-
  %% there is sensor in given state...
  sensor(SensorID, true, sequence, T1),
  %% its not true that this sensor activated before
  Tlow is Time - T1,
  % ... before our time of interest...
  T1 =< Time,
  %% ...and its status does not change after that.
  \+sensorStill_(SensorID, T1, Time).

%% sensor state between T1 and T2 inclusive
sensorStill_(SensorID, T1, T2) :-
  sensor(SensorID, false, sequence, T),
  T1 =< T, T =< T2.


% addons
del(X,[X|Tail],Tail) :- !.  
del(X,[Y|Tail],[Y|Tail1]):-
  !, del(X,Tail,Tail1).

remDu(Dirty, Clean) :-
  remDu([], Dirty, Clean).
remDu(Cur, [D|Irty], Clean) :-
  (member(D, Cur), !, remDu(Cur, Irty, Clean), !);
  (\+member(D, Cur), !, remDu([D|Cur], Irty, Clean), !).
remDu(C, [], C).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% activity(Activity, Time, Resident) :-
%%   locations(Time, Locations),
%%   roomInLocations(Locations, Room),
%%   roomActivity(Room, Activity),
%%   bedroom(Resident, Room).

%% activity(Activity, Time, Resident) :-
%%   locations(Time, Locations),
%%   hallbathroomLocations(Locations, HB),
%%   roomActivity(HB, Activity),
%%   roomInLocations(Locations, Room),
%%   bedroom(Person, Room),
%%   allPeopleBut(Person, [Resident]).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
