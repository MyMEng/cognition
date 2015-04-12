#! /bin/bash
# Workflow

ls=(casasN)

for i in ${ls[@]}; do
  mkdir $i

  cp ../../CASAS/whole/data.f.pl $i/data.f
  cp ../../CASAS/whole/data.n.pl $i/data.n

  cp alephHeader.pl $i/data.b
  cat alephBody.pl >> $i/data.b

  cat casas.bg >> $i/data.b
  cat ../../CASAS/whole/data.pl >> $i/data.b

  cp learn.ypl $i/
  cp aleph.yap $i/

  # Copy the directory "foo" from the local host to a remote host's directory "bar"
  scp -r $i kacper@192.168.56.101:~/
  ssh kacper@192.168.56.101 $i/learn.ypl
  scp kacper@192.168.56.101:~/$i/rules.pl $i/
  ssh kacper@192.168.56.101 rm -fr $i

  # clean rules and move
  ./cleanupSingles.py $i/rules.pl
  mv rules.cleaned.pl $i
done
