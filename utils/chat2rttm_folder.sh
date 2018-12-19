#!/bin/bash
#
# Shell script to convert all .CHA files inside a folder to .rttm format
# 
for j in ${1}/*.cha
    do chat2stm.sh $j 
    file=`echo $j | sed "s/.cha$//"`
    cat ${file}.stm | awk '{print "SPEAKER",${file},"1",$4,($5 - $4),"<NA>","<NA>","speech","<NA>","<NA>" }' > ${file}.rttm
    rm ${file}.stm
done