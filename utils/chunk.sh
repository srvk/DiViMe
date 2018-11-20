#!/bin/bash

# chunk.sh - break files into 5 minute segments in a special folder
#            then run a processing script on the folder of chunks
#            then merge the resulting RTTMs back together into the
#            folder where the input file resides
#
# assumes $1 is full path to a large WAV file
# assumes $2 is path to script to run (such as are found in utils/
#         that takes a folder name in /vagrant, and processes all WAVs in it)
#
# produces a single .rttm in the same folder $1 was found in
#
# uses /vagrant/chunk/ for temporary results

if [[ $# < 2 ]]; then
  echo "Usage: " $0 " <long WAV file> <runscript>"
  echo "  e.g. utils/chunk.sh /vagrant/ami.wav launcher/yunitate.sh"
  exit
fi

WORKFOLDER="/vagrant/data/temp/chunk"

# remember basename for later ;)
filename=$(basename "$1")
basename="${filename%.*}"  # name without extension
dirname=`dirname $1`       # input folder

if [[ -f $WORKFOLDER ]]; then
  # clean out the folder first
  rm -rf $WORKFOLDER/*
else
  # create the folder
  mkdir -p $WORKFOLDER
fi

# Create 5 minute (except for last piece) named chunk-001.wav chunk-002.wav etc.
sox $1 $WORKFOLDER/chunk-.wav trim 0 300 : newfile : restart

# run whichever tool you were going to run over the $WORKFOLDER folder
# assume programs are like in ~/launcher and assume path is /vagrant/<folder-name>
# but are only given <folder-name>
$2 `basename $WORKFOLDER`

# assume output is in $WORKFOLDER/chunk-00x.rttm - rename/ rejoin 

OUTFILE=$dirname/$basename.rttm
rm -f $OUTFILE # don't want to append to existing one!
touch $OUTFILE

COUNT=0
for f in `ls $WORKFOLDER/*chunk-*.rttm`; do

  # add $COUNT seconds to start time (column 4) of RTTM, and concatenate to $OUTFILE
  cat $f | awk -v ADDME=$COUNT '{print $1,$2,$3,($4+ADDME),$5,$6,$7,$8,$9}' >> $OUTFILE

  # increment COUNT in 5 minutes' worth of seconds (300)
  COUNT=$(($COUNT + 300))

done

