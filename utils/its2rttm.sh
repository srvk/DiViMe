#!/usr/bin/env bash
# Given a folder, convert all of the its files to rttm

SCRIPT_PATH=$(dirname "$(readlink -f "$0")")

folder=$1

if [ -z "$folder" ]; then
      echo "You must specify a folder containing its files."
      exit
fi

if [ ! -n "$(ls -A $folder/*.its 2>/dev/null)" ]
then
  echo "The folder you specified does not contain any its files."

fi

for its_file in $folder/*.its
do
    rttm_name=${its_file%.its}.rttm
    python $SCRIPT_PATH/its2rttm.py $its_file $rttm_name
done
