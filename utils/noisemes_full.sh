#!/bin/bash

# run OpenSAT with hard coded models & configs found here and in /vagrant
# assumes Python environment in /home/${user}/

# Absolute path to this script. /home/user/bin/foo.sh
SCRIPT=$(readlink -f $0)
# Absolute path this script is in. /home/user/bin
BASEDIR=`dirname $SCRIPT`
# Path to OpenSAT (go on folder up and to opensat)
OPENSATDIR=$(dirname $BASEDIR)/OpenSAT

if [ $# -ne 1 ]; then
  echo "Usage: noisemes_full.sh <dirname>"
  echo "where dirname is the name of the folder"
  echo "containing the wav files"
  exit 1
fi

audio_dir=/vagrant/$1
filename=$(basename "${audio_dir}")
dirname=$(dirname "${audio_dir}")
extension="${filename##*.}"
basename="${filename%.*}"
# Check audio_dir to see if empty or if contains empty wav
bash $BASEDIR/check_folder.sh ${audio_dir}

# let's get our bearings: set CWD to the path of OpenSAT
cd $OPENSATDIR

# first features
echo "extracting features for noisemes_full"
for file in `ls ${audio_dir}/*.wav`; do
    SSSF/code/feature/extract-htk-vm2.sh $file
done




# then confidences
# python SSSF/code/predict/1-confidence-vm.py $BASEDIR/SSSF/data/feature/evl.med.htk/$basename.htk $basename
echo "predicting classes"
# python SSSF/code/predict/1-confidence-vm.py $BASEDIR/SSSF/data/feature/evl.med.htk/$basename.htk $basename
python SSSF/code/predict/1-confidence-vm4.py ${audio_dir}
echo "noisemes_full finished running"

# take all the .rttm in /vagrant/data/hyp_sum and move them to /vagrant/data - move features and hyp_sum to another folder also.
for sad in `ls ${audio_dir}/hyp_sum/*.rttm`; do
    _rttm=$(basename $sad)
    rttm=${audio_dir}/noiseme_full_${_rttm}
    mv $sad $rttm
done

# simply remove hyp and feature
rm -rf ${audio_dir}/feature ${audio_dir}/hyp_sum

#if [ ! -d "${audio_dir}/noiseme_full_temp" ]; then
#    mkdir -p ${audio_dir}/noiseme_full_temp
#fi
#
#if [! -d "${audio_dir}/noiseme_full_temp" ]; then
#    mv ${audio_dir}/hyp_sum ${audio_dir}/noiseme_full_temp
#else
#    echo "can't move hyp_sum/ folder to noiseme_full_temp/ because temp is already full"
#fi
#
#if [! -d "${audio_dir}/noiseme_full_temp" ]; then
#    mv ${audio_dir}/feature ${audio_dir}/noiseme_full_temp
#else
#    echo "can't move features/ folder to noiseme_full_temp/ because temp is already full"
#fi
#
