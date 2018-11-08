#!/usr/bin/env bash
# Given a txt file containing the following fields : onset offset transcription receiver speaker_tier (Note that eaf2txt.py generates such kind of files)
# Returns an enriched version of it by cleaning the transcription field, syllabifying (or phonemizing it), counting the number of words, and the number of syllables

LC_CTYPE=C
#########VARIABLES
#Variables that have been passed by the user
SELFILE=$1
ORTHO=$2
LANG=$3
#########


display_usage() {
    echo "Given a txt files containing the following fields : onset offset transcription receiver speaker_tier"
    echo "and a language, returns an enriched version of this file by :"
    echo -e "\t 1) Cleaning the transcription field (removing human-made errors)"
    echo -e "\t 2) Counting the number of words"
    echo -e "\t 3) Phonemizing (if english)/Syllabifying (if spanish or tzeltal) the transcription"
    echo -e "\t 4) Counting the number of syllables"
    echo "usage: $0 [input] [output] [language]"
    echo "  input       The file path where to find the input txt file (REQUIRED)."
    echo "  output      The output path (REQUIRED)."
    echo "  language    The language of the transcription : english, spanish or tzeltal (REQUIRED)."
	exit 1
	}

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || ! [[ $LANG =~ ^(english|spanish|tzeltal)$ ]]; then
    display_usage
fi

# Get relative and absolute paths that we need.
DATA_DIR=/vagrant
SELFILE_ABS="$DATA_DIR/$SELFILE"
ORTHO_ABS="$DATA_DIR/$ORTHO"
DIRNAME_ABS=$(dirname "${ORTHO_ABS}")
CLEAN_TRANSCRIPT_ABS=$DIRNAME_ABS"/clean_transcript.txt"
PHONEMIZED_ABS=$DIRNAME_ABS"/phonemized.txt"
DIRNAME_REL=$(dirname "${ORTHO}")
CLEAN_TRANSCRIPT_REL=$DIRNAME_REL"/clean_transcript.txt"
PHONEMIZED_REL=$DIRNAME_REL"/phonemized.txt"

echo "Cleaning $SELFILE"


### HANDLING REPETITIONS ###
###    word [x2]         ###
### or <phrase> [x2]     ###
cut -f 4 -d$'\t' $SELFILE_ABS |
sed "s/\[ \+/\[/g" |
sed "s/ \+\[/\[/g" |
sed -r "s/\[X([0-9]+)/\[x\1/g" |
sed "s/> \+/>/g" > ${CLEAN_TRANSCRIPT_ABS}.tmp

python -c "
import re
for line in open(\"${CLEAN_TRANSCRIPT_ABS}.tmp\"):

    if '<' in line and '>' in line:
        newline = re.sub('<(.*)>\[x([0-9]+)\]', r'\1 \2', line)
        if newline != line:
            n = int(newline[-2:-1])
            newline = newline[:-2]*n
        else:
            newline = line
    else:
        reg = re.sub('(.*)\[x([0-9]+)\]', r'\1\2', line)
        newline=[]
        for word in reg.split():
            if word[-1].isdigit():
                newline += [word[:-1]]*int(word[-1])
            else:
                newline += [word]
        newline = ' '.join(newline)
    newline = newline.rstrip() # Remove all \newline and let the print function puts only one of them
    print(newline)
" > ${CLEAN_TRANSCRIPT_ABS}2.tmp


### CLEAN human-made inconsistencies

cat ${CLEAN_TRANSCRIPT_ABS}2.tmp |
sed "s/\_/ /g" |
sed '/^0(.*) .$/d' |
sed  's/\..*$//g' | #this code deletes bulletpoints (Û+numbers
sed  's/\?.*$//g' |
sed  's/\!.*$//g' |
tr -d '\"' |
tr -d '\^' | #used to be identical to previous line
tr -d '\/' |
sed 's/\+/ /g' |
tr -d '\.' |
tr -d '\?' |
tr -d '!' |
tr -d ';' |
tr -d '\<' |
tr -d '\>' |
tr -d ','  |
tr -d ':'  |
tr -d '~'  |
sed 's/&=[^ ]*//g' |
sed 's/&[^ ]*//g' |  #delete words beginning with & ##IMPORTANT CHOICE COULD HAVE CHOSEN TO NOT DELETE SUCH NEOLOGISMS/NONWORDS
sed 's/\[[^[]*\]//g' | #delete comments
#sed 's/([^(]*)//g' | #IMPORTANT CHOICE -- UNCOMMENT THIS LINE AND COMMENT OUT THE NEXT TO DELETE MATERIAL NOTED AS NOT PRONOUNCED
sed 's/(//g' | sed 's/)//g' | #IMPORTANT CHOICE -- UNCOMMENT THIS LINE AND COMMENT OUT THE PRECEDING TO REMOVE PARENTHESES TAGGING UNPRONOUNCED MATERIAL
sed 's/xxx//g' |
sed 's/www//g' |
sed 's/XXX//g' |
sed 's/yyy//g' |
sed 's/0*//g' |
sed 's/[^ ]*@s:[^ ]*//g' | #delete words tagged as being a switch into another language
#sed 's/[^ ]*@o//g' | #delete words tagged as onomatopeic
sed 's/@[^ ]*//g' | #delete tags beginning with @ IMPORTANT CHOICE, COULD HAVE CHOSEN TO DELETE FAMILIAR/ONOMAT WORDS
sed "s/\'/ /g"  |
tr -s ' ' |
sed 's/ $//g' |
sed 's/^ //g' |
sed 's/^[ ]*//g' |
sed 's/ $//g' |
#sed '/^$/d' | # We don't want to remove end lines here
sed '/^ $/d' |
sed 's/\^//g' |
sed 's/\-//g' |
sed 's/\[\=//g' | # We observed [= occurrences that we're not interested in. Has to be careful about that one
sed 's/[0-9]//g' | # We remove all of the remaining numbers
#tr -d '\t' |
awk '{gsub("\"",""); print}' > ${CLEAN_TRANSCRIPT_ABS}3.tmp

SCRIPT_DIR=$(dirname "$0")
$SCRIPT_DIR/syllabify.sh ${CLEAN_TRANSCRIPT_REL}3.tmp ${PHONEMIZED_REL} $LANG

## Append number of words to the clean transcription
cat ${CLEAN_TRANSCRIPT_ABS}3.tmp | awk -F'[ ]' '{print $0"\t"NF}' > ${CLEAN_TRANSCRIPT_ABS}

## Concatenate those 2 files
python -c "
import re
transcript_f = open(\"${CLEAN_TRANSCRIPT_ABS}\")
phonemized_f = open(\"${PHONEMIZED_ABS}\")

for transcript_l in transcript_f.readlines():
    nb_words = transcript_l.split('\t')[1]
    if int(nb_words) == 0:
        x=2
        print(\"\t0\t\t0\")
    else:
        phoneme_l = phonemized_f.readline()
        transcript_l = transcript_l.rstrip()
        phoneme_l = phoneme_l.rstrip()
        print(transcript_l+'\t'+phoneme_l)
" > $ORTHO_ABS.tmp

## Now we concatenate the original csv files and the clean ortho (by column)
### Extract everything except transcript column from the original file
cut -f1,2,3,5 -d$'\t' $SELFILE_ABS > ${ORTHO_ABS}2.tmp

### Concatenate the latter columns to the clean one contained in _tmp3.txt
paste -d$'\t' ${ORTHO_ABS}2.tmp ${ORTHO_ABS}.tmp > $ORTHO_ABS

##This is to process all the "junk" that were generated when making the
##changes from included to ortho.  For e.g., the cleaning process
##generated double spaces between 2 words (while not present in
##included)
sed -i -e 's/ $//g' $ORTHO_ABS

# Remove temporary files
rm ${DIRNAME_ABS}/*.tmp
rm ${CLEAN_TRANSCRIPT_ABS}
rm ${PHONEMIZED_ABS}