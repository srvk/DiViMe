#!/bin/bash
#
# Shell script to convert all .eaf files following the ACLEW Annotation Scheme inside a folder to .rttm format
# 
for j in ${1}/*.eaf; do
    r=`echo $j | sed "s/.eaf/rttm/"`
    elan2rttm.py -i $j -o $r
#generate the basic rttms
done