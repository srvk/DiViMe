#!/bin/bash
source activate divime

# run OpenSAT with hard coded models & configs found here and in /vagrant


# Absolute path to this script. /home/user/bin/foo.sh
SCRIPT=$(readlink -f $0)
# Absolute path this script is in. /home/user/bin
BASEDIR=`dirname $SCRIPT`
# Path to OpenSAT (go on folder up and to opensat)



if [ $# -lt 1 ]; then
  echo "Usage: noisemesSad.sh <dirname>"
  echo "where dirname is a folder on the host"
  echo "containing the wav files (/vagrant/dirname/ in the VM)"
  exit 1
fi

KEEPTEMP=false
if [ $BASH_ARGV == "--keep-temp" ]; then
    KEEPTEMP=true
fi

audio_dir=/vagrant/$1
filename=$(basename "$audio_dir")
dirname=$(dirname "$audio_dir")
extension="${filename##*.}"
basename="${filename%.*}"

# Check audio_dir to see if empty or if contains empty wav
bash $UTILS/check_folder.sh $audio_dir

# let's get our bearings: set CWD to path of OpenSAT
cd $OPENSATDIR
git checkout develop/python3

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
python SSSF/code/predict/1-confidence-vm5.py $audio_dir
echo "finished detecting speech and non speech segments"

# take all the .rttm in /vagrant/data/hyp and move them to /vagrant/data - move features and hyp to another folder also.
for sad in `ls $audio_dir/hyp_sum/*.lab`; do
    base=$(basename $sad .lab)
    rttm_out=noisemesSad_${base}.rttm
   if [ -s $sad ]; then 
       grep ' speech' $sad | awk -v fname=$base '{print "SPEAKER" "  " fname " " 1  " " $1  " " $2-$1 " " "<NA>" " " "<NA>"  " " $3  " "  "<NA>"}'   > $audio_dir/$rttm_out
   else
       touch $audio_dir/$rttm_out
   fi
done

# simple remove hyp and feature
if ! $KEEPTEMP; then
    rm -rf $audio_dir/hyp_sum $audio_dir/feature
fi
git checkout master