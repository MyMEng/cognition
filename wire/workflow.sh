#! /bin/bash
# Workflow

# check if argument was given as trialID, if not perform 10 trials
if [ -z "$1" ]; then
  # {l0,l1,l2,l3,l4,l5,l6,l7,l8,l9}
  ls=(l0 l1 l2 l3 l4 l5 l6 l7 l8 l9)
else
  ls=(a0)
  ls=($1)
fi

for i in ${ls[@]}; do
  mkdir $i

  ../../SHgen/generator.py ../../SHgen/examples/rooms.l ../../SHgen/examples/layout.l ../../SHgen/examples/activities.l ../../SHgen/examples/basicML.l #../../SHgen/examples/basicpat.l #../../SHgen/examples/casas.l #casas.s #path1.ui

  mv bg.pl $i/
  cat alephBody.pl >> $i/bg.pl

  # move truth to background!!!
  ./editTruth.py
  mv data.fb $i/

  mv data.txt $i/
  mv data.f $i/
  mv data.n $i/

  ./formatData.py $i/data.txt
  mv data.pl $i/
  mv data.f.pl $i/
  mv data.n.pl $i/
  mv data.A.arff $i/
  mv data.R.arff $i/
  mv data.S.arff $i/
  mv data.W.arff $i/
  mv data.D.arff $i/

  cp alephHeader.pl $i/data.b

  cat $i/bg.pl >> $i/data.b
  cat $i/data.pl >> $i/data.b

  cp learn.ypl $i/
  cp aleph.yap $i/

  # move truth to background!!!
  cat $i/data.fb >> $i/data.b

  # Copy the directory "foo" from the local host to a remote host's directory "bar"
  scp -r $i kacper@192.168.56.101:~/
  ssh kacper@192.168.56.101 $i/learn.ypl
  scp kacper@192.168.56.101:~/$i/rules.pl $i/
  ssh kacper@192.168.56.101 rm -fr $i

  # clean rules and move
  ./cleanupSingles.py $i/rules.pl
  mv rules.cleaned.pl $i
done

if [ ${#ls[@]} -le 1 ]; then
  echo "Cannot perform cross-validation: only one element."
else
  # do cross validation
  ./cross-validate.py "${ls[*]}"
fi
