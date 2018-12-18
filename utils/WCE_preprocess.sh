# Perform pre-porcessing of speech data for WCE module training and/or cross-validation. Requires
# wav-files following ACLEW file naming convention, and .eafs containing daylong annotations.

SCRIPT_DIR=$(dirname "$0")

WAV_FOLDER=$1
EAF_FOLDER=$2
LANGUAGE=$3

display_usage() {
    echo "usage: $0 [wav_folder] [eaf_folder] [language] [SAD]"
    echo "  wav_folder   The folder where to find the wav files (REQUIRED)."
    echo "  eaf_folder   The folder where to find the eaf files (REQUIRED)."
    echo "  language     The language of the transcription : english, spanish or tzeltal (REQUIRED)."  
    echo "  SAD          The SAD used to detect speech: opensmileSad (DEFAULT), tocomboSad"
    echo ""
    echo "Wav files have to follow ACLEW file naming conventions:"
    echo "COR_baby_yyyyyy_zzzzzz.wav where COR is the three-character ID of the corpus, baby is four-digit"
    echo "identifier of the baby, and yyyyyy and zzzzzz are 2/5min segment onsets and offsets in seconds"
    echo "measured from the beginning of the daylong file, e.g., BER_0396_005220_005340.wav"
    echo ""
    echo "Eaf-files must be of form xxxx.eaf, where xxxx is the babyID corerresponding to the .wav files."
	exit 1
	}

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || ! [[ $LANGUAGE =~ ^(english|spanish|tzeltal)$ ]]; then
    display_usage
fi

if [ -z "$4" ]; then
    SAD="opensmileSad"
else
    SAD=$4
fi;



# Check that WCE_VM temp dir exists and create if needed
if [ ! -d "/vagrant/data/WCE_VM_TEMP/" ]; then
    mkdir /vagrant/data/WCE_VM_TEMP/    
    mkdir /vagrant/data/WCE_VM_TEMP/RTTM/    
    mkdir /vagrant/data/WCE_VM_TEMP/ENRICH/    
fi;


# 1) Put .wav files to {wav_folder} under {data} and .eafs to another {eaf_folder}.

# 2) Run: SAD on the data

echo "Running SAD on the .wav files"

~/launcher/${SAD}.sh $WAV_FOLDER

#for file in "/vagrant/${WAV_FOLDER}/*.rttm"; do cp "$file" /vagrant/data/WCE_VM_TEMP/RTTM/;done
#cp "/vagrant/${WAV_FOLDER}*.rttm" /vagrant/data/WCE_VM_TEMP/RTTM/

curdir=$(pwd);cd /vagrant/${WAV_FOLDER};cp *.rttm /vagrant/data/WCE_VM_TEMP/RTTM/;cd $curdir

# 3) Call eaf2enriched.sh to create .rttm files from .eaf files

echo "Converting .eafs to .rttms..."

~/utils/eaf2enriched_txt.sh ${EAF_FOLDER} english

curdir=$(pwd);cd /vagrant/${EAF_FOLDER};cp *enriched.txt /vagrant/data/WCE_VM_TEMP/ENRICH/;cd $curdir

# 4) Call SADsplit to create annotation file for each SAD output segment

echo "Creating .wav files and annotation files for each SAD segment..."

~/repos/WCE_VM/aux_VM/SADsplit.sh /vagrant/data/WCE_VM_TEMP/ENRICH/ /vagrant/data/WCE_VM_TEMP/RTTM/ $WAV_FOLDER

echo " "
echo "WCE data preprocessing complete. Use WCE_LOSO_eval.sh to run leave-one-subject-out validation
of the system, or WCE_fulltrain.sh to adapt the WCE for all the data."

# 5) Do leave-one-subject-out validation of the WCE 

#~/launcher/WCE_LOSO_eval.sh

# 6) Train with all data

#~/launcher/WCE_fulltrain.sh
