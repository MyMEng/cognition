#! /bin/bash
# Workflow
# {l0,l1,l2,l3,l4,l5,l6,l7,l8,l9}
ls=(l0 l1 l2 l3 l4 l5 l6 l7 l8 l9)
# ls=(a8)

for i in ${ls[@]}; do
  mkdir $i

  ../../SHgen/generator.py ../../SHgen/examples/rooms.l ../../SHgen/examples/layout.l ../../SHgen/examples/activities.l ../../SHgen/examples/path1.ui

  mv bg.pl $i/
  mv data.txt $i/
  mv data.f $i/
  mv data.n $i/

  ./formatData.py $i/data.txt
  mv data.pl $i/

  cp alephHeader.pl $i/data.b

  cat $i/bg.pl >> $i/data.b
  cat $i/data.pl >> $i/data.b

  cp learn.ypl $i/
  cp aleph.yap $i/

  # Copy the directory "foo" from the local host to a remote host's directory "bar"
  scp -r $i kacper@192.168.56.101:~/
  ssh kacper@192.168.56.101 $i/learn.ypl
  scp kacper@192.168.56.101:~/$i/rules.pl $i/
  ssh kacper@192.168.56.101 rm -fr $i
done

# do cross validation
./cross-validate.py "${ls[*]}"
