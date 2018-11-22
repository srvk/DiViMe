#!/bin/bash
#
# author: the ACLEW team
#
# after all the transcriptions are extracted, 
# look for wav file for which no transcription
# exist, and create empty file

for wav in `ls $1/*.wav`; do
    id=$(basename $wav .wav)
    eaf=$1/$id.rttm
    if [ ! -f $eaf ]; then
        touch $eaf
    fi
done
