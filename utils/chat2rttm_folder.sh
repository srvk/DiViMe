#!/bin/bash
#
# Shell script to convert all .CHA files inside a folder to .rttm format
# 
for j in ${1}/*.cha; do
    stm=${j/.cha/.stm}
    rttm=${j/.cha/.rttm}
    chat2stm.sh $j >> $stm
    cat $stm | awk -v file="$(basename ${rttm/.rttm/})" '{print "SPEAKER",file,"1",$4,($5 - $4),"<NA>","<NA>",$2,"<NA>","<NA>" }' > $rttm
#    rm ${j/.cha/.stm}
done