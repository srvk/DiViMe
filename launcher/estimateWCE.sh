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


# If input is a directory, find all .wavs in it and write to a file to be used as input
# to the WCE tool
if [[ -d $1 ]]; then
  find $1*.wav > ~/repos/WCE_VM/file_list.txt
  FILES_TEST=~/repos/WCE_VM/file_list.txt
elif [ ! -d "$1" ] && [ ! -f $1 ]; then
  if [[ -d /vagrant/$1 ]]; then
    find /vagrant/$1*.wav > ~/repos/WCE_VM/file_list.txt
    FILES_TEST=~/repos/WCE_VM/file_list.txt
  fi
fi


# Replace DiViMe way of addressing data-folder with an absolute path
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

if [ ! -d "/vagrant/data/WCE_VM_TEMP/" ]; then
  mkdir -p /vagrant/data/WCE_VM_TEMP/
fi

MATPATH="/usr/local/MATLAB/MATLAB_Runtime/v93/"

echo "Running WCE module (this might take a while...)"
# The 'DISPLAY= ' part prevents an X-Server from popping up on some machines
DISPLAY= ~/repos/WCE_VM/run_WCEestimate.sh ${MATPATH} ${FILES_TEST} ${MODEL} ${OUTPUTFILE} > /vagrant/data/WCE_VM_TEMP/WCE_process_log.log

# Combine filenames and output counts into one file
paste -d ', ' $FILES_TEST $OUTPUTFILE > /vagrant/data/WCE_VM_TEMP/tempout.txt
cp /vagrant/data/WCE_VM_TEMP/tempout.txt $OUTPUTFILE
sed -i 's+/vagrant/data/+data/+g' $OUTPUTFILE


echo "WCE processing complete. Wrote output to $OUTPUTFILE"
