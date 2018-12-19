#!/usr/bin/env bash

# Perform full training of WCE module using data prepared by WCE_preprocess.sh

SCRIPT_DIR=$(dirname "$0")
DIROP_FOLDER="/vagrant/data/WCE_VM_TEMP/"

MATPATH="/usr/local/MATLAB/MATLAB_Runtime/v93/"
FILES_TRAIN="${DIROP_FOLDER}/WAVFILES_TRAIN.txt"
TRAIN_COUNTS="${DIROP_FOLDER}/WORDCOUNTS_TRAIN.txt"
MODEL_FINAL="~/repos/WCE_VM/models/model_final.mat"
ALPHA="${DIROP_FOLDER}/ALPHA.txt"
CONFIG="~/repos/WCE_VM/configs/config_default.txt"

FILES_TEST="${DIROP_FOLDER}/WAVFILES_TEST.txt"
TEST_COUNTS="${DIROP_FOLDER}/WORDCOUNTS_TEST.txt"
OUTPUTS_COUNTS="${DIROP_FOLDER}/OUTPUTS_COUNTS.csv"
OUTPUTS_EVAL="${DIROP_FOLDER}/OUTPUTS_EVAL.txt"

c=0
for en_path in ${DIROP_FOLDER}*_totWords.txt; do
  ((c++))
  ids[c]=${en_path##*/}
  ids[c]="${ids[c]%_totWords.txt}"
done

#python ... write python code that averages all the results of the speakers
c=-1
python $SCRIPT_DIR/get_train_LOO_inputs.py ${c} ${DIROP_FOLDER} ${ids[@]}
~/repos/WCE_VM/run_WCEtrain.sh ${MATPATH} ${FILES_TRAIN} ${TRAIN_COUNTS} ${MODEL_FINAL} ${CONFIG} ${ALPHA}
