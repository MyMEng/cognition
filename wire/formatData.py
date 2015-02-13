#! /usr/local/bin/python

import sys
import time, datetime
from pprint import pprint

# time window length in microsecond (10^-6): 5 seconds
WINDOWLENGTH = 5 * 1000000

# Data format: 2008-03-28 13:42:40.467418 M18 ON
def convertDataEntry( line ):
  entities = line.split()

  ##############################################################################
  sensor = entities[2]
  ##############################################################################

  ##############################################################################
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
  elif signal == str(numericValue):
    uniformSignal = signal
  else:
    print "Unrecognised signal: ", signal
    sys.exit(1)
  ##############################################################################

  ##############################################################################
  # Action begins
  action = ''
  if len(entities) > 4:
    action = ' '.join(entities[4:])
  ##############################################################################
  
  ##############################################################################
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

  return (stamp, sensor, uniformSignal, action)

# Construct sensor knowledge
def sensor_data(sensorID, sensorStatus, timeType, time, trialID):
  rule = "sensor("
  # get sensor ID
  rule += sensorID + ", "
  # get sensor status
  rule += sensorStatus + ", "
  #
  # get type of time
  rule += timeType + ", "
  # get time
  rule += time + ", "
  # get trialID
  rule += trialID + " "
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
  if len(args) != 3:
    # Fail
    print "No file or data-type specified."
    print "usage: formatData.py path/to/file type"
    print "where type can be either + (positive examples) or - (negative examples)"
    sys.exit(1)

  # Get type
  dataType = args[2]
  if dataType != '+' and dataType != '-' and dataType != '~':
    print "Wrong type specified"
    print "type can be either '+' (positive examples) or '-' (negative examples)"
    sys.exit(1)

  # Initialise matrix
  data = []

  f = open(args[1], 'r')
  for line in f:
    data.append( convertDataEntry(line) )
  f.close()

  # # Get name of file
  # ind = args[1][::-1].find('/')
  # if ind != -1:
  #   name = args[1][::-1][:ind][::-1]
  # else:
  #   name = args[1]
  # # and create local name
  # nameb = name + ".b" #background
  # namef = name + ".f" #positive
  # namen = name + ".n" #negative

  # TODO: handle incompleteness in data --- missing *off* if double *on*

  # 1:  Make a phone call. # 2:  Wash hands. # 3:  Cook. # 4:  Eat. # 5:  Clean.
  # Create 5+ and 5- files for each activity - Decide on activity based on filename
  activity = args[1][-2:]
  fab = activity + ".b"
  faf = activity + ".f"
  fan = activity + ".n"

  # get trial number: expected "*p01.t1"
  trialID = args[1][-6:-3]
  trialID = trialID.lower()

  record = None
  if dataType == '+':
    print "Nothing to do for: ", dataType
    sys.exit(0)
    # record = faf
  elif dataType == '-':
    print "Nothing to do for: ", dataType
    sys.exit(0)
    # record = fan
  elif dataType == '~':
    record = fab
  else: # error
    print "Unrecognised type!"
    sys.exit(1)

  # Open record file and append to it
  f = open(record, 'a')

  # Convert to Aleph format
  # normalise time so that each activity starts at 0 - memorise first time-stamp 
  init = data[0][0]

  # Target rule: m08( time, tatus ).
  for i, e in enumerate(data):
    f.write("\n")

    # relative time knowledge
    rule = sensor_data( e[1].lower(), e[2].lower(), "relative", str(e[0] - init), trialID )
    f.write(rule)

    # absolute time knowledge
    rule = sensor_data( e[1].lower(), e[2].lower(), "absolute", str(e[0]), trialID )
    f.write(rule)

    # absolute time knowledge
    rule = sensor_data( e[1].lower(), e[2].lower(), "sequence", str(i), trialID )
    f.write(rule)

    # windowed time knowledge
    window = get_window( init, e[0] )
    rule = sensor_data( e[1].lower(), e[2].lower(), "windowed", str(window), trialID )
    f.write(rule)

    f.write("\n")

  f.close()
  # pprint(data)
