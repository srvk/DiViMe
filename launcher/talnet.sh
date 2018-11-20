#!/bin/bash
# Since the script is built to be launched outside of the vm, source
# the .bashrc which is not necessarily sourced!
source ~/.bashrc
conda_dir=/home/vagrant/anaconda/bin

# run 537 class classifier with hard coded models & configs found here
# assumes Python environment in /home/${user}/anaconda/

# Absolute path to this script. /home/user/bin/foo.sh
SCRIPT=$(readlink -f $0)
# Absolute path this script is in. /home/user/bin
BASEDIR=`dirname $SCRIPT`
# Path to classify tool (go one folder up and to 537cls)
CLASSIFY=/home/vagrant/repos/TALNet

if [ $# -ne 1 ]; then
  echo "Usage: $0 <dirname>"
  echo "where dirname is the name of the folder"
  echo "in /vagrant containing wav files"
  exit 1
fi

audio_dir=/vagrant/$1
filename=$(basename "$audio_dir")
dirname=$(dirname "$audio_dir")
extension="${filename##*.}"
basename="${filename%.*}"
# Check audio_dir to see if empty or if contains empty wav
bash $BASEDIR/check_folder.sh $audio_dir


# this is set in user's login .bashrc
#export PATH=/home/${user}/anaconda/bin:$PATH

# let's get our bearings: set CWD to the path of TALNet
cd $CLASSIFY

# Iterate over files
echo "Starting"
for f in `ls ${audio_dir}/*.wav`; do
    ./runTALNet.sh $f
    base=$(basename $f .wav)
    mv $audio_dir/${base}.frame_prob.mat ${audio_dir}/${base}_talnet.frame_prob.mat
done

echo "$0 finished running"
