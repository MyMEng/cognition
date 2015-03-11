#! /usr/local/bin/python

from pyswip import Prolog
from sys import argv, exit
from os.path import abspath
# from pprint import pprint

def ppTable(name, lst):
  l0 = len(str(lst[0])) - len('true')
  l2 = len(str(lst[2])) - len('true')
  l02 = l0 if l0>l2 else l2
  l02 = l02 if l02>0 else 0

  l = len('true') + l02
  d0 = l - len(str(lst[0]))
  d2 = l - len(str(lst[2]))
  if d0 <0 or d2 <0:
    print "Wrong length calculation!"
    exit(1)

  output = name + ':\n'
  output += len('positive')*' ' + ' ' + 'true' + l02*' ' + ' ' + 'false\n'
  output += 'positive' + ' ' + str(lst[0]) + d0*' ' + ' ' + str(lst[1]) + '\n'
  output += 'negative' + ' ' + str(lst[2]) + d2*' ' + ' ' + str(lst[3]) + '\n'

  print output


if __name__ == '__main__':

  # check whether argument was passed
  if len(argv) != 2:
    print "Argument missing: list of folders containing Prolog data!"
    print "e.g. \"l0 l1 l2 l3 l4 l5 l6 l7 l8 l9\""
    exit(1)

  # get arguments
  folders = argv[1].split(' ')

  # open Prolog stream
  prolog = Prolog()

  # results
  ## (0)True positive | (1)False Positive
  ## (2)True Negative | (3)False Negative
  table = {}

  # choose *m* as model to test
  for m in folders:

    testData = folders[:]
    testData.remove(m)


    # read in rules
    rules_ = []
    rules  = []
    with open(m+"/rules.pl", 'r') as rulesFile:
      for line in rulesFile:
        rules_.append( line.strip() )
    # remove singularities
    body = False
    rule = ""
    for r in rules_:
      # discard singularities
      if '.' in r:
        if body:
          rule += r
          rules.append(rule.strip('.'))
          rule = ""
        body = False
      else:
        rule += r + ' '
        body = True


    for f in testData:
      # refresh Prolog stream
      prolog = None
      prolog = Prolog()

      # consult ground truth
      prolog.consult( f + '/data.f')

      # get ground truth as a list
      gt_ = list(prolog.query("activity(Activity, Time)"))
      # prune
      gt = {}
      for d in gt_:
        activity = d['Activity']
        time     = d['Time']
        if activity not in gt.keys():
          gt[activity] = [time]
        else:
          gt[activity].append(time)

      # remove
      list(prolog.query("abolish(activity/2)"))

  ########################################

      # consult ground truth
      prolog.consult( f + '/data.n')

      # get ground truth as a list
      gf_ = list(prolog.query("activity(Activity, Time)"))
      # prune
      gf = {}
      for d in gf_:
        activity = d['Activity']
        time     = d['Time']
        if activity not in gf.keys():
          gf[activity] = [time]
        else:
          gf[activity].append(time)

      # remove
      list(prolog.query("abolish(activity/2)"))
          
  ########################################

      # load background
      prolog.consult( f + '/data.pl')
      prolog.consult( f + '/bg.pl')

  ########################################

      # initialise result table if not yet initialised
      if len(table) == 0:
        for k in gt:
          table[k] = [0, 0, 0, 0]
        table['all'] = [0, 0, 0, 0]

      # query current data
      ## write in rules
      for r in rules:
        prolog.assertz(r)

      # check with ground truth
      for act in gt:
        for tim in gt[act]:
          ## query using rules and maintain counter
          ans = bool(len(list(prolog.query( "activity(%s, %d)" % (act, tim) ))))    
          if ans: # True Positive
            table[act][0] += 1
            table['all'][0] += 1
          else: # False Negative
            table[act][3] += 1
            table['all'][3] += 1
      # check with ground false
      for act in gf:
        for tim in gf[act]:
          ## query using rules and maintain counter
          ans = bool(len(list(prolog.query( "activity(%s, %d)" % (act, tim) ))))    
          if ans: # False Positive
            table[act][1] += 1
            table['all'][1] += 1
          else: # True Negative
            table[act][2] += 1
            table['all'][2] += 1
      

      # clean memory
      f1 = abspath(f + '/data.pl')
      list(prolog.query( "source_file(Pred, '" + f1 + "'), functor(Pred, Functor, Arity), abolish(Functor/Arity)" ))
      f2 = abspath(f + '/bg.pl')
      list(prolog.query( "source_file(Pred, '" + f2 + "'), functor(Pred, Functor, Arity), abolish(Functor/Arity)" ))
      list(prolog.query("abolish(activity/2)"))

  # produce statistics per class
  for tabl in table:
    ppTable( tabl, table[tabl] )
