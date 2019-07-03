#!/usr/bin/env bash

display_usage() {
    echo "Usage: eval.sh <data> <model> <list of metrics> <optional flags>"
    echo "where :"
    echo -e "\tdata is the folder containing the data"
    echo -e "\tmodel is the model that needs to be evaluated"
    echo -e "\tmetrics is a list of metrics that will assess the performances"
    echo -e "\toptional flags, are the flags that change the behaviour of this script :"
    echo -e "\t\t --identification to assess the model as an identification task (when the labels are same in the reference and the hypothesis)"
    echo -e "\t\t --visualization to generate .png files showing the alignement between the reference and the hypothesis.\n\n"
    echo "Choices for the model are:"
    echo -e "\t - noisemesSad"
    echo -e "\t - tocomboSad"
    echo -e "\t - opensmileSad"
    echo -e "\t - diartk"
    echo -e "\t - yunitator"
    echo "If evaluating diartk or yunitator, please give which flavour"
    echo "of SAD you used to produce the transcription"
    echo "you want to evaluate"
    echo -e "\nChoices for the metrics are:"
    echo -e "\t- for the speech activity detection task :"
    echo -e "\t\t accuracy, deter, precision, recall"
    echo -e "\t- for the diarization task :"
    echo -e "\t\t completeness, coverage, diaer, homogeneity, purity"
    echo -e "\t- for the identification task :"
    echo -e "\t\t ider, precision, recall"
    exit 1
}

### Read in variables from user
DATA=$1
MODEL=$2
shift; shift;
if [[ "$MODEL" == "diartk" ]] || [[ "$MODEL" == "yunitator" ]]; then
    if [[ "$1" == "rttm" ]]; then
        MODEL=${MODEL}_goldSad
    else
        MODEL=${MODEL}_$1
    fi
    shift;
fi;

# Read metrics
METRICS=()
while [ ! -z $1 ] && [ ! ${1:0:2} == "--" ]; do
    METRICS+=("$1")
    shift ;
done

# Read optional flags that are used to run
# the script in a "non-classical" way.
FLAGS=()
while true ; do
    case "$1" in
        --identification)
                FLAGS+=("--identification")
        		shift ;;
        --visualization)
                FLAGS+=("--visualization")
                shift ;;
        *)
            if [[ ! $1 == "" ]]; then
                echo "Flag $1 not recognized."
                exit 1
            fi
            break;;
    esac
done

echo -e "\nEvaluating ${MODEL} on ${DATA} with respect to : ${METRICS[*]}"
echo -e "${FLAGS[*]}"
### Launcher onset routine
SCRIPT=$(readlink -f $0)
BASEDIR=/home/vagrant
REPOS=$BASEDIR/repos
UTILS=$BASEDIR/utils
LAUNCHER=$BASEDIR/launcher
###############################

#### SCRIPT STARTS
source activate divime
case $MODEL in
"tocomboSad"|"opensmileSad"|"noisemesSad")
   python $UTILS/compute_metrics.py --reference $DATA/.. --hypothesis $DATA --prefix $MODEL --task detection --metrics ${METRICS[*]} ${FLAGS[*]}
   ;;
"yunitator_old"|"yunitator_english"|"yunitator_universal"|"lena"|"diartk_noisemesSad"|"diartk_tocomboSad"|"diartk_opensmileSad"|"diartk_goldSad")
   python $UTILS/compute_metrics.py --reference $DATA/.. --hypothesis $DATA --prefix $MODEL --task diarization --metrics ${METRICS[*]} ${FLAGS[*]}
   ;;
*)
   display_usage
   ;;
esac
conda deactivate
