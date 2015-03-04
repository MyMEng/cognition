#! /bin/bash

# define output directory name
outdir="knowledge"
# clean output --- remove if file exists: rm -f "$outdir/$result"
rm -rf $outdir
# create output folder if does not exists
mkdir -p $outdir

# process data §
for f in ../../WashingtonDatasets/adlnormal/*.{t1,t2,t3,t4,t5}
do
 echo "§Processing $f"
 # format data on $f
 ./formatData.py "$f"
done

# # append general knowledge to background knowledge
# for f in {t1.b,t2.b,t3.b,t4.b,t5.b}
# do
#  echo "§Gknowledge $f"
#  cat alephHeader.pl >> $f
#  ./generateBgk.py "$f"
# done

# move files to output directory #{f,b,n}
for f in ./*.t{1,2,3,4,5}.pl
do
  echo ">Moving $f"
  mv $f $outdir
done
