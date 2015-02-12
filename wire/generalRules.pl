% General rules appended to every background knowledge

negate(Y, X) :-
  (X ->
   Y = false;
   Y = true).

% sensor state before time Time
% TODO: they can be both in the same timeframe-so no timeframe use here
% TODO: additional argumetn how long was it on
% TODO: Check for double on's

sensor_state(SensorID, SensorState, Time) :-
  sensor_state(SensorID, SensorState, sequence, Time).

sensor_state(SensorID, SensorState, TimeType, Time) :-
  % there is sensor in given state...
  sensor(SensorID, SensorState, TimeType, T1),
  % ... before our time of interest...
  T1 =< Time,
  % ...and its status does not change after that.
  negate(NotSensor, SensorState),
  \+sensor_state(SensorID, NotSensor, TimeType, T1, Time),!.

% sensor state between T1 and T2 inclusive
sensor_state(SensorID, SensorState, TimeType, T1, T2) :-
  sensor(SensorID, SensorState, TimeType, T),
  T1 =< T, T =< T2.

% define activities
task(t1). % make a phone call
activity(dining_room). %  move to the phone in the dining room
activity(phone_book).
activity(phone_dial).
activity(phone_talk).
activity(notepad).

task(t2). % wash hands
activity(kitchen).
activity(wash_hands).

task(t3). % cook
activity(measure_water).
activity(run_water).
activity(hob).
activity(oats).
activity(bowl).
activity(raisins).
activity(sugar).

task(t4). % eat
activity(medicin_container).
activity(dining_room).

task(t5). % clean
activity(kitchen). % obscure?
activity(run_water).

% define sensors
sensorID(asterisk). % asterisk
sensorID(ad1-a).    % water sensor
sensorID(ad1-b).    % water sensor
sensorID(ad1-c).    % burner sensor
sensorID(i01).      % oatmeal
sensorID(i02).      % raisins
sensorID(i03).      % brown sugar
sensorID(i04).      % bowl
sensorID(i05).      % measuring spoon
sensorID(i06).      % medicine container sensor
sensorID(i07).      % pot sensor
sensorID(i08).      % phone book sensor
sensorID(d01).      % cabinet sensor
sensorID(m01).      % motion sensor
sensorID(m02).      % motion sensor
sensorID(m03).      % motion sensor
sensorID(m04).      % motion sensor
sensorID(m05).      % motion sensor
sensorID(m06).      % motion sensor
sensorID(m07).      % motion sensor
sensorID(m08).      % motion sensor
sensorID(m09).      % motion sensor
sensorID(m10).      % motion sensor
sensorID(m11).      % motion sensor
sensorID(m12).      % motion sensor
sensorID(m13).      % motion sensor
sensorID(m14).      % motion sensor
sensorID(m15).      % motion sensor
sensorID(m16).      % motion sensor
sensorID(m17).      % motion sensor
sensorID(m18).      % motion sensor
sensorID(m19).      % motion sensor
sensorID(m20).      % motion sensor
sensorID(m21).      % motion sensor
sensorID(m22).      % motion sensor
sensorID(m23).      % motion sensor
sensorID(m24).      % motion sensor
sensorID(m25).      % motion sensor
sensorID(m26).      % motion sensor

% define sensor states
sensorMode(on).
sensorMode(off).
% TODO: sensorMode(+integer).

%% :- set(evalfn, posonly).
%% :- set(clauselength,2).
%% :- set(gsamplesize,20).

% Determinations
:- determination( activity/2, sensor_state/3 ).

% Mode declarations: modeHead; modeBody
:- modeh( 1, activity(#activity, +number) ).
:- modeb( 1, sensor_state(#sensorID, #sensorMode, +number) ).
%% TODO: see above: :- modeb( 1, sensor_state(#sensorID, #integer, +integer) ).

% Set constrains
%% no 2 activities at the same time
false :-
  activity(Activity, T1),
  activity(Activity, T2),
  T1 = T2.

% Specify that phoning activity starts with:
%% asterisk: true
% ends with
%% asterisk: false

% Target rules
% act(Time, Activity) :-
%   sensor_state(m42, on,  Time)
%   sensor_state(m42, off, Time),
%   Activity = phone.
