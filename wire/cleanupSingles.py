#! /usr/local/bin/python

from sys import argv, exit

if __name__ == '__main__':
  # check whether argument was passed
  if len(argv) != 2:
    print "Argument missing: path to file containing rules!"
    print "e.g. \"folder/rules.pl\""
    exit(1)

  # remove rules without body
  ## read in rules
  rules, rules_ = [], []
  with open(argv[1], 'r') as rulesFile:
    for line in rulesFile:
      rules_.append( line.strip() )
  ## remove singularities
  body = False
  rule = ""
  for r in rules_:
    # discard singularities
    if '.' in r:
      if body:
        rule += r
        rules.append(rule)
        rule = ""
      body = False
    else:
      rule += r + '\n  '
      body = True

  # Get name of file without subdirectories
  slashInd = argv[1][::-1].find('/')
  name = argv[1][::-1][:slashInd][::-1] if slashInd!=-1 else argv[1]
  # Get the name without extension
  ext = ""
  dotInd = name[::-1].find('.')
  if dotInd != -1:
    ext  = name[::-1][:dotInd][::-1]
    name = name[::-1][dotInd+1:][::-1]

  # write cleaned rules
  with open(name+".cleaned."+ext, 'w') as rulesFile:
    rulesFile.write( '\n'.join(rules) )
    rulesFile.write('\n')
