#! /bin/bash
# Workflow

mkdir $1

../../SHgen/generator.py ../../SHgen/examples/rooms.l ../../SHgen/examples/layout.l ../../SHgen/examples/activities.l ../../SHgen/examples/path1.ui

mv bg.pl $1/
mv data.txt $1/
mv data.f $1/
mv data.n $1/

./formatData.py $1/data.txt
mv data.pl $1/

cp alephHeader.pl $1/data.b

cat $1/bg.pl >> $1/data.b
cat $1/data.pl >> $1/data.b

cp learn.ypl $1/
cp aleph.yap $1/

# Copy the directory "foo" from the local host to a remote host's directory "bar"
scp -r $1 kacper@192.168.56.101:~/
ssh kacper@192.168.56.101 $1/learn.ypl
scp kacper@192.168.56.101:~/$1/rules.pl $1/
ssh kacper@192.168.56.101 rm -fr $1
