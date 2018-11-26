#!/bin/bash
# Since the script is built to be launched outside of the vm, source
# the .bashrc which is not necessarily sourced!
source ~/.bashrc
conda_dir=/home/vagrant/anaconda/bin

# run OpenSAT with hard coded models & configs found here and in /vagrant
# assumes Python environment in /home/${user}/

# Absolute path to this script. /home/user/bin/foo.sh
SCRIPT=$(readlink -f $0)
# Absolute path this script is in. /home/user/bin
BASEDIR=`dirname $SCRIPT`
#| Path to VCM (go one folder up and to VCM)
VCMDIR=/home/vagrant/repos/vcm

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
bash $BASEDIR/check_folder.sh $audio_dir

KEEPTEMP=false
if [ $BASH_ARGV == "--keep-temp" ]; then
    KEEPTEMP=true
fi



# this is set in user's login .bashrc
#export PATH=/home/${user}/anaconda/bin:$PATH

# let's get our bearings: set CWD to the path of VCM
cd $VCMDIR

# Iterate over files
echo "Starting"
for f in `ls $audio_dir/*.wav`; do
   echo $f
    ./runVCM.sh $f
done

echo "$0 finished running"

# take all the .rttm in $audio_dir/VCMtemp/ and move them to /vagrant/data
for vcm in `ls $audio_dir/VCMtemp/*.rttm`; do
    _rttm=$(basename $vcm)
    rttm=$audio_dir/${_rttm}
    mv $vcm $rttm
done

# simply remove hyp and feature
if ! $KEEPTEMP; then
    rm -rf $audio_dir/VCMtemp
fi
