#!/bin/bash
# Done in bash thinking that it would be faster.
# Maybe need to redo it in Python.

INPUT=$1

display_usage() {
    echo "Given a folder containing .cha files, convert them into .rttm files."
    echo "usage: $0 [input] [optional flag]"
    echo "  input       The folder where to find the .cha files, or the single .cha file (REQUIRED)."
    exit 1
}

cha_2_rttm() {
    if [ "$#" -eq 0 ]; then
        echo "Illegal number of parameters"
        exit 1
    else
        filename=$1
    fi

    if [ ! -f $filename ]; then
        echo "File not found"
        exit 1
    fi
#    # Read header
#    header="$(cat $filename | grep "^@")"
#    NB_PARTICIPANTS=$(echo "${header,,}" | grep "^@participants" | awk -F"," '{print NF}')
#
#    PARTICIPANTS=$(echo "${header,,}" | grep "^@id")
#    PARTICIPANTS=$(echo "$PARTICIPANTS" | awk -F"|" '{print "p_"$3 " a_"$4}')
#    >&2 echo "Number of participants : $NB_PARTICIPANTS"
#    >&2 echo "Participants & their age: ${PARTICIPANTS//$'\n'/, }"

    new_file=$(basename $filename)
    new_file=${new_file%.*}.rttm

    # Read body
    body="$(cat $filename | sed ':a;N;s/\n\t/ok/;ta;P;D' | grep "^*")"  # Ensuring that one transcript = one and only one line
    while IFS= read -r line; do
        # Get class
        SPKR=$(grep -oP '(?<=\*).*?(?=:)' <<< "$line")

        # Get onset / offset
        ONOFF=$(echo $line | grep -oP '(?<=\025)\d+_\d+(?=\025)')
        ONSET=${ONOFF%_*}
        OFFSET=${ONOFF#*_}

        if [ "$ONSET" == "" ] || [ "$OFFSET" == "" ]; then
            echo -e "SPEAKER\t${new_file%.*}\t1\t-1.0\t-1.0\t<NA>\t<NA>\t$SPKR\t<NA>\t<NA>"
        else
            # Get seconds instead of ms
            ONSET=$(echo "scale=4; $ONSET/1000.0" | bc -l)
            OFFSET=$(echo "scale=4; $OFFSET/1000.0" | bc -l)
            DURATION=$(echo "scale=4; $OFFSET-$ONSET" | bc -l)
            echo -e "SPEAKER\t${new_file%.*}\t1\t$ONSET\t$DURATION\t<NA>\t<NA>\t$SPKR\t<NA>\t<NA>"
        fi
    done < <(printf '%s\n' "$body") > $(dirname $filename)/$new_file
    >&2 echo "Done ${new_file%.*}"
}

if [ -z "$1" ]; then
    display_usage
fi


if [ -f "/vagrant/"$1 ]; then
    echo "File found."
    cha_2_rttm $cha_path
elif [ -d "/vagrant/"$1 ]; then
    echo "Directory found."
    for cha_path in /vagrant/$1/*.cha; do
        cha_2_rttm $cha_path
    done
else
    echo "File or directory not found."
    display_usage
fi;

