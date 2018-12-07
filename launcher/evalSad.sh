#!/bin/bash
# Since the script is built to be launched outside of the vm, source
# the .bashrc which is not necessarily sourced!
source ~/.bashrc

# Absolute path to this script. /home/user/bin/foo.sh
SCRIPT=$(readlink -f $0)
# Absolute path this script is in. /home/user/bin
BASEDIR=/home/vagrant
UTILS=$BASEDIR/utils
REPOS=$BASEDIR/repos
# Path to scoring tool NOTE: NOT dscore!
DSCOREDIR=$REPOS/dscore


# data directory
audio_dir=$1
filename=$(basename "${audio_dir}")
dirname=$(dirname "${audio_dir}")
extension="${filename##*.}"
basename="${filename%.*}"

# check system to evaluate - either LDC, OpenSAT or "MySystem"
sys_name=$2

if ! [[ $sys_name =~ ^(noisemesSad|tocomboSad|opensmileSad|lenaSad)$ ]]; then
    echo "Please Specify the System you wish to evaluate."
    echo "Choose between noisemesSad, tocomboSad, lenaSad and opensmileSad."
    exit
fi

KEEPTEMP=false
if [ $BASH_ARGV == "--keep-temp" ]; then
    KEEPTEMP=true
fi

# Set CWD to path of scoring tool
cd $DSCOREDIR

# pass vagrant-relative pathname to create_ref_sys
$UTILS/create_ref_sys.sh ${audio_dir} $sys_name true

# resolve to absolute path for rest of this script
audio_dir=/vagrant/${audio_dir}

OUTPUT_DF=${audio_dir}/${sys_name}_eval.df
REF=${audio_dir}/temp_ref
SYS=${audio_dir}/temp_sys
echo "evaluating"

python score_batch.py $OUTPUT_DF $REF $SYS

# small detail: remove the commas from the output
sed -i "s/,//g" $OUTPUT_DF
echo "done evaluating, check $1/${sys_name}_eval.df for the results"

# remove temps
if ! $KEEPTEMP; then
    rm -rf $REF $SYS
fi
