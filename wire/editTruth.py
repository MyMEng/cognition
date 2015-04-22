#! /usr/local/bin/python

if __name__ == '__main__':
  ls = []
  with open('data.f', 'rb') as thefile:
    for row in thefile:
      if 'activity' in row:
        ls.append('b'+row)
      else:
        ls.append(row)

  with open( 'data.fb', 'wb') as writer:
    writer.write( ''.join(ls) )
