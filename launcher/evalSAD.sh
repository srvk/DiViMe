#!/bin/bash
# Launcher onset routine
source ~/.bashrc
SCRIPT=$(readlink -f $0)
BASEDIR=`dirname $(dirname $SCRIPT )`
conda_dir=$BASEDIR/anaconda/bin
REPOS=$BASEDIR/repos
UTILS=$BASEDIR/utils
# end of launcher onset routine


### Read in variables from user
# data directory
audio_dir=/vagrant/$1
filename=$(basename "$audio_dir")
dirname=$(dirname "$audio_dir")
extension="${filename##*.}"
basename="${filename%.*}"

# check system to evaluate
system=$2


### Other variables specific to this script
# Path to scoring tool NOTE: NOT dscore!
ldcSad_DIR=$REPOS/ldc_sad_hmm
# create temp dir
workdir=$audio_dir
mkdir -p $workdir


### SCRIPT STARTS
if [[ $system = "ldcSad" ]]; then
    sys_name="ldcSad"
elif [[ $system = "noisemesSad" ]]; then
    sys_name="noisemesSad"
elif [[ $system = "tocombosad" ]]; then
    sys_name="tocombo_sad"
elif [[ $system = "opensmileSad" ]]; then
    sys_name="opensmileSad"
elif [[ $system = "lenaSad" ]]; then
    sys_name="lenaSad"

else
    echo "Please Specify the System you wish to evaluate."
    echo "Choose between ldcSad, noisemeSad, tocomboSad, opensmileSad, lenaSad."
    exit
fi


# Set CWD to path of scoring tool
cd $ldcSad_DIR

#mkdir

$UTILS/create_ref_sys.sh $audio_dir $sys_name true

echo "evaluating"
#$conda_dir/python score_batch.py $audio_dir/${sys_name}_eval.df $workdir/temp_ref $workdir/temp_sys
# create /vagrant/results if it doesn't exist
echo "filename	DCF	FA	MISS" > $audio_dir/${sys_name}_eval.df
for lab in `ls $workdir/temp_sys/*.lab`; do
    base=$(basename $lab .lab)
    if [ ! -s $workdir/temp_ref/$base.lab  ]; then
        if [ ! -s $workdir/temp_sys/$base.lab ]; then
            echo $base"	0.00%	0.00%	0.00%" >> $audio_dir/${sys_name}_eval.df
        else
            echo $base"	25.00%	100.00%	0.00%" >> $audio_dir/${sys_name}_eval.df
        fi
    elif [ ! -s $workdir/temp_sys/$base.lab ] && [ -s $workdir/temp_ref/$base.lab ]; then
        echo $base"	75.00%	0.00%	100.00%" >> $audio_dir/${sys_name}_eval.df
    else
        $conda_dir/python score.py $workdir/temp_ref $lab | awk -v var="$base" -F" " '{if ($1=="DCF:") {print var"\t"$2"\t"$4"\t"$6}}' >> $audio_dir/${sys_name}_eval.df
    fi

done
# small detail: remove the commas from the output
sed -i "s/,//g" $audio_dir/${sys_name}_eval.df
echo "done evaluating, check $1/${sys_name}_eval.df for the results"

# remove temps
rm -rf $workdir/temp_ref $workdir/temp_sys

