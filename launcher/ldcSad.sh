#!/bin/bash
# Launcher onset routine
source ~/.bashrc
SCRIPT=$(readlink -f $0)
BASEDIR=/home/vagrant
conda_dir=$BASEDIR/anaconda/bin
REPOS=$BASEDIR/repos
UTILS=$BASEDIR/utils
# end of launcher onset routine

### Read in variables from user
audio_dir=/vagrant/$1

### Other variables specific to this script
LDC_SAD_DIR=$REPOS/ldc_sad_hmm
workdir=$audio_dir/temp/diartk
mkdir -p $workdir

### SCRIPT STARTS
if [ $# -lt 1 ]; then
  echo "Usage: ldcSad.sh <dirname>"
  echo "where dirname is the name of the folder"
  echo "containing the wav files"
  exit 1
fi

KEEPTEMP=false
if [ $BASH_ARGV == "--keep-temp" ]; then
    KEEPTEMP=true
fi

# Check audio_dir to see if empty or if contains empty wav
bash $UTILS/check_folder.sh $audio_dir

# Set CWD as LDC_SAD_HMM
cd $LDC_SAD_DIR

# launch ldc
$conda_dir/python perform_sad.py  -L $workdir $audio_dir/*.wav
echo "finished using ldcSad_hmm. Please look inside $1 to see the output in *.rttm format"

# move all files to name them correctly
for wav in `ls $audio_dir/*.wav`; do
    # retrieve filename and remove .wav
    base=$(basename $wav .wav)
    rttm_out=$workdir/ldcSad_${base}.rttm
    if [ -s $workdir/${base}.lab ]; then 
        grep ' speech' $workdir/${base}.lab | awk -v fname=$base '{print "SPEAKER" " " fname " " 1  " " $1  " " $2-$1 " " "<NA>" " " "<NA>"  " " $3  " "  "<NA>"}'   > $rttm_out
    else
        touch $rttm_out
    fi
done

if ! $KEEPTEMP; then
    rm -rf $workdir
fi
