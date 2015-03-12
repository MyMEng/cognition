#! /usr/local/bin/python

# TODO: handle incompleteness in data --- missing *off* if double *on*

import sys
import time, datetime
# from pprint import pprint

# time window length in microsecond (10^-6): 5 seconds
WINDOWLENGTH = 5 * 1000000

activityRule = "activity"

# Data format: 2008-03-28 13:42:40.467418 M18 ON
def convertDataEntry( sequenced, line ):
  entities = line.split()

  # get date
  date = " ".join(entities[0:2])
  # some readings does not have milliseconds
  try:
    stamp = time.mktime(datetime.datetime.strptime( date, "%Y-%m-%d %H:%M:%S.%f" ).timetuple())
    # #
    dot = entities[1].find('.')
    msec = float( entities[1][dot:] )
    # #
    stamp += msec
  except:
    stamp = time.mktime(datetime.datetime.strptime( date, "%Y-%m-%d %H:%M:%S" ).timetuple())

  # Convert timestamp to integer
  stamp *= 1000000
  stamp = int(stamp)
  ##############################################################################

  # get sensor ID
  sensor = entities[2].lower()
  ##############################################################################

  # get signal value
  signal = entities[3]
  # check if can be parsed
  try:
    numericValue = float(signal)
  except:
    numericValue = None

  # output variable
  uniformSignal = None
  if   signal == "ON":
    uniformSignal = "true"
  elif signal == "OFF":
    uniformSignal = "false"
  elif signal == "START":
    uniformSignal = "true"
  elif signal == "END":
    uniformSignal = "false"
  elif signal == "PRESENT":
    uniformSignal = "true"
  elif signal == "ABSENT":
    uniformSignal = "false"
  elif signal == "OPEN":
    uniformSignal = "true"
  elif signal == "CLOSE":
    uniformSignal = "false"
  elif signal == "START_INSTRUCT":
    uniformSignal = "true"
  elif signal == "STOP_INSTRUCT":
    uniformSignal = "false"
  elif signal == "true":
    uniformSignal = "true"
  elif signal == "false":
    uniformSignal = "false"
  elif signal == str(numericValue):
    uniformSignal = signal
  else:
    print "Unrecognised signal: ", signal
    sys.exit(1)
  ##############################################################################

  
  # Action begins & ends here
  action = []
  if len(entities) > 4:
    actions = entities[4:]

    # the length should be even
    if len(actions) % 2 != 0:
      print "Action beging and end wrongly encoded!"
      print ' '.join(entities)
      sys.exit(1)

    for a in range(0, len(actions), 2):
      actionID = actions[a].lower()
      aD = actions[a+1].lower()
      actionDescription = None
      if   aD == 'begin':
        actionDescription = 'true'
      elif aD == 'end':
        actionDescription = 'false'
      else:
        print "Unknown block description!"
        print ' '.join(entities)
        sys.exit(1)
      action.append( (actionID, actionDescription, [stamp, sequenced]) )

  ##############################################################################

  return (stamp, sensor, uniformSignal, action)

# Construct sensor knowledge
def sensor_data(sensorID, sensorStatus, timeType, time):
  rule = "sensor("
  # get sensor ID
  rule += sensorID + ", "
  # get sensor status
  rule += sensorStatus + ", "
  #
  # get type of time
  rule += timeType + ", "
  # get time
  rule += time + " "
  # end rule
  rule += ").\n"

  return rule

# get time window of event
def get_window( initTime, currentTime ):
  diff = currentTime - initTime
  # check for negativity
  if diff < 0:
    print "Negative time in get_window()!"
    sys.exit(1)
  # get window: 0--WINDOWLENGTH is 0
  return int(diff/WINDOWLENGTH)

if __name__ == '__main__':
  # Check whether file is given as argument
  args = sys.argv
  if len(args) != 2:
    # Fail
    print "No file specified.\nUsage: formatData.py path/to/file"
    sys.exit(1)

  # Initialise matrix
  data = []
  groundFacts = []

  with open(args[1], 'r') as f: 
    for i, line in enumerate(f):
      out = convertDataEntry(i, line)
      data.append( out[0:3] )
      groundFacts += out[3]

  # Get name of file without subdirectories
  slashInd = args[1][::-1].find('/')
  name = args[1][::-1][:slashInd][::-1] if slashInd!=-1 else args[1]
  # Get the name without extension
  dotInd = name[::-1].find('.')
  if dotInd != -1 and name[-dotInd:] == "txt":
    name = name[::-1][dotInd+1:][::-1]

  # and create local name
  record = name + ".pl" #background

  # Convert to Aleph format
  # normalise time so that each activity starts at 0 - memorise first time-stamp 
  init = data[0][0]

  # Open record file and append to it
  with open(record, 'a') as f:
    for i, e in enumerate(data):
      f.write("\n")

      # relative time knowledge
      rule = sensor_data( e[1].lower(), e[2].lower(), "relative", str(e[0] - init) )
      f.write(rule)
      # absolute time knowledge
      rule = sensor_data( e[1].lower(), e[2].lower(), "absolute", str(e[0]) )
      f.write(rule)
      # absolute time knowledge
      rule = sensor_data( e[1].lower(), e[2].lower(), "sequence", str(i) )
      f.write(rule)
      # windowed time knowledge
      rule = sensor_data( e[1].lower(), e[2].lower(), "windowed", str(get_window( init, e[0] )) )
      f.write(rule)

      f.write("\n")

  # write down ground truth and ground false
  recordf = name + ".f.pl"
  recordn = name + ".n.pl"
  # add two time representations to ground facts
  for i in range(len(groundFacts)):
    rel = groundFacts[i][2][0]-init
    win = get_window( init, groundFacts[i][2][0] )
    groundFacts[i][2].insert(0, rel)
    groundFacts[i][2].append(win)
  # generate positives and negatives - generate only for *sequence*
  pos = []
  neg = []
  farEnd = len(data)
  while len(groundFacts) != 0:
    # get first
    a = []
    a += [groundFacts.pop(0)]
    # find all the rest of the activity
    for i in range(len(groundFacts))[::-1]:
      if groundFacts[i][0] == a[0][0]:
        a.append( groundFacts.pop(i) )
    
    # for the moment forbid the same activity repeated within one file
    # or the list does not start with *{* and finishes with *}*
    if len(a) != 2 or a[0][1] != 'true' or a[1][1] != 'false':
      print "The same block name used more than once: *", a[0][0], "* !"
      print "or"
      print "Wrong block structure!"
      print ">\n", a
      sys.exit(1)

    # use only *sequence*
    beginning = a[0][2][2]
    end = a[1][2][2]
    # generate for all the events
    for i in range(beginning):
      neg.append( activityRule + "(" + a[0][0] + ", " + str(i) + ")." )
    for i in range(beginning, end):
      pos.append( activityRule + "(" + a[0][0] + ", " + str(i) + ")." )
    for i in range(end, farEnd):
      neg.append( activityRule + "(" + a[0][0] + ", " + str(i) + ")." )
    ## generate for one event with range
    # neg.append( activityRule + "(" + a[0][0] + ", " + str(0) + ", " + str(beginning-1) + ")." )
    # pos.append( activityRule + "(" + a[0][0] + ", " + str(beginning) + ", " + str(end-1) + ")." )
    # neg.append( activityRule + "(" + a[0][0] + ", " + str(end) + ", " + str(farEnd) + ")." )

  # Write positive and negative examples
  with open(recordf, 'wb') as pf:
    pf.write( '\n'.join(pos) )
    pf.write('\n')
  with open(recordn, 'wb') as nf:
    nf.write( '\n'.join(neg) )
    nf.write('\n')

