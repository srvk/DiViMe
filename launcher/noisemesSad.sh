#!/bin/bash
# noisemes_sad.sh
# Since the script is built to be launched outside of the vm, source
# the .bashrc which is not necessarily sourced!
source ~/.bashrc

source activate divime

# Absolute path to this script. /home/vagrant/launcher/noisemesSad.sh
SCRIPT=$(readlink -f $0)
# home folder
BASEDIR=/home/vagrant
YUNITATORDIR=/home/vagrant/repos/Yunitator

if [ $# -lt 1 ]; then
  echo "Usage: noisemesSad.sh <dirname> [--keep-temp] [--full-classes]"
  echo "where dirname is a folder on the host"
  echo "containing the wav files (/vagrant/dirname/ in the VM)"
  exit 1
fi

KEEPTEMP=false
FULLCLASSES=false
for a in ${BASH_ARGV[*]} ; do
  if [ $a == "--keep-temp" ]; then
    KEEPTEMP=true
  fi
  if [ $a == "--full-classes" ]; then
    FULLCLASSES=true
  fi
done

audio_dir=/vagrant/$1
TEMPNAME=feature
filename=$(basename "${audio_dir}")
dirname=$(dirname "${audio_dir}")
extension="${filename##*.}"
basename="${filename%.*}"

# Check audio_dir to see if empty or if contains empty wav
bash $BASEDIR/utils/check_folder.sh ${audio_dir}

# let's get our bearings: set CWD to path of Yunitator
cd $YUNITATORDIR

# make output folder for features, below input folder
mkdir -p ${audio_dir}/$TEMPNAME

# first features
echo "extracting features for speech activity detection"

for file in `ls ${audio_dir}/*.wav`; do
  ./extract-htk-vm2.sh $file $TEMPNAME
done

# Choose chunksize based off memory. Currently this is equivalent to 200
# frames per 100MB of memory. 
#   Ex: 3GB -> 6000 frames
#   Ex: 2048MB -> 4000 frames
# This setting was chosen arbitrarily and was successful for tests at 2GB-4GB.
chunksize=$(free | awk '/^Mem:/{print $2}')
let chunksize=$chunksize/100000*200

# then confidences
#python SSSF/code/predict/1-confidence-vm3.py $1
echo "detecting speech and non speech segments"

python yunified.py noisemes ${audio_dir} $chunksize

echo "finished detecting speech and non speech segments"

# take all the .rttm in /vagrant/data/hyp and move them to /vagrant/data - move features and hyp to another folder also.
for sad in `ls ${audio_dir}/hyp_sum/*.lab`; do
    base=$(basename $sad .lab)

    if $FULLCLASSES; then
      rttm_out=noisemesFull_${base}.rttm      
    else
      rttm_out=noisemesSad_${base}.rttm
    fi
    
    if [ -s $sad ]; then 
        if $FULLCLASSES; then
          grep '' $sad | awk -v fname=$base '{print $4 " " fname " " 1  " " $1  " " $2-$1 " " "<NA>" " " "<NA>"  " " $3  " "  "<NA>"}'   > ${audio_dir}/$rttm_out
        else 
          grep ' speech' $sad | awk -v fname=$base '{print $4 " " fname " " 1  " " $1  " " $2-$1 " " "<NA>" " " "<NA>"  " " $3  " "  "<NA>"}'   > ${audio_dir}/$rttm_out
        fi
    else
        touch ${audio_dir}/$rttm_out
    fi
done

# simple remove hyp and feature
if ! $KEEPTEMP; then
    rm -rf ${audio_dir}/hyp_sum ${audio_dir}/$TEMPNAME
fi

conda deactivate
