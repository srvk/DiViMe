#!/bin/bash

check_folder=$(readlink -f $1)

# First check that the folder is not empty
if [[ -z "$(ls -A $check_folder)" ]]; then
    echo "data folder is empty!"
    exit
else
    echo "wavs and transcriptions found !"
fi

# Then, check the consistency of all the files -> check if 
# the wav have no amplitude 
# (credit to http://decided.ly/2013/02/06/find-silent-audio-files/)
## A quick hack like script to list all the files that have
## a low amplitude.

Max=0.0 # Any amplitude greater than this will NOT be listed
#OutList=~/output.list # The name of the file that contains a
# list of file names only of all the
# low-amplitude files.
 
# rm $OutList
for each in `ls $check_folder/*.wav`
do 
    amplitude=$(sox "$each" -n stat 2>&1 | grep "Maximum amplitude" | cut -d ":" -f 2 | sed 's/ //g')
    if [[ $(echo "if (${amplitude} > ${Max}) 1 else 0" | bc) -eq 0 ]]
    then
        echo "$each --> $amplitude" >&2
        echo "$each seems empty !" 
    fi
done

echo "Tests finished"
