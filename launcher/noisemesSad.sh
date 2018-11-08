#!/bin/bash
# noisemes_sad.sh
# Since the script is built to be launched outside of the vm, source
# the .bashrc which is not necessarily sourced!
source ~/.bashrc
conda_dir=/home/vagrant/anaconda/bin

# run OpenSAT with hard coded models & configs found here and in /vagrant

# Absolute path to this script. /home/user/bin/foo.sh
SCRIPT=$(readlink -f $0)
# Absolute path this script is in. /home/user/bin
BASEDIR=`dirname $SCRIPT`
# Path to OpenSAT (go on folder up and to opensat)
OPENSATDIR=$(dirname $BASEDIR)/OpenSAT

if [ $# -ne 1 ]; then
  echo "Usage: noisemes_sad.sh <dirname>"
  echo "where dirname is a folder on the host"
  echo "containing the wav files (/vagrant/dirname/ in the VM)"
  exit 1
fi

audio_dir=/vagrant/$1
filename=$(basename "$audio_dir")
dirname=$(dirname "$audio_dir")
extension="${filename##*.}"
basename="${filename%.*}"

# Check audio_dir to see if empty or if contains empty wav
bash $BASEDIR/check_folder.sh $audio_dir

# let's get our bearings: set CWD to path of OpenSAT
cd $OPENSATDIR

# make output folder for features, below input folder
mkdir -p $audio_dir/feature

# first features
echo "extracting features for speech activity detection"
for file in `ls $audio_dir/*.wav`; do
  SSSF/code/feature/extract-htk-vm2.sh $file
done

# then confidences
#python SSSF/code/predict/1-confidence-vm3.py $1
echo "detecting speech and non speech segments"
$conda_dir/python SSSF/code/predict/1-confidence-vm5.py $audio_dir
echo "finished detecting speech and non speech segments"

# take all the .rttm in /vagrant/data/hyp and move them to /vagrant/data - move features and hyp to another folder also.
for sad in `ls $audio_dir/hyp_sum/*.lab`; do
    base=$(basename $sad .lab)
    rttm_out=noisemes_sad_${base}.rttm
   if [ -s $sad ]; then 
       grep ' speech' $sad | awk -v fname=$base '{print "SPEAKER" "  " fname " " 1  " " $1  " " $2-$1 " " "<NA>" " " "<NA>"  " " $3  " "  "<NA>"}'   > $audio_dir/$rttm_out
   else
       touch $audio_dir/$rttm_out
   fi
done

# simple remove hyp and feature
rm -rf $audio_dir/hyp_sum $audio_dir/feature
# mv hyp and features folders to a temp that the user can delete.
#if [ ! -d "$audio_dir/noiseme_sad_temp" ]; then
#    mkdir -p $audio_dir/noiseme_sad_temp
#fi
#
#if [! -d "$audio_dir/noiseme_sad_temp" ]; then
#    mv $audio_dir/hyp_sum $audio_dir/noiseme_sad_temp
#else
#    echo "can't move hyp_sum/ folder to noiseme_sad_temp/ because temp is already full"
#fi
#
#if [! -d "$audio_dir/noiseme_sad_temp" ]; then
#    mv $audio_dir/feature $audio_dir/noiseme_sad_temp
#else
#    echo "can't move features/ folder to noiseme_sad_temp/ because temp is already full"
#fi
#
