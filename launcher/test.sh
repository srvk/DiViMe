#!/bin/bash 
#
# This script tests numerous tools
# from a downloaded 5 minute section of the HomeBank VanDam daylong audio sample
# ("ACLEW Starter" data)

# this doesn't work because .bashrc exits immediately if not running interactively
#source /home/vagrant/.bashrc -i
# instead:
export PATH=/home/vagrant/anaconda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin
LD_LIBRARY_PATH="/usr/local/MATLAB/MATLAB_Runtime/v93/runtime/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v93/bin/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v93/sys/os/glnxa64:$LD_LIBRARY_PATH"

KEEPTEMP=""
if [ $# -eq 1 ]; then
    if [ $BASH_ARGV == "--keep-temp" ]; then
	KEEPTEMP="--keep-temp"
    fi
fi

conda_dir=/home/vagrant/anaconda/bin

# Absolute path to this script.  /home/vagrant/launcher
SCRIPT=$(readlink -f $0)
# Absolute path this script is in. /home/vagrant/ - works out to being user home folder
BASEDIR=`dirname $SCRIPT`
LAUNCHERS=/home/vagrant/launcher
REPOS=/home/vagrant/repos
UTILS=/home/vagrant/utils

# Paths to Tools
LDC_SAD_DIR=$REPOS/ldc_sad_hmm
OPENSATDIR=$REPOS/OpenSAT     # noisemes
OPENSMILEDIR=$REPOS/openSMILE-2.1.0/
TOCOMBOSAD=$REPOS/To-Combo-SAD
DIARTKDIR=$REPOS/ib_diarization_toolkit
#TALNETDIR=$REPOS/TALNet
DSCOREDIR=$REPOS/dscore
YUNITATORDIR=$REPOS/Yunitator

FAILURES=false

echo "Starting tests"
echo "Downloading test audio..."

cd /vagrant/data
# get transcript
wget -q -N https://homebank.talkbank.org/data/Public/VanDam-Daylong.zip
unzip -q -o VanDam-Daylong.zip

# This is the working directory for the tests; right beside the input
cd VanDam-Daylong/BN32/
WORKDIR=`pwd`

# Get daylong recording from the web
wget -q -N https://media.talkbank.org/homebank/Public/VanDam-Daylong/BN32/BN32_010007.mp3

DATADIR=data/VanDam-Daylong/BN32  # relative to /vagrant, used by launcher scripts
BASE=BN32_010007 # base filename for test input file, minus .wav or .rttm suffix
BASETEST=${BASE}_test
START=2513 # 41:53 in seconds
STOP=2813  # 46:53 in seconds

# get 5 minute subset of audio
sox $BASE.mp3 $BASETEST.wav trim $START 5:00 >& /dev/null 2>&1 # silence output

# convert CHA to reliable STM
$UTILS/chat2stm.sh $BASE.cha > $BASE.stm 2>/dev/null
# convert STM to RTTM as e.g. BN32_010007.rttm
# shift audio offsets to be 0-relative
cat $BASE.stm | awk -v start=$START -v stop=$STOP -v file=$BASE -e '{if (($4 > start) && ($4 < stop)) print "SPEAKER",file,"1",($4 - start),($5 - $4),"<NA>","<NA>","<NA>","<NA>","<NA>" }' > $BASETEST.rttm
TEST_RTTM=$WORKDIR/$BASETEST.rttm
TEST_WAV=$WORKDIR/$BASETEST.wav


# Check for HTK
echo "Checking for HTK..."
if [ -s /usr/local/bin/HCopy ]; then
    echo "HTK is installed."
else
    echo "   HTK missing; did you first download HTK-3.4.1 from http://htk.eng.cam.ac.uk/download.shtml"
    echo "   and rename it to HTK.tar.gz? If not, do so now, then run: ssh -c \"install_htk.sh\" "
fi

# First test in ldc_sad_hmm
echo "Testing LDC SAD..."
if [ -s $LDC_SAD_DIR/perform_sad.py ]; then
    cd $LDC_SAD_DIR
    TESTDIR=$WORKDIR/ldc_sad-test
    rm -rf $TESTDIR; mkdir -p $TESTDIR
    $conda_dir/python perform_sad.py -L $TESTDIR $TEST_WAV > $TESTDIR/ldc_sad.log 2>&1 || { echo "   LDC SAD failed - dependencies"; FAILURES=true;}
    # convert output to rttm, for diartk.
    grep ' speech' $TESTDIR/$BASETEST.lab | awk -v fname=$BASE '{print "SPEAKER" " " fname " " 1  " " $1  " " $2-$1 " " "<NA>" " " "<NA>"  " " $3  " "  "<NA>"}'   > $TESTDIR/$BASETEST.rttm
    if [ -s $TESTDIR/$BASETEST.rttm ]; then
	echo "LDC SAD passed the test."
    else
	FAILURES=true
	echo "   LDC SAD failed - no output RTTM"
    fi
else
    echo "   LDC SAD failed because the code for LDC SAD is missing. This is normal, as we are still awaiting the official release!"
fi


# now test Noisemes
echo "Testing noisemes..."
cd $OPENSATDIR
TESTDIR=$WORKDIR/noisemes-test
rm -rf $TESTDIR; mkdir -p $TESTDIR
ln -fs $TEST_WAV $TESTDIR
#./runDiarNoisemes.sh $TESTDIR > $TESTDIR/noisemes-test.log 2>&1 
$LAUNCHERS/noisemesSad.sh $DATADIR/noisemes-test $KEEPTEMP > $TESTDIR/noisemes-test.log 2>&1 || { echo "   Noisemes failed - dependencies"; FAILURES=true;}

if [ -s $TESTDIR/noisemes_sad_$BASETEST.rttm ]; then
    echo "Noisemes passed the test."
else
    FAILURES=true
    echo "   Noisemes failed - no RTTM output"
fi
# clean up
#rm -rf $OPENSATDIR/SSSF/data/feature $OPENSATDIR/SSSF/data/hyp


# now test OPENSMILEDIR
echo "Testing OpenSmile SAD..."
cd $OPENSMILEDIR
TESTDIR=$WORKDIR/opensmile-test
rm -rf $TESTDIR; mkdir -p $TESTDIR
ln -fs $TEST_WAV $TESTDIR
$LAUNCHERS/opensmileSad.sh $DATADIR/opensmile-test $KEEPTEMP >$TESTDIR/opensmile-test.log || { echo "   OpenSmile SAD failed - dependencies"; FAILURES=true;}

if [ -s $TESTDIR/opensmileSad_$BASETEST.rttm ]; then
    echo "OpenSmile SAD passed the test."
else
    FAILURES=true
    echo "   OpenSmile SAD failed - no RTTM output"
fi

# now test TOCOMBOSAD
echo "Testing ToCombo SAD..."
cd $TOCOMBOSAD
TESTDIR=$WORKDIR/tocombo_sad-test
rm -rf $TESTDIR; mkdir -p $TESTDIR
ln -fs $TEST_WAV $TESTDIR
$LAUNCHERS/tocomboSad.sh $DATADIR/tocombo_sad-test $KEEPTEMP > $TESTDIR/tocombo_sad_test.log 2>&1 || { echo "   TOCOMBO SAD failed - dependencies"; FAILURES=true;}

if [ -s $TESTDIR/tocomboSad_$BASETEST.rttm ]; then
    echo "TOCOMBO SAD passed the test."
else
    FAILURES=true
    echo "   TOCOMBO SAD failed - no output RTTM"
fi


# finally test DIARTK
echo "Testing DIARTK..."
cd $DIARTKDIR
TESTDIR=$WORKDIR/diartk-test
rm -rf $TESTDIR; mkdir -p $TESTDIR
ln -fs $TEST_WAV $TESTDIR
cp $TEST_RTTM $TESTDIR
# run like the wind
$LAUNCHERS/diartk.sh $DATADIR/diartk-test rttm $KEEPTEMP > $TESTDIR/diartk-test.log 2>&1
if grep -q "command not found" $TESTDIR/diartk-test.log; then
    echo "   Diartk failed - dependencies (probably HTK is missing)"
    FAILURES=true
else
    if [ -s $TESTDIR/diartk_goldSad_$BASETEST.rttm ]; then
	echo "DiarTK passed the test."
    else
	FAILURES=true
	echo "   Diartk failed - no output RTTM"
    fi
fi
rm $TESTDIR/$BASETEST.rttm

# finally test Yunitator
echo "Testing Yunitator..."
cd $YUNITATORDIR
TESTDIR=$WORKDIR/yunitator-test
rm -rf $TESTDIR; mkdir -p $TESTDIR
ln -fs $TEST_WAV $TESTDIR
# let 'er rip
#./runYunitator.sh $TESTDIR/$BASETEST.wav > $TESTDIR/yunitator-test.log 2>&1 || { echo "   Yunitator failed - dependencies"; FAILURES=true;}
$LAUNCHERS/yunitate.sh $DATADIR/yunitator-test $KEEPTEMP > $TESTDIR/yunitator-test.log 2>&1 || { echo "   Yunitator failed - dependencies"; FAILURES=true;}
if [ -s $TESTDIR/yunitator_$BASETEST.rttm ]; then
    echo "Yunitator passed the test."
else
    FAILURES=true
    echo "   Yunitator failed - no output RTTM"
fi


# Test DSCORE
echo "Testing Dscore..."
cd $DSCOREDIR
TESTDIR=$WORKDIR/dscore-test
rm -rf $TESTDIR; mkdir -p $TESTDIR
cp -r test_ref test_sys $TESTDIR
rm -f test.df
python score_batch.py $TESTDIR/test.df $TESTDIR/test_ref $TESTDIR/test_sys > $TESTDIR/dscore-test.log ||  { echo "   Dscore failed - dependencies"; FAILURES=true;}
if [ -s $TESTDIR/test.df ]; then
    echo "DScore passed the test."
else
    echo "   DScore failed the test - output does not match expected"
    FAILURES=true
fi


# testing LDC evalSAD (on opensmile)
echo "Testing LDC evalSAD"
if [ -d $LDC_SAD_DIR ]; then
    cd $LDC_SAD_DIR
    TESTDIR=$WORKDIR/opensmile-test
    cp $WORKDIR/$BASETEST.rttm $TESTDIR
    $LAUNCHERS/eval.sh $DATADIR/opensmile-test opensmileSad $KEEPTEMP > $WORKDIR/ldc_sad-test/ldc_evalSAD.log 2>&1 || { echo "   LDC evalSAD failed - dependencies"; FAILURES=true;}
    if [ -s $TESTDIR/opensmileSad_eval.df ]; then
	echo "LDC evalSAD passed the test"
    else
	echo "   LDC evalSAD failed - no output .df"
	FAILURES=true
    fi
else
    echo "   LDC evalSAD failed because the code for LDC SAD is missing. This is normal, as we are still awaiting the official release!"
    FAILURES=true
fi


# test finished
if $FAILURES; then
    echo "Some tools did not pass the test, but you can still use others"
else
    echo "Congratulations, everything is OK!"
fi

# results
echo "RESULTS:"
for f in /vagrant/$DATADIR/*-test/*.rttm; do $UTILS/sum-rttm.sh $f; done
echo "DSCORE:"
cat /vagrant/data/VanDam-Daylong/BN32/dscore-test/test.df
echo "EVAL_SAD:"
cat $TESTDIR/opensmileSad_eval.df
