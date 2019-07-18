if [ $# -lt 1 ]; then
  echo "Usage: sh WCE_from_SAD_outputs.sh <dirname> <sadname>"
  echo "where dirname is a folder containing audio .wav files and the corresponding .rttm files"
  echo "created using <sadname>."
  echo "Output .rttm files with WCE counts will be produced to <dirname>"
  exit 1
fi


SCRIPT_DIR=$(dirname "$0")
DATA_FOLDER=$1

#if [ -n "$2" ]; then
if [ "$#" -ne 2 ]; then
SADNAME="opensmile"
else
SADNAME=$2
fi

rm ${DATA_FOLDER}/wav_tmp/*.wav

python /home/vagrant/repos/WCE_VM/aux_VM/rttm_to_wavs.py ${DATA_FOLDER} ${SADNAME}

sh /home/vagrant/launcher/estimateWCE.sh  ${DATA_FOLDER}/wav_tmp/ ${DATA_FOLDER}/wav_tmp/WCE_output.txt

python /home/vagrant/repos/WCE_VM/aux_VM/WCE_to_rttm.py ${DATA_FOLDER}/wav_tmp/WCE_output.txt ${DATA_FOLDER}
