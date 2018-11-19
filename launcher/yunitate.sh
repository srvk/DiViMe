#!/bin/bash
# Since the script is built to be launched outside of the vm, source
# the .bashrc which is not necessarily sourced!
source ~/.bashrc
conda_dir=/home/vagrant/anaconda/bin

# run Yunitator with hard coded models & configs 
# assumes Python environment in /home/vagrant/anaconda/bin

# Absolute path to this script. /home/vagrant/launcher/yunitate.sh
SCRIPT=$(readlink -f $0)
# Absolute path this script is in. /home/vagrant/launcher
BASEDIR=`dirname $SCRIPT`
# Path to Yunitator (go one folder up and to Yunitator)
YUNITATDIR=/home/vagrant/repos/Yunitator

if [ $# -ne 1 ]; then
  echo "Usage: $0 <dirname>"
  echo "where dirname is the name of the folder"
  echo "containing the wav files"
  exit 1
fi

audio_dir=/vagrant/$1
filename=$(basename "$audio_dir")
dirname=$(dirname "$audio_dir")
extension="${filename##*.}"
basename="${filename%.*}"
# Check audio_dir to see if empty or if contains empty wav
bash /home/vagrant/utils/check_folder.sh $audio_dir


# this is set in user's login .bashrc
#export PATH=/home/${user}/anaconda/bin:$PATH

# let's get our bearings: set CWD to the path of Yunitator
cd $YUNITATDIR

# Iterate over files
echo "Starting"
for f in `ls $audio_dir/*.wav`; do
    ./runYunitator.sh $f
done

echo "$0 finished running"

# take all the .rttm in $audio_dir/Yunitemp/ and move them to /vagrant/data
for sad in `ls $audio_dir/Yunitemp/*.rttm`; do
    _rttm=$(basename $sad)
    rttm=$audio_dir/yunitator_${_rttm}
    # Remove not needed SIL lines
    # sed -i '/ SIL /d' $sad
    mv $sad $rttm
done

# simply remove hyp and feature
rm -rf $audio_dir/Yunitemp
