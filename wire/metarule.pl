%% Single resident
metaActivity(Activity, Time) :-
  activity(Activity, Time),
  Time >= 0, !.

metaActivity(Activity, Time) :-
  !, Time > 0,
  metaActivity(Activity, Time-1).


%% Multiple residents
metaActivity(Activity, Time, Persona) :-
  activity(Activity, Time, Persona),
  Time >= 0, !.

metaActivity(Activity, Time, Persona) :-
  !, Time > 0,
  metaActivity(Activity, Time-1, Persona).
