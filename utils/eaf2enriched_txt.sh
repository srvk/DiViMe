#!/bin/bash
INPUT_FOLDER=$1
LANG=$2
SCRIPT_DIR=$(dirname "$0")

display_usage() {
    echo "Given a folder containing eaf file, creates an enriched txt version of them."
    echo "For each files, this script produces a txt version containing :"
    echo -e "\t onset"
    echo -e "\t off"
    echo -e "\t speaker"
    echo -e "\t cleaned up transcription"
    echo -e "\t number of words"
    echo -e "\t phonemized (or syllabified) version of the transcription"
    echo -e "\t number of syllables"

    echo "usage: $0 [input] [language]"
    echo "  input       The folder where to find the eaf files (REQUIRED)."
    echo "  output      The language of the transcription : english, spanish or tzeltal (REQUIRED)."
	exit 1
	}

if [ -z "$1" ] || [ -z "$2" ] || ! [[ $LANG =~ ^(english|spanish|tzeltal)$ ]]; then
    display_usage
fi

for eaf_path in /vagrant/$1/*.eaf; do
    eaf_path=${eaf_path#/vagrant/}
    without_extension="${eaf_path%.*}"
    echo "Converting $eaf_path files to ${without_extension}.txt ..."
    python $SCRIPT_DIR/eaf2txt.py -i $eaf_path

    echo "Enriching ${without_extension}.txt"
    $SCRIPT_DIR/selcha2clean.sh ${without_extension}.txt ${without_extension}_enriched.txt $LANG

    rm /vagrant/${without_extension}.txt
done