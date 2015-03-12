#! /usr/local/bin/python

# TODO: handle incompleteness in data --- missing *off* if double *on*

import sys
import time, datetime
from pprint import pprint

# time window length in microsecond (10^-6): 5 seconds
WINDOWLENGTH = 5 * 1000000

# Prolog ground truth
activityRule = "activity"

# Weka ground truth
atRelation = "@RELATION smartHouse\n"
atAttribute = "@ATTRIBUTE "
atributeTF = " {true, false}"
atributeN  = " numeric"
atributeD  = " \"yyyy-MM-dd HH:mm:ss.SSS\""
atClass = "\n@ATTRIBUTE class "
atData = "\n@DATA"

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

  # get date in Weka format
  dateFormat = datetime.datetime.fromtimestamp(round(stamp, 3)).strftime('%Y-%m-%d %H:%M:%S.%f')[:-3]

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
    uniformSignal = numericValue
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

  return (stamp, sensor, uniformSignal, dateFormat, action)

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

# check whether ground truth is multi-label
def checkLabel(dictionary):
  onLabels = 0
  curretnLabel = 'none'
  for i in dictionary:
    if dictionary[i]:
      onLabels += 1
      curretnLabel = i
  if onLabels > 1:
    print "Multi-label sets not supported at the moment!"
    sys.exit(1)
  return curretnLabel

# get boolean
def getBool(s):
  if s.lower() == 'true':
    return True
  elif s.lower() == 'false':
    return False
  else:
    print "unknown Bool type: ", s, "!"
    sys.exit(1)

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
      data.append( out[0:4] )
      groundFacts += out[4]

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
      rule = sensor_data( e[1].lower(), str(e[2]).lower(), "relative", str(e[0] - init) )
      f.write(rule)
      # absolute time knowledge
      rule = sensor_data( e[1].lower(), str(e[2]).lower(), "absolute", str(e[0]) )
      f.write(rule)
      # absolute time knowledge
      rule = sensor_data( e[1].lower(), str(e[2]).lower(), "sequence", str(i) )
      f.write(rule)
      # windowed time knowledge
      rule = sensor_data( e[1].lower(), str(e[2]).lower(), "windowed", str(get_window( init, e[0] )) )
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

  # generate positives and negatives - generate only for *sequence* - PROLOG
  ## and memorise activity rules for WEKA
  arffGroundTruth = {}
  arffGroundFacts = groundFacts[:]
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

    # memorise beginning and end for WEKA
    arffGroundTruth[a[0][0]] = ( a[0][2], a[1][2] )

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


  
  # write ARFF file for Weka
  ## relative
  recordRarff = name + ".R.arff"
  ## absolute
  recordAarff = name + ".A.arff"
  ## sequenced
  recordSarff = name + ".S.arff"
  ## windowed
  recordWarff = name + ".W.arff"
  ## date
  recordDarff = name + ".D.arff"
  # prepare data to write & # append time
  Rarff = [atRelation, atAttribute+"time"+atributeN]
  Aarff = [atRelation, atAttribute+"time"+atributeN]
  Sarff = [atRelation, atAttribute+"time"+atributeN]
  Warff = [atRelation, atAttribute+"time"+atributeN]
  Darff = [atRelation, atAttribute+"time DATE"+atributeD]
  # get all sensor names
  sensorNames = []
  for e in data:
    f = e[1].lower()
    ft = atributeTF if type(e[2])==str else atributeN
    if (f, ft) not in sensorNames:
      sensorNames.append( (f, ft) )
  # append attributes
  for e in sensorNames:
    Rarff.append(atAttribute + e[0] + e[1])
    Aarff.append(atAttribute + e[0] + e[1])
    Sarff.append(atAttribute + e[0] + e[1])
    Warff.append(atAttribute + e[0] + e[1])
    Darff.append(atAttribute + e[0] + e[1])
  # prepare classes
  classes = []
  for e in arffGroundFacts:
    if e[0] not in classes:
      classes.append(e[0])
  classesArff = "{"
  for e in classes:
    classesArff += e + ','
  classesArff += 'none}'
  # append target class attribute
  Rarff.append(atClass + classesArff)
  Aarff.append(atClass + classesArff)
  Sarff.append(atClass + classesArff)
  Warff.append(atClass + classesArff)
  Darff.append(atClass + classesArff)
  # include DATA marker
  Rarff.append(atData)
  Aarff.append(atData)
  Sarff.append(atData)
  Warff.append(atData)
  Darff.append(atData)
  # generate data
  ## keep track of current sensors status to generate data
  sensorStatus = {}
  for e in sensorNames:
    sensorStatus[e[0]] = False
  ## keep track of current activity to mark ground truth
  groundTruth = {}
  for e in classes:
    groundTruth[e] = False








  # create common data type
  cdt = []
  for d in data:
    if cdt == []:
      cdt.append( (d[0], d[3], [(d[1], d[2])]) )
    elif d[0] in cdt[-1]:
      cdt[-1][-1].append( (d[1], d[2]) )
    else:
      cdt.append( (d[0], d[3], [(d[1], d[2])]) )
  pprint(data)
  pprint(cdt)
  ## generate data
  i = 0
  for e in data:
    # update sensor status based on current entry
    if type(e[2]) == str:
      if e[2].lower() != 'true' and e[2].lower() != 'false':
        print "Unknown sensor status (true/false): *", e[2], "*!"
        sys.exit(1)
      sensorStatus[e[1].lower()] = getBool(e[2])
    elif type(e[2]) == float:
      sensorStatus[e[1].lower()] = e[2]
    else:
      print "Unknown sensor status type: *", e[2], "*!"
      sys.exit(1)
    racwd = ""
    for j in sensorNames:
      racwd += str(sensorStatus[j[0]]).lower() + ','
    # update label record
    for j in groundTruth:
      beg = arffGroundTruth[j][0][2]
      end = arffGroundTruth[j][1][2]
      if i in range(beg, end):
        groundTruth[j] = True
      else:
        groundTruth[j] = False
    # check current class if none give 'none' # detect multi-label issue and report it
    cc = checkLabel(groundTruth)
    # remember that time/date goes first
    Rarff.append(str(e[0] - init) + "," + racwd + cc)
    Aarff.append(str(e[0]) + ',' + racwd + cc)
    Sarff.append(str(i) + ',' + racwd + cc)
    Warff.append(str(get_window( init, e[0] )) + ',' + racwd + cc)
    Darff.append("\"" + e[3] + "\"," + racwd + cc)
    # update i
    i += 1







  # write the files
  with open(recordRarff, 'wb') as pf:
    pf.write( '\n'.join(Rarff) )
    pf.write('\n')
  with open(recordAarff, 'wb') as pf:
    pf.write( '\n'.join(Aarff) )
    pf.write('\n')
  with open(recordSarff, 'wb') as pf:
    pf.write( '\n'.join(Sarff) )
    pf.write('\n')
  with open(recordWarff, 'wb') as pf:
    pf.write( '\n'.join(Warff) )
    pf.write('\n')
  with open(recordDarff, 'wb') as pf:
    pf.write( '\n'.join(Darff) )
    pf.write('\n')
