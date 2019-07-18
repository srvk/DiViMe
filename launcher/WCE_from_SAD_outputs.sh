# Runs WCE for .wav files using the corresponding speech activity detection (SAD)
# segments defined in .rttm files named as <sadname>_<wavname>.rttm , all located
# in the same directory <dirname>.

if [ $# -lt 1 ]; then
  echo "Usage: sh WCE_from_SAD_outputs.sh <dirname> <sadname>"
  echo "where dirname is a folder containing audio .wav files and the corresponding .rttm files"
  echo "created using <sadname>."
  echo "Output .rttm files with WCE counts will be produced to <dirname>"
  exit 1
fi


SCRIPT_DIR=$(dirname "$0")
DATA_FOLDER=$1

if [ "$#" -ne 2 ]; then
SADNAME="tocomboSad"
else
SADNAME=$2
fi

if [ -d "${DATA_FOLDER}/wav_tmp/" ]; then
rm ${DATA_FOLDER}/wav_tmp/*.wav
fi

python /home/vagrant/repos/WCE_VM/aux_VM/rttm_to_wavs.py ${DATA_FOLDER} ${SADNAME}

echo "Running WCE..."
sh /home/vagrant/launcher/estimateWCE.sh  ${DATA_FOLDER}/wav_tmp/ ${DATA_FOLDER}/wav_tmp/WCE_output.txt > /dev/null 2>&1

python /home/vagrant/repos/WCE_VM/aux_VM/WCE_to_rttm.py ${DATA_FOLDER}/wav_tmp/WCE_output.txt ${DATA_FOLDER}
echo "WCE complete."
