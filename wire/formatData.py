#! /usr/local/bin/python

# TODO: handle incompleteness in data --- missing *off* if double *on*

import sys
import time, datetime
# from pprint import pprint

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

  with open(args[1], 'r') as f: 
    for line in f:
      data.append( convertDataEntry(line) )

  # Get name of file without subdirectories
  slashInd = args[1][::-1].find('/')
  if slashInd != -1:
    name = args[1][::-1][:slashInd][::-1]
  else:
    name = args[1]
  # Get the name without extension
  dotInd = name[::-1].find('.')
  if dotInd != -1 and name[-dotInd:] == "txt":
    name = name[::-1][dotInd+1:][::-1]
  else:
    # name = name
    pass

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
