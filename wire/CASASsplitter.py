#! /usr/local/bin/python

if __name__ == '__main__':
  i = 1
  ls = []
  with open('data', 'rb') as thefile:
    for row in thefile:
      ls.append(row)
      if 'Clean end' in row:
        with open( (str(i)+'.data'), 'w') as writer:
          writer.write( ''.join(ls) )
        ls = []
        i += 1
