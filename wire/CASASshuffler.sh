#! /bin/bash
# shuffler

for f in ./*.data
do
  # get number
  number=$(echo $f | egrep -o '[0-9]+')

  echo ">Handling $f"
  #create directory
  mkdir ../$number
  # move original file
  mv $f ../$number
  # process the file
  ./../../Dissertation/wire/formatData.py ../$number/$f
  # move processed
  mv "$f.A.arff" ../$number
  mv "$f.D.arff" ../$number
  mv "$f.f.pl" ../$number
  mv "$f.n.pl" ../$number
  mv "$f.pl" ../$number
  mv "$f.R.arff" ../$number
  mv "$f.S.arff" ../$number
  mv "$f.W.arff" ../$number
done
