#!/bin/bash

# sum-rttm.sh
#
# Compute and print the number of lines in an RTTM, and the sum of durations
# for use in comparing system outputs
#
# Takes 1 argument: path to an RTTM file

if [ $# -ne 1 ]; then
  echo "Usage: $0 <RTTMfile>"
  echo "where RTTMfile is an RTTM filename"
  exit 1
fi

LINES=`cat $1 | wc -l`
SUM=`awk '{SUM+=$5} END {print SUM}' $1`

echo -e 'LINES: '$LINES'\tDURATION SUM: '$SUM'\tFILE: '$1
