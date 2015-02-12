#! /usr/local/bin/python

import sys

# extend rule with statement
def extend_rule(sentence):
  return sentence + "\n"

def activity_t1(bg):
  # discover *phone call*
  return "\n"


# TODO: activity_t2
def activity_t2(bg):
  return "\n"
# TODO: activity_t3
def activity_t3(bg):
  return "\n"
# TODO: activity_t4
def activity_t4(bg):
  return "\n"
# TODO: activity_t5
def activity_t5(bg):
  return "\n"


if __name__ == '__main__':
  # get program arguments --- get background filename
  fab = sys.argv[1]

  background = ""
  if   fab[:-2] == "t1":
    background = activity_t1(background)
  elif fab[:-2] == "t2":
    pass
  elif fab[:-2] == "t3":
    pass
  elif fab[:-2] == "t4":
    pass
  elif fab[:-2] == "t5":
    pass
  else:
    # activity not recognised
    print "Activity not recognised!"
    sys.exit(1)

  with open(fab, 'a') as f:
    # write specific knowledge
    f.write(background)

  # easier done in BASH
  # # open general knowledge file
  # with open('generalRules.pl', 'r') as gk:
  #   lines = gk.readlines()
  #   # open-append-close record file
  #   with open(fab, 'a') as f:
  #     # write general knowledge
  #     f.writelines(lines)
  #     # write specific knowledge
  #     f.write(background)
