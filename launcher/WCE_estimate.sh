#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "$0")

FILES_TEST=$1


if [ -n "$2" ]; then
OUTPUTFILE = '/vagrant/repos/WCE_VM/outputs/default_output.csv'
else
OUTPUTFILE=$2
fi

MATPATH="/usr/local/MATLAB/MATLAB_Runtime/v93/"
MODEL_FINAL="~/repos/WCE_VM/models/model_final.mat"

#python ... write python code that averages all the results of the speakers
~/repos/WCE_VM/run_WCEestimate.sh ${MATPATH} ${FILES_TEST} ${MODEL_FINAL} ${OUTPUTFILE}
