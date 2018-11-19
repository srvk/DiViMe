#!/bin/bash
# Launcher onset routine
source ~/.bashrc
SCRIPT=$(readlink -f $0)
BASEDIR=/home/vagrant
conda_dir=$BASEDIR/anaconda/bin
REPOS=$BASEDIR/repos
UTILS=$BASEDIR/utils
LAUNCHER=$BASEDIR/launcher
# end of launcher onset routine

### Read in variables from user
#audio_dir=/vagrant/$1
audio_dir=$1
system=$2

### Other variables specific to this script
#none

display_usage() {
    echo "Usage: eval.sh <data> <system> <<optionalSAD>>"
    echo "where data is the folder containing the data"
    echo "and system is the system you want"
    echo "to evaluate. Choices are:"
    echo "  ldcSad"
    echo "  noisemesSad"
    echo "  tocomboSad"
    echo "  opensmileSad"
    echo "  lenaSad"
    echo "  diartk"
    echo "  yunitate"
    echo "  lenaDiar"
    echo "If evaluating diartk, please give which flavour"
    echo "of SAD you used to produce the transcription"
    echo "you want to evaluate"
    exit 1
}

if [ $# -lt 2 ] ; then
  display_usage
fi


### SCRIPT STARTS
case $system in
"tocomboSad"|"opensmileSad"|"ldcSad"|"noisemesSad|lenaSad")
   sh $LAUNCHER/evalSAD.sh $audio_dir $system
   ;;
"yunitate"|"lenaDiar")
   sh $LAUNCHER/evalDiar.sh $audio_dir $system
   ;;
"diartk")
   sad=$3
   sh $LAUNCHER/evalDiar.sh $audio_dir $system $sad
   ;;
*)
   display_usage
   ;;

esac
