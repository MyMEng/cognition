#! /bin/bash

# # create result file
# result="${f:(-2)}.f"
# # move output files
# mv $result $outdir
# minus=$(grep -r -i --exclude={Chinook_3_Bedroom_TH.png,Chinook_Cabinet.png,README,data} \* ../WashingtonDatasets/adlerror)
# plus=$(grep -r -i --exclude={Chinook_3_Bedroom_TH.png,Chinook_Cabinet.png,README,data} \* ../WashingtonDatasets/adlnormal)

# TODO: replace absolute path with pass-by-reference --- $1; and catch errors

# define output directory name
outdir="knowledge"
# clean output --- remove if file exists: rm -f "$outdir/$result"
rm -rf $outdir
# create output folder if does not exists
mkdir -p $outdir

# # process positive examples +
# for f in ../../WashingtonDatasets/adlnormal/*.{t1,t2,t3,t4,t5}
# do
#  echo "+Processing $f"
#  # format data on $f
#  ./formatData.py "$f" "+"
# done

# # process negative examples -
# for f in ../../WashingtonDatasets/adlerror/*.{t1,t2,t3,t4,t5}
# do
#  echo "-Processing $f"
#  # format data on $f
#  ./formatData.py "$f" "-"
# done

# process background knowledge §
for f in ../../WashingtonDatasets/adlnormal/*.{t1,t2,t3,t4,t5}
do
 echo "§Processing $f"
 # format data on $f
 ./formatData.py "$f" "~"
done

# process background knowledge
for f in {t1.b,t2.b,t3.b,t4.b,t5.b}
do
 echo "§BGknowledge $f"
 # generate background knowledge on $f
 ./generateBgk.py "$f"
done

# append general knowledge to background knowledge
for f in {t1.b,t2.b,t3.b,t4.b,t5.b}
do
 echo "§Gknowledge $f"
 cat generalRules.pl >> $f
 ./generateBgk.py "$f"
done

# move files to output directory #{f,b,n}
for f in ./t{1,2,3,4,5}.*
do
  echo ">Moving $f"
  mv $f $outdir
done
