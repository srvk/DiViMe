#!/bin/bash

# Launcher onset routine
SCRIPT=$(readlink -f $0)
BASEDIR=/home/vagrant
REPOS=$BASEDIR/repos
UTILS=$BASEDIR/utils
DSCOREDIR=$REPOS/dscore
# end of launcher onset routine


display_usage() {
    echo "Usage: evalDiar.sh <dirname> <system>"
    echo "where dirname is the name of the folder"
    echo "containing the wav files, and system"
    echo "specifies which system you want to evaluate"
    echo "System choices are :"
    echo "  - noisemesSad"
    echo "  - opensmileSad"
    echo "  - tocomboSad"
    echo "  - diartk_noisemesSad"
    echo "  - diartk_opensmileSad"
    echo "  - diartk_tocomboSad"
    echo "  - diartk_rttm"
    echo "  - yunitate"
    echo "  - lenaSad"
    exit 1;

}

### Read in variables from user
audio_dir=/vagrant/$1
model=$2

if ! [[ $model =~ ^(noisemesSad| opensmileSad| tocomboSad | diartk_noisemesSad | diartk_opensmileSad | diartk_rttm |yunitate|lenaSad)$ ]]; then
    display_usage
fi

KEEPTEMP=false
if [ $BASH_ARGV == "--keep-temp" ]; then
    KEEPTEMP=true
fi


# Set CWD to path of Dscore
cd $DSCOREDIR

if [[ $model =~ ^(diartk|yuniseg) ]]; then
    trs_format=$3
    case $trs_format in
      "noisemesSad")
       sys_name=$model"_noisemesSad"
      ;;
      "tocomboSad")
       sys_name=$model"_tocomboSad"
      ;;
      "opensmileSad")
       sys_name=$model"_opensmileSad"
      ;;
      "textgrid")
       sys_name=$model"_goldSad"
       for wav in `ls ${audio_dir}/*.wav`; do
           base=$(basename $wav .wav)
           python /home/vagrant/utils/textgrid2rttm.py ${audio_dir}/${basename}.TextGrid ${audio_dir}/${basename}.rttm
       done
      ;;
      "eaf")
        sys_name=$model"_goldSad"
       for wav in `ls ${audio_dir}/*.wav`; do
           base=$(basename $wav .wav)
           python /home/vagrant/utils/elan2rttm.py ${audio_dir}/${basename}.eaf ${audio_dir}/${basename}.rttm
       done
       ;;
       "rttm")
        sys_name=$model"_goldSad"
       ;;
       *)
        echo "ERROR: You're trying to evaluate diartk, but the speech activity detection you specified is not recognized:"
        echo "  noisemesSad"
        echo "  textgrid"
        echo "  eaf"
        echo "  rttm"
        echo "Now exiting..."
        exit 1
       ;;
    esac
elif [ "$2" == "yunitate" ]; then
    sys_name="yunitator"
elif [ "$2" == "lenaSad" ]; then
    sys_name="lena"
fi

echo $UTILS/create_ref_sys.sh $1 $sys_name
$UTILS/create_ref_sys.sh $1 $sys_name

echo "evaluating"

python score_batch.py ${audio_dir}/${sys_name}_eval.df ${audio_dir}/temp_ref ${audio_dir}/temp_sys

# Check if some gold files are empty. If so, add a line in the eval dataframe
for fin in `ls ${audio_dir}/temp_ref/*.rttm`; do
    base=$(basename $fin .rttm)
    if [ ! -s ${audio_dir}/temp_ref/$base.rttm ]; then
        if [ ! -s ${audio_dir}/temp_sys/$base.rttm ]; then
            echo $base"	0	NA	NA	NA	NA	NA	NA	NA	NA" >> ${audio_dir}/${sys_name}_eval.df
        else
            echo $base"	100	NA	NA	NA	NA	NA	NA	NA	NA" >> ${audio_dir}/${sys_name}_eval.df
        fi
    elif [ ! -s ${audio_dir}/temp_sys/$base.rttm ] && [ -s ${audio_dir}/temp_ref/$base.rttm ]; then
        echo $base"	100	NA	NA	NA	NA	NA	NA	NA	NA" >> ${audio_dir}/${sys_name}_eval.df
    fi
done

echo "done evaluating, check $1/${sys_name}_eval.df for the results"
# remove temps
if ! $KEEPTEMP; then
    rm -rf ${audio_dir}/temp_ref ${audio_dir}/temp_sys
fi
