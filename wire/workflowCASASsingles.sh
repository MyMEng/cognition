#! /bin/bash
# Workflow

ls=(casas1 casas2 casas3 casas4 casas5 casas6 casas7 casas8 casas9 casas10)

for i in ${ls[@]}; do
  mkdir $i

  # extract number from $i
  number=$(echo $i | egrep -o '[0-9]+')

  cp "../../CASAS/$number/$number.data.f.pl" $i/data.f
  cp "../../CASAS/$number/$number.data.n.pl" $i/data.n
  cp "../../CASAS/$number/$number.data.pl" $i/data.pl

  cp alephHeader.pl $i/data.b
  cat alephBody.pl >> $i/data.b

  cat casas.bg >> $i/data.b

  cp casas.bg $i/bg.pl
  cat alephBody.pl >> $i/bg.pl

  cat "../../CASAS/$number/$number.data.pl" >> $i/data.b

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

# cross-validate
if [ ${#ls[@]} -le 1 ]; then
  echo "Cannot perform cross-validation: only one element."
else
  # do cross validation
  ./cross-validate.py "${ls[*]}"
fi
