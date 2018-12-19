#!/bin/bash

# run YuniSeg with hard coded models & configs found here and in /vagrant
# assumes Python environment in /home/${user}/

# Absolute path to this script. /home/user/bin/foo.sh
SCRIPT=$(readlink -f $0)
# Absolute path this script is in. /home/user/bin
BASEDIR=`dirname $SCRIPT`
# Path to YuniSeg (go one folder up and to Yunitator)
YUNITATDIR=$(dirname $BASEDIR)/Yunitator
# let's get our bearings: set CWD to the path of Yunitator
cd $YUNITATDIR

if [ $# -ne 2 ]; then
  echo "Usage: $0 <dirname> <SADtoolname>"
  echo "where dirname is the name of the folder"
  echo "containing the wav and rttm files"
  echo "and SADtoolname is the SAD to use."
  echo "Choices are:"
  echo "  ldc_sad"
  echo "  noisemes"
  echo "  tocombosad"
  echo "  opensmile"
  echo "  textgrid"
  echo "  eaf"
  echo "  rttm"
  exit 1
fi

audio_dir=/vagrant/$1
trs_format=$2

# Check audio_dir to see if empty or if contains empty wav
bash $BASEDIR/check_folder.sh ${audio_dir}

# Iterate over files
echo "Starting"
for f in `ls ${audio_dir}/*.wav`; do
    filename=$(basename "$f")
    basename="${filename%.*}"
    echo "treating $basename"
    
    # output filename produced by runYuniSegs
    outfile=${audio_dir}/$basename.yuniSeg.rttm

    case $trs_format in
      "ldc_sad")
       sys="ldcSad"
       model_prefix="ldc_sad_"
      ;;
      "")
       # add default case
       echo "Warning: no SAD source specified, using Noisemes by default, at your own risk."
       echo "Next time, please specify SAD."
       sys="noisemesSad"
       model_prefix="noisemes_sad_"
      ;;
      "noisemes")
       sys="noisemesSad"
       model_prefix="noisemes_sad_"
      ;;
      "tocombosad")
       sys="tocomboSad"
       model_prefix="tocombo_sad_"
      ;;
      "opensmile")
       sys="opensmileSad"
       model_prefix="opensmile_sad_"
      ;;
      "textgrid") 
       sys="goldSad"
       model_prefix=${trs_format}_
       python /home/vagrant/utils/textgrid2rttm.py ${audio_dir}/${basename}.TextGrid ${trs_format}_${basename}.rttm
      ;;
      "eaf")
       sys="goldSad"
       model_prefix=${trs_format}_
       python /home/vagrant/utils/elan2rttm.py ${audio_dir}/${basename}.eaf ${trs_format}_${basename}.rttm
      ;;
      "rttm")
       sys="goldSad"
       model_prefix=""
      ;;
      *)
       echo "ERROR: please choose SAD system between:"
       echo "  ldc_sad"
       echo "  noisemes"
       echo "  tocombosad"
       echo "  opensmile"
       echo "  textgrid"
       echo "  eaf"
       echo "  rttm"
       echo "Now exiting..."
       exit 1
      ;;
    esac

    ./runYuniSegs.sh $f ${audio_dir}/${model_prefix}${basename}.rttm
    cp $outfile ${audio_dir}/yuniseg_${sys}_${basename}.rttm

    if [ ! -s ${audio_dir}/yuniseg_${sys}_${basename}.rttm ]; then
        # if diarization failed, still write an empty file...
        touch ${audio_dir}/yuniseg_${sys}_${basename}.rttm
    fi
done

echo "$0 finished running"

# simply remove hyp and feature
rm $outfile
rm -rf ${audio_dir}/Yunitemp
