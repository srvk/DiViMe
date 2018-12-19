#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "$0")
DIROP_FOLDER="/vagrant/data/WCE_VM_TEMP/"

MATPATH="/usr/local/MATLAB/MATLAB_Runtime/v93/"
FILES_TRAIN="${DIROP_FOLDER}/WAVFILES_TRAIN.txt"
TRAIN_COUNTS="${DIROP_FOLDER}/WORDCOUNTS_TRAIN.txt"
MODEL="~/repos/WCE_VM/models/default_model.mat"
ALPHA="${DIROP_FOLDER}/ALPHA.txt"
CONFIG="~/repos/WCE_VM/configs/config_default.txt"

FILES_TEST="${DIROP_FOLDER}/WAVFILES_TEST.txt"
TEST_COUNTS="${DIROP_FOLDER}/WORDCOUNTS_TEST.txt"
OUTPUTS_COUNTS="${DIROP_FOLDER}/OUTPUTS_COUNTS.csv"
OUTPUTS_EVAL="${DIROP_FOLDER}/OUTPUTS_EVAL.txt"


[ -e "${DIROP_FOLDER}/all_estimates.csv" ] && rm "${DIROP_FOLDER}/all_estimates.csv"
[ -e "${DIROP_FOLDER}/all_references.csv" ] && rm "${DIROP_FOLDER}/all_references.csv"

c=0
for en_path in ${DIROP_FOLDER}*_totWords.txt; do
  ((c++))
  ids[c]=${en_path##*/}
  ids[c]="${ids[c]%_totWords.txt}" # this neglects corpus name, only 4 digits

  line=$(head -n 1 $en_path) 
  echo $line >> "${DIROP_FOLDER}/all_references.csv"  
done

c=0
for en_path in ${DIROP_FOLDER}*_totWords.txt; do
  #python $SCRIPT_DIR/get_train_LOO_inputs.py ${c} ${DIROP_FOLDER} ${ids[@]}
  python ~/repos/WCE_VM/aux_VM/get_train_LOO_inputs.py ${c} ${DIROP_FOLDER} ${ids[@]}
  ~/repos/WCE_VM/run_WCEtrain.sh ${MATPATH} ${FILES_TRAIN} ${TRAIN_COUNTS} ${MODEL} ${CONFIG} ${ALPHA}  
  ~/repos/WCE_VM/run_WCEestimate.sh ${MATPATH} ${FILES_TEST} ${MODEL} "${DIROP_FOLDER}/OUTPUTS_COUNTS_${c}_ESTIMATE.csv"
  python ~/repos/WCE_VM/evaluate_WCE.py "${DIROP_FOLDER}/OUTPUTS_COUNTS_${c}_ESTIMATE.csv" ${TEST_COUNTS} ${DIROP_FOLDER}"/OUTPUTS_EVAL_"${c}".txt" # code to run eval must bre filled
  cp ${TEST_COUNTS} "${DIROP_FOLDER}/OUTPUTS_COUNTS_${c}_REFERENCE.csv"

 ((c++))
done

c=0
for en_path in ${DIROP_FOLDER}*_ESTIMATE.csv; do 
  awk '{ sum += $1 } END { print sum }' "${DIROP_FOLDER}/OUTPUTS_COUNTS_${c}_ESTIMATE.csv" >> "${DIROP_FOLDER}/all_estimates.csv"  
 ((c++))
done

python ~/repos/WCE_VM/evaluate_WCE.py "${DIROP_FOLDER}/all_estimates.csv" "${DIROP_FOLDER}/all_references.csv" ${DIROP_FOLDER}"/OUTPUTS_LOO.txt" # code to run eval must bre filled

more ${DIROP_FOLDER}"/OUTPUTS_LOO.txt"