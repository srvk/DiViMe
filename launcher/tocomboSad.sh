#!/bin/bash
# Launcher onset routine
SCRIPT=$(readlink -f $0)
BASEDIR=`dirname $SCRIPT`
REPOS=/home/vagrant/repos
UTILS=/home/vagrant/utils
# end of launcher onset routine


### Read in variables from user
audio_dir=/vagrant/$1
trs_format=$2


### Other variables specific to this script
# create temp dir
#workdir=${audio_dir}/temp
#mkdir -p $workdir
workdir=`mktemp -d --tmpdir=${audio_dir}`
TOCOMBOSADDIR=$REPOS/To-Combo-SAD
MCR=/usr/local/MATLAB/MATLAB_Runtime/v93

### SCRIPT STARTS

if [ $# -lt 1 ]; then
  echo "Usage: tocombo_sad.sh <dirname>"
  echo "where dirname is a folder on the host"
  echo "containing the wav files (/vagrant/dirname/ in the VM)"
  exit 1
fi

KEEPTEMP=false
if [ $BASH_ARGV == "--keep-temp" ]; then
    KEEPTEMP=true
fi

filename=$(basename "${audio_dir}")
dirname=$(dirname "${audio_dir}")
extension="${filename##*.}"
basename="${filename%.*}"

# Check audio_dir to see if empty or if contains empty wav
bash /home/vagrant/utils/check_folder.sh ${audio_dir}

# let's get our bearings: set CWD to path of ToComboSAD
cd $TOCOMBOSADDIR

mkdir -p $workdir/feat
rm -f $workdir/filelist.txt
touch $workdir/filelist.txt

# create temp dir to store audio files with 1 channels, if needed (i.e. if audio to treat has 2 or more channels.)
# Indeed, To Combo Sad Fails when there are more than 1 channels.
for f in ${audio_dir}/*.wav; do
   # Check if audio has 1 channel or more. If it has more, use sox to create a temp audio file w/ 1 channel.
   n_chan=$(soxi $f | grep Channels | cut -d ':' -f 2)
   if [[ $n_chan -gt 1 ]]; then
       base=$(basename $f)
       sox -c $n_chan $f -c 1 $workdir/$base
       f=$workdir/$base
   fi

   echo $f >> $workdir/filelist.txt

done
echo "finished"

export LD_LIBRARY_PATH=$MCR/runtime/glnxa64:$MCR/bin/glnxa64:$MCR/sys/os/glnxa64:

# The 'DISPLAY= ' part prevents an X-Server from popping up
DISPLAY= ./run_get_TOcomboSAD_output_v3.sh $MCR $workdir/filelist.txt 0 0.5 $TOCOMBOSADDIR/UBMnodct256Hub5.txt

#convert to rttms
for f in `ls ${audio_dir}/*.ToCombo.txt ${workdir}/*.ToCombo.txt`; do
  echo converting to rttm $f
  bn=`basename $f .wav.ToCombo.txt`
  python $TOCOMBOSADDIR/tocombo2rttm.py $f $bn > ${workdir}/tocomboSad_$bn.rttm
done

# same in the temp folder which has the .wav that were not monochannel
#for f in ${workdir}/*.ToCombo.txt; do
#  bn=`basename $f .wav.ToCombo.txt`
#  python $TOCOMBOSADDIR/tocombo2rttm.py $f $bn > ${workdir}/tocomboSad_$bn.rttm
#done

# get the rttm
mv ${workdir}/*.rttm ${audio_dir}

# move the txt files and delete temporary folder
mv ${audio_dir}/*ToCombo.txt $workdir
if ! $KEEPTEMP; then
    rm -rf $workdir
fi
