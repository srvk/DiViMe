#!/bin/bash
# this script takes as input, for $corpus, the folder containing the daylong recordings
# and the transcriptions in eaf format in a folder raw_$corpus. It reads the transcriptions 
# in the eaf files and cuts the wav to only keep the transcribed part, and convert the transcribed
# part into rttm with the same names as the cut wavs.

# take the name of the corpus as input and define the hard coded paths - they shall not change!
corpus=$1 # should be chosen between BER, WAR, SOD and CAS
working_dir=/DATA2T/aclew_data_update
daylong_dir=/DATA2T/aclew_daylong_data
temp_dir=$working_dir/temp # create temp dir to store wav. will be removed at end of script

# Define function to check if all small wavs have an rttm. If not, create an empty one.
create_empty_rttm() {
    # check the wav files and the talker_roles to see if the rttm exists
    # if it doesn't, create an empty rttm file.
    wav=$1
    rttms=$2
    for fin in `ls $wav/*.wav`; do
        basename=$(basename $fin .wav)
        if [[ ! -f $rttms/${basename}.rttm ]]; then
            touch $rttms/${basename}.rttm
        fi
    done
}

## Treat BER WAR the "simple way", add parameters to take into account the format of CAS and SOD/SOD2
#if [[ $corpus == 'BER' ]] || [[ $corpus == 'WAR' ]] || [[ $corpus == 'CAS' ]]; then
if [[ $corpus != 'SOD2' ]] ; then
    mkdir -p $temp_dir/$corpus/SAD 
    for wav in `ls $daylong_dir/$corpus/*.wav`; do
        base=$(basename $wav .wav)
        eaf=raw_$corpus/${base}.eaf
	if [[ $corpus == 'CAS' ]]; then
             python $working_dir/adjust_timestamps.py $working_dir/github_data/$eaf $wav $temp_dir --CAS
        else
             python $working_dir/adjust_timestamps.py $working_dir/github_data/$eaf $wav $temp_dir 2>&1 
	fi
	# now remove old wav and transcriptions:

    done
    rm $working_dir/ACLEW_data/databrary_ACLEW/wavs/${corpus}_*wav $working_dir/ACLEW_data/databrary_ACLEW/talker_role/${corpus}_*rttm
    mv $temp_dir/*.rttm $working_dir/ACLEW_data/databrary_ACLEW/talker_role/
    mv $temp_dir/*.wav $working_dir/ACLEW_data/databrary_ACLEW/wavs/

    # create empty rttms when the wav has no transcription (nobody's talking)'
    #create_empty_rttm $corpus/treated $corpus/treated/talker_role

    # Now create the SAD
    rm $working_dir/ACLEW_data/databrary_ACLEW/SAD/${corpus}_*rttm
    python remove_overlap_rttm.py $working_dir/ACLEW_data/databrary_ACLEW/talker_role/ $working_dir/ACLEW_data/databrary_ACLEW/SAD
fi

# SOD : the eaf have the same name as the wav, but they added '-$name' where $name is the initials of the annotator
if [[ $corpus == 'SOD2' ]]; then
    echo "treating SOD" 2>&1
    corpus=SOD
    mkdir -p $temp_dir/$corpus/SAD 
    for wav in `ls $daylong_dir/$corpus/*.wav`; do
        base=$(basename $wav .wav)
        eaf=raw_$corpus/${base}-TS.eaf
        if [ ! -f $working_dir/github_data/$eaf ]; then
            eaf=raw_$corpus/${base}-JK.eaf
        fi
        python $working_dir/adjust_timestamps.py $working_dir/github_data/$eaf $wav $temp_dir 2>&1 

    done
    mv $temp_dir/*.rttm $working_dir/ACLEW_data/databrary_ACLEW/talker_role/
    mv $temp_dir/*.wav $working_dir/ACLEW_data/databrary_ACLEW/wavs/

    # Now create the SAD
    python remove_overlap_rttm.py $working_dir/ACLEW_data/databrary_ACLEW/talker_role/ $working_dir/ACLEW_data/databrary_ACLEW/SAD

fi
# create empty rttms when the wav has no transcription (nobody's talking)'

#create_empty_rttm $corpus/treated $corpus/treated/talker_role

# Now create the SAD
#python remove_overlap_rttm.py $corpus/treated/talker_role $corpus/treated/SAD


## CAS : the eaf don't have the 'on_off' tier to encode the segments, instead it's called "code" - this is taken
## into account in adjust_timestamps.py with the --CAS parameter
#if [[ $corpus == 'CAS' ]]; then
#    #convert2wav $corpus
#    mkdir -p $corpus/treated/SAD
#    for wav in `ls $corpus/*.wav`; do
#        base=$(basename $wav .wav)
#        eaf=$corpus/raw_$corpus/${base}.eaf
#        python $working_dir/adjust_timestamps.py $eaf $wav --CAS
#    done
#fi
## create empty rttms when the wav has no transcription (nobody's talking)'
#
#create_empty_rttm $corpus/treated $corpus/treated/talker_role
#
## Now create the SAD
#python remove_overlap_rttm.py $corpus/treated/talker_role $corpus/treated/SAD
##done
#
