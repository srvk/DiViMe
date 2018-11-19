#!/usr/bin/env bash
# Given an input file (containing raw text), an output one, and a language (english, spanish or tzeltal)
# Write in the output file the phonemization (if english) or the syllabification (if spanish or tzeltal) of it,
# and count the number of syllables
### Script parameters
INPUT=$1
OUTPUT=$2
LANG=$3
VOWELS=$4
###
DATA_DIR="/vagrant"
INPUT=$DATA_DIR"/"$INPUT
OUTPUT=$DATA_DIR"/"$OUTPUT
DIRNAME=${INPUT%/*}
EXTENSION=${INPUT##*.}

display_usage() {
    echo "Given the path to a file (.tmp or .txt) containing sentences, a language (english, spanish or tzeltal),"
    echo "and a list of vowels, create a .syll file containing the original sentence, the phonemized/syllabified"
    echo "version of it, and the number of syllables present in the original sentence."
    echo "usage: $0 [input] [output] [language] [vowels]"
    echo "  input       The file path where to find the transcription. Has to be txt or tmp extension. (REQUIRED)"
    echo "  output      The output path. (REQUIRED)"
    echo "  language    The language of the transcription (OPTIONAL, default = english)"
    echo "  vowels      The list of vowels of the language if language set on spanish or tzeltal (OPTIONAL, default = aeiou)"
	exit 1
	}

if [ -z "$1" ] || [ -z "$2" ] || ! [[ $EXTENSION =~ ^(txt|tmp)$ ]]; then
    display_usage
fi

if [ -z "$3" ]; then
        echo "No languages has been provided. Setting this parameter to english."
        LANG="english"
fi

if [ "$3" == "spanish" ] || [ "$3" == "tzeltal" ]; then
    if [ -z "$4" ]; then
        VOWELS="aeiouáéíóúü"
        echo "Language set on spanish or tzeltal. But no vowels have been provided."
        echo "Setting this parameter to $VOWELS"
        echo $VOWELS > $DIRNAME"/"$LANG"-Vowels.txt"
    fi
fi

if [ "$3" == "english" ]; then
    echo "Pĥonemizing $INPUT ..."
    # Phonemize the clean version
    phonemize ${INPUT} -o ${OUTPUT}.tmp -s -

    ## Append number of syllables to the phonemized transcription
    cat ${OUTPUT}.tmp | awk -F- '{print $0"\t"NF-1}' > ${OUTPUT}
elif [ "$3" == "spanish" ] || [ "$3" == "tzeltal" ]; then
    # Changing upper case to lower case
    cat $INPUT | tr '[:upper:]' '[:lower:]' | tr 'A-ZÂÁÀÄÊÉÈËÏÍÎÖÓÔÖÚÙÛÑÇ' 'a-zâáàäêéèëïíîöóôöúùûñç' > $INPUT.tmp
    # Get all the different words in the corpus
    # and get the different onsets by removing what follows the first vowel
    cat $INPUT.tmp | tr ' ' '\n' | sort | uniq |
                    sed 's/[aeiou].*//g' | grep .| uniq >  $DIRNAME"/"$LANG"-ValidOnsets.txt"
    SCRIPT_DIR=$(dirname "$0")
    perl $SCRIPT_DIR/catspa-syllabify-corpus.pl $LANG $INPUT.tmp $OUTPUT.tmp

    ## Append number of syllables
    cat $OUTPUT.tmp | awk -F'/' '{print $0"\t"NF-1}' > $OUTPUT

    rm $INPUT.tmp $DIRNAME"/"$LANG"-ValidOnsets.txt" $DIRNAME"/"$LANG"-Vowels.txt"
else
    echo "Language unknown."
    exit 1
fi

echo "Done."

rm $OUTPUT.tmp


