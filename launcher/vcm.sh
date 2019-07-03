#!/bin/bash

# run OpenSAT with hard coded models & configs found here and in /vagrant
# assumes Python environment in /home/${user}/

# Absolute path to this script. /home/user/bin/foo.sh
SCRIPT=$(readlink -f $0)
# Absolute path this script is in. /home/user/bin
BASEDIR=`dirname $SCRIPT`
#| Path to VCM (go one folder up and to VCM)
VCMDIR=/home/vagrant/repos/vcm
UTIL=/home/vagrant/utils

if [ $# -gt 2 ]; then
  echo "Usage: $0 <dirname> [yun_mode]"
  echo "where dirname is the name of the folder"
  echo "containing the wav files"
  exit 1
fi

audio_dir=/vagrant/$1
if [ $# -gt 1 ]; then
    yun=$2
else
    yun="universal"
fi
filename=$(basename "${audio_dir}")
dirname=$(dirname "${audio_dir}")
extension="${filename##*.}"
basename="${filename%.*}"
# Check audio_dir to see if empty or if contains empty wav
bash $UTIL/check_folder.sh ${audio_dir}

KEEPTEMP=false
if [ $BASH_ARGV == "--keep-temp" ]; then
    KEEPTEMP=true
fi
mkdir -p ${audio_dir}/VCMtemp
echo ${audio_dir}/VCMtemp

# let's get our bearings: set CWD to the path of VCM
cd $VCMDIR

# Iterate over files
echo "Starting"
for f in `ls ${audio_dir}/*.wav`; do
   echo $f
    ./runVCM.sh $f $yun
done

echo "$0 finished running"


# simply remove hyp and feature
if ! $KEEPTEMP; then
    rm -rf ${audio_dir}/VCMtemp
fi
