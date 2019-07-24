#!/bin/bash
# Since the script is built to be launched outside of the vm, source
# the .bashrc which is not necessarily sourced!
source ~/.bashrc

source activate divime

# run Yunitator with hard coded models & configs 

# Absolute path to this script. /home/vagrant/launcher/yunitate.sh
SCRIPT=$(readlink -f $0)
# Absolute path this script is in. /home/vagrant/launcher
BASEDIR=`dirname $SCRIPT`
# Path to Yunitator (go one folder up and to Yunitator)
YUNITATDIR=/home/vagrant/repos/Yunitator

if [ $# -lt 1 ] || [ $# -gt 3 ]; then
  echo "Usage: $0 <dirname> <optional arg amongst [old, english, universal]>"
  echo "where dirname is the name of the folder"
  echo "containing the wav files, and the second parameter (optional)"
  echo "whether to use the old model, the english model, or the universal one."
  exit 1
fi

DELSIL=true
KEEPTEMP=false
if [ $BASH_ARGV == "--keep-temp" ]; then
    KEEPTEMP=true
fi

MODE=$2 # old, english or universal
if [[ $MODE == "" ]]; then
    MODE="old"
fi

case $MODE in
   old|english|universal)
    ;;
   *)
     echo "MODE = $MODE but needs to be amongst {old, english, universal}";
     exit 1;;
esac

audio_dir=/vagrant/$1
TEMPNAME=Yunitemp
YUNITEMP=${audio_dir}/$TEMPNAME
filename=$(basename "${audio_dir}")
dirname=$(dirname "${audio_dir}")
extension="${filename##*.}"
basename="${filename%.*}"

# Check audio_dir to see if empty or if contains empty wav
bash /home/vagrant/utils/check_folder.sh ${audio_dir}

# let's get our bearings: set CWD to the path of Yunitator
cd $YUNITATDIR

# make output folder for features, below input folder
mkdir -p $YUNITEMP

# Iterate over files
echo "Starting $0"
if true; then
    # I think it is safe to do the feature extraction in parallel by default
    ls ${audio_dir}/*.wav | xargs -P `nproc` -i ./extract-htk-vm2.sh '{}' $TEMPNAME
else
for f in `ls ${audio_dir}/*.wav`; do
    basename=`basename $f .wav`
    # first features
    ./extract-htk-vm2.sh $f $TEMPNAME
done
fi


# Choose chunksize based off memory. Currently this is equivalent to 200
# frames per 100MB of memory. 
#   Ex: 3GB -> 6000 frames
#   Ex: 2048MB -> 4000 frames
# This setting was chosen arbitrarily and was successful for tests at 2GB-4GB.
chunksize=$(free | awk '/^Mem:/{print $2}')
let chunksize=$chunksize/100000*200
[ $chunksize -eq 0 ] && echo You seem to have very little free memory. Things may be slow:
[ $chunksize -eq 0 ] && free
[ $chunksize -eq 0 ] && let chunksize=1000

echo python yunified.py yunitator $audio_dir $chunksize $MODE
python yunified.py yunitator $audio_dir $chunksize $MODE # MODE equal to old, english or universal

for f in `ls $YUNITEMP/*.rttm.sorted`; do
    filename=$(basename "$f")
    basename="${filename%.*}"

    sort -V -k3 $f > $YUNITEMP/$basename
done 

echo "$0 finished running"

# take all the .rttm in ${audio_dir}/Yunitemp/ and move them to /vagrant/data
for sad in `ls $YUNITEMP/*.rttm`; do
    _rttm=$(basename $sad)
    rttm=${audio_dir}/yunitator_${MODE}_${_rttm}
    if $DELSIL; then
	# Remove not needed SIL lines
	sed -i '/ SIL /d' $sad
    fi
    mv $sad $rttm
done

# simply remove hyp and feature
if ! $KEEPTEMP; then
    rm -rf $YUNITEMP
fi

conda deactivate
