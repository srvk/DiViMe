#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "$0")

FILES_TEST=$1

if [ "$#" -ne 1 ] && [ "$#" -ne 2 ]  && [ "$#" -ne 3 ]  ; then
echo "Usage: $0 <list_of_filenames.txt or audio folder> <output_file.csv> (optional) <WCE modelfile.mat> (optional)"
echo "Example:"
echo "$0 /vagrant/data/my_audiodata/ ~/my_WCE_output.txt"
echo "or"
echo "$0 /vagrant/data/list_of_audiofiles.txt ~/my_WCE_output.txt"
exit 1
fi



if [[ -d $1 ]]; then
  find $1*.wav > ~/repos/WCE_VM/file_list.txt
  FILES_TEST=~/repos/WCE_VM/file_list.txt
elif [ ! -d "$1" ] && [ ! -f $1 ]; then
  if [[ -d /vagrant/$1 ]]; then
    find /vagrant/$1*.wav > ~/repos/WCE_VM/file_list.txt
    FILES_TEST=~/repos/WCE_VM/file_list.txt
  fi
fi


if [ -n "$2" ]; then
  OUTPUTFILE=$2
  OUTPUTFILE=${OUTPUTFILE/"data/"/"/vagrant/data/"}
  OUTPUTFILE=${OUTPUTFILE/"/vagrant//vagrant/"/"/vagrant/"}
else
  OUTPUTFILE='~/repos/WCE_VM/outputs/default_output.csv'
fi

if [ -n "$3" ]; then
  MODEL=$3
else
  MODEL="~/repos/WCE_VM/models/model_default.mat"
fi

MATPATH="/usr/local/MATLAB/MATLAB_Runtime/v93/"

echo "Running WCE module (this might take a while...)"
~/repos/WCE_VM/run_WCEestimate.sh ${MATPATH} ${FILES_TEST} ${MODEL} ${OUTPUTFILE} > ~/repos/WCE_VM/process_log.log

echo "WCE processing complete. Wrote output to $OUTPUTFILE"
