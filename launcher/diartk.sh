#!/bin/bash
# Launcher onset routine
SCRIPT=$(readlink -f $0)
BASEDIR=/home/vagrant
REPOS=$BASEDIR/repos
UTILS=$BASEDIR/utils
# end of launcher onset routine

if [ $# -lt 1 ] || [ $# -gt 3 ]; then
  echo "Usage: $0 <audio-dir> <format>"
  echo "where audio-dir is the name of the folder"
  echo "containing the wav files"
  echo "and <format> is one of:"
  echo "  noisemesSad"
  echo "  tocomboSad"
  echo "  opensmileSad"
  echo "  textgrid"
  echo "  eaf"
  echo "  rttm"

  exit 1
fi

KEEPTEMP=false
if [ $BASH_ARGV == "--keep-temp" ]; then
    KEEPTEMP=true
fi

### Read in variables from user
audio_dir=/vagrant/$1
trs_format=$2

### Other variables specific to this script
# create temp dir
workdir=`mktemp -d --tmpdir=${audio_dir}`

### SCRIPT STARTS
cd $BASEDIR/repos/ib_diarization_toolkit


# Check audio_dir to see if empty or if contains empty wav
bash $UTILS/check_folder.sh ${audio_dir}


for fin in `ls ${audio_dir}/*.wav`; do
    filename=$(basename "$fin")
    basename="${filename%.*}"
    echo "treating $basename"
    
    featfile=$workdir/$basename.fea
    scpfile=$workdir/$basename.scp
    
    # first-first convert RTTM to DiarTK's version of a .scp file
    # SCP format:
    #   <basename>_<start>_<end>=<filename>[start,end]
    # RTTM format:
    #   Type file chan tbeg tdur ortho stype name conf Slat
    # math: convert RTTM seconds to HTK (10ms default) frames = multiply by 100
    case $trs_format in
     "noisemesSad")
       sys="noisemesSad"
       python $UTILS/rttm2scp.py ${audio_dir}/noisemesSad_${basename}.rttm $scpfile
      ;;
      "tocomboSad")
       sys="tocomboSad"
        python $UTILS/rttm2scp.py ${audio_dir}/tocomboSad_${basename}.rttm $scpfile
      ;;
      "opensmileSad")
       sys="opensmileSad"
        python $UTILS/rttm2scp.py ${audio_dir}/opensmileSad_${basename}.rttm $scpfile
      ;;
      "textgrid") 
       sys="goldSad"
       python /home$UTILS/textgrid2rttm.py ${audio_dir}/${basename}.TextGrid $workdir/${basename}.rttm
       python $UTILS/rttm2scp.py $workdir/${basename}.rttm $scpfile
       rm $workdir/$basename.rttm
      ;;
      "eaf")
       sys="goldSad"
       python /home$UTILS/elan2rttm.py ${audio_dir}/${basename}.eaf $workdir/${basename}.rttm
       python $UTILS/rttm2scp.py $workdir/${basename}.rttm $scpfile
       rm $workdir/$basename.rttm
      ;;
      "rttm")
       sys="goldSad"
       # Since some reference rttm files are spaced rather than tabbed, we need to
       # tab them before using them.
       cp ${audio_dir}/${basename}.rttm $workdir/${basename}.rttm
       sed -i 's/ \+/\t/g' $workdir//${basename}.rttm
       python $UTILS/rttm2scp.py $workdir/${basename}.rttm $scpfile
      ;;
      *)
       echo "ERROR: please choose SAD system between:"
       echo "  noisemesSad"
       echo "  tocomboSad"
       echo "  opensmileSad"
       echo "  textgrid"
       echo "  eaf"
       echo "  rttm"
       echo "Now exiting..."
       exit 1
      ;;
    esac
   
    # don't process files with empty transcription
    if [ -s $scpfile ]; then 
        # first generate HTK features
        #HCopy -T 2 -C htkconfig $fin $featfile
        >&2 echo WARNING for $featfile: replacing HCopy htconfig with SMILExtract MFCC12_E_D_A is untested
        LD_LIBRARY_PATH=/usr/local/lib \
	    SMILExtract \
            -C ~/repos/opensmile-2.3.0/config/MFCC12_E_D_A.conf \
            -I $fin -O $featfile \
            -logfile $workdir/opensmile-diartk.log

        # next run DiarTK
        scripts/run.diarizeme.sh $featfile $scpfile $workdir $basename
        
        # print results
        #cat $workdir/$basename.out
        cp $workdir/$basename.rttm ${audio_dir}/diartk_${sys}_${basename}.rttm
    else
        # Create empty output file
        touch ${audio_dir}/diartk_${sys}_${basename}.rttm
    fi
done

# Delete temporary folder
if ! $KEEPTEMP; then
    rm -rf $workdir
fi
