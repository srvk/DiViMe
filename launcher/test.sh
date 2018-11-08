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

conda_dir=/home/vagrant/anaconda/bin

# Absolute path to this script. /home/user/bin/foo.sh
SCRIPT=$(readlink -f $0)
# Absolute path this script is in. /home/vagrant/tools
BASEDIR=`dirname $SCRIPT`

# Paths to Tools
LDC_SAD_DIR=$(dirname $BASEDIR)/ldcSad_hmm
OPENSATDIR=$(dirname $BASEDIR)/OpenSAT     # noisemes
OPENSMILEDIR=$(dirname $BASEDIR)/openSMILE-2.1.0/
TOCOMBOSAD=$(dirname $BASEDIR)/To-Combo-SAD
DIARTKDIR=$(dirname $BASEDIR)/ib_diarization_toolkit
#TALNETDIR=$(dirname $BASEDIR)/TALNet
DSCOREDIR=$(dirname $BASEDIR)/dscore
YUNITATORDIR=$(dirname $BASEDIR)/Yunitator

FAILURES=false

echo "Starting tests"
echo "Downloading test audio..."

cd /vagrant/data
# get transcript
wget -q -N https://homebank.talkbank.org/data/Public/VanDam-Daylong.zip
unzip -q -o VanDam-Daylong.zip

# This is the working directory for the tests; right beside the input
cd VanDam-Daylong/BN32/
# Get daylong recording from the web
wget -q -N https://media.talkbank.org/homebank/Public/VanDam-Daylong/BN32/BN32_010007.mp3

WORKDIR=`pwd`
DATADIR=data/VanDam-Daylong/BN32  # relative to /vagrant, used by launcher scripts
BASE=BN32_010007 # base filename for test input file, minus .wav or .rttm suffix
BASETEST=${BASE}_test
START=2513 # 41:53 in seconds
STOP=2813  # 46:53 in seconds

# get 5 minute subset of audio
sox $BASE.mp3 $BASETEST.wav trim $START 5:00 >& /dev/null 2>1

# convert CHA to reliable STM
/home/vagrant/tools/chat2stm.sh $BASE.cha > $BASE.stm 2>/dev/null
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
    echo "   and rename it to HTK.tar.gz ?"
fi

# First test in ldcSad_hmm
echo "Testing LDC SAD..."
if [ -s $LDC_SAD_DIR/perform_sad.py ]; then
    cd $LDC_SAD_DIR
    TESTDIR=$WORKDIR/ldcSad-test
    rm -rf $TESTDIR; mkdir -p $TESTDIR
    $conda_dir/python perform_sad.py -L $TESTDIR $TEST_WAV > $TESTDIR/ldcSad.log 2>&1 || { echo "   LDC SAD failed - dependencies"; FAILURES=true;}
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
<<<<<<< HEAD
./runDiarNoisemes.sh $TESTDIR > $TESTDIR/nosiemes-test.log 2>&1 || (echo "Noisemes failed - dependencies" && FAILURES=true)
cp $TESTDIR/hyp_sum/$BASETEST.rttm $TESTDIR
=======
./runDiarNoisemes.sh $TESTDIR > $TESTDIR/nosiemes-test.log 2>&1 || { echo "   Noisemes failed - dependencies"; FAILURES=true;}
>>>>>>> 053a3d0b196066a04d60bf41fbc2b62843374814

if [ -s $TESTDIR/hyp_sum/$BASETEST.rttm ]; then
    echo "Noisemes passed the test."
else
    FAILURES=true
    echo "   Noisemes failed - no RTTM output"
fi
# clean up
rm -rf $OPENSATDIR/SSSF/data/feature $OPENSATDIR/SSSF/data/hyp


# now test OPENSMILEDIR
echo "Testing OpenSmile SAD..."
cd $OPENSMILEDIR
TESTDIR=$WORKDIR/opensmile-test
rm -rf $TESTDIR; mkdir -p $TESTDIR
ln -fs $TEST_WAV $TESTDIR
<<<<<<< HEAD
/home/vagrant/tools/opensmile_sad.sh $DATADIR/opensmile-test >$TESTDIR/opensmile-test.log || (echo "OpenSmile SAD failed - dependencies" && FAILURES=true)
=======
/home/vagrant/tools/opensmile_sad.sh data/VanDam-Daylong/BN32/opensmile-test >$TESTDIR/opensmile-test.log || { echo "   OpenSmile SAD failed - dependencies"; FAILURES=true;}
>>>>>>> 053a3d0b196066a04d60bf41fbc2b62843374814

if [ -s $TESTDIR/opensmile_sad_$BASETEST.rttm ]; then
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
<<<<<<< HEAD
/home/vagrant/tools/tocombo_sad.sh $DATADIR/tocombo_sad-test > $TESTDIR/tocombo_sad_test.log 2>&1 || (echo "TOCOMBO SAD failed - dependencies" && FAILURES=true)
=======
/home/vagrant/tools/tocombo_sad.sh data/VanDam-Daylong/BN32/tocombo_sad-test > $TESTDIR/tocombo_sad_test.log 2>&1 || { echo "   TOCOMBO SAD failed - dependencies"; FAILURES=true;}
>>>>>>> 053a3d0b196066a04d60bf41fbc2b62843374814

if [ -s $TESTDIR/tocombo_sad_$BASETEST.rttm ]; then
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
# run like the wind
./run-rttm.sh $TEST_WAV $TEST_RTTM $TESTDIR > $TESTDIR/diartk-test.log 2>&1
if grep -q "command not found" $TESTDIR/diartk-test.log; then
    echo "   Diartk failed - dependencies (probably HTK)"
    FAILURES=true
else
    if [ -s $TESTDIR/$BASETEST.rttm ]; then
	echo "DiarTK passed the test."
    else
	FAILURES=true
	echo "   Diartk failed - no output RTTM"
    fi
fi

# finally test Yunitator
echo "Testing Yunitator..."
cd $YUNITATORDIR
TESTDIR=$WORKDIR/yunitator-test
rm -rf $TESTDIR; mkdir -p $TESTDIR
ln -fs $TEST_WAV $TESTDIR
# let 'er rip
./runYunitator.sh $TESTDIR/$BASETEST.wav > $TESTDIR/yunitator-test.log 2>&1 || { echo "   Yunitator failed - dependencies"; FAILURES=true;}
if [ -s $TESTDIR/Yunitemp/$BASETEST.rttm ]; then
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
<<<<<<< HEAD
cd $LDC_SAD_DIR
TESTDIR=$WORKDIR/opensmile-test
cp $WORKDIR/$BASETEST.rttm $TESTDIR
~/tools/eval.sh $TESTDIR opensmile > $WORKDIR/ldcSad-test/ldc_evalSAD.log 2>&1 || (echo "LDC evalSAD failed - dependencies" && FAILURES=true)
# clean up
rm $TESTDIR/$BASETEST.rttm
if [ -s $TESTDIR/opensmile_sad_eval.df ]; then
    echo "LDC evalSAD passed the test"
=======
if [ -d $LDC_SAD_DIR ]; then
    cd $LDC_SAD_DIR
    TESTDIR=$WORKDIR/opensmile-test
    cp $WORKDIR/$BASETEST.rttm $TESTDIR
    ~/tools/eval.sh $DATADIR/opensmile-test opensmile > $WORKDIR/ldcSad-test/ldc_evalSAD.log 2>&1 || { echo "   LDC evalSAD failed - dependencies"; FAILURES=true;}
    if [ -s $TESTDIR/opensmile_sad_eval.df ]; then
	echo "LDC evalSAD passed the test"
    else
	echo "   LDC evalSAD failed - no output .df"
	FAILURES=true
    fi
>>>>>>> 053a3d0b196066a04d60bf41fbc2b62843374814
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
for f in /vagrant/$DATADIR/*-test/*.rttm; do $BASEDIR/sum-rttm.sh $f; done
echo "DSCORE:"
cat /vagrant/data/VanDam-Daylong/BN32/dscore-test/test.df
echo "EVAL_SAD:"
cat $TESTDIR/opensmile_sad_eval.df
