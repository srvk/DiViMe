#!/bin/bash
# Launcher onset routine
SCRIPT=$(readlink -f $0)
BASEDIR=`dirname $SCRIPT` # this is the home folder of this script
                          # not the home folder of the 'vagrant' user in the VM
REPOS=/home/vagrant/repos
UTILS=/home/vagrant/utils
CONF=/vagrant/conf
# end of launcher onset routine

### Read in variables from user
audio_dir=/vagrant/$1

### Other variables specific to this script
OSHOME=$REPOS/opensmile-2.3.0
CONFIG_FILE=$CONF/vad_segmenter_aclew.conf
OPENSMILE=SMILExtract
workdir=${audio_dir}/temp/opensmileSad
mkdir -p $workdir

### SCRIPT STARTS

if [ $# -lt 1 ]; then
  echo "USAGE: $0 <INPUT FILE>"
  exit 1
fi

KEEPTEMP=false
if [ $BASH_ARGV == "--keep-temp" ]; then
    KEEPTEMP=true
fi

filename=$(basename "$1")
dirname=$(dirname "$1")
extension="${filename##*.}"
basename="${filename%.*}"


cd $OSHOME/scripts/vad

# Use OpenSMILE 2.3.0
for sad in `ls ${audio_dir}/*.wav`; do
    file=$sad
    id=`basename $file`
    id=${id%.wav}
    > ${audio_dir}/${id}.txt #Make it empty if already present
    echo "Processing $id ..."
    echo $workdir/${id}.txt
    LD_LIBRARY_PATH=/usr/local/lib \
	$OPENSMILE \
	-C $CONFIG_FILE \
	-I $file \
	-turndebug 1 \
	-noconsoleoutput 1 \
	-saveSegmentTimes $workdir/${id}.txt \
	-logfile $workdir/opensmile-vad.log

	if [[ ! -f $workdir/${id}.txt ]]; then
        echo "No output produced by opensmileSad."
        echo "Generating empty rttm... (check the log file)"
        touch $workdir/${id}.txt
	fi
done

# clean up generated WAV files in working directory (tool_home/scripts/vad)
rm -f output_segment_*.wav

for output in $(ls $workdir/*.txt); do
    id=$(basename $output .txt)
    awk -F ';|,' -v FN=$id '{ start_on = $2; start_off = $3 ; print "SPEAKER "FN" 1 "start_on" "(start_off-start_on)" <NA> <NA> speech <NA>" }' $output > ${audio_dir}/opensmileSad_$id.rttm
done

# Delete temporary folder
if ! $KEEPTEMP; then
    rm -rf $workdir
fi
