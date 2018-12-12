#!/bin/bash 
#
# This script tests numerous tools
# from a downloaded 5 minute section of the HomeBank VanDam daylong audio sample
# ("ACLEW Starter" data)

KEEPTEMP=""
if [ $# -eq 1 ]; then
    if [ $BASH_ARGV == "--keep-temp" ]; then
	KEEPTEMP="--keep-temp"
    fi
fi


# Absolute path to this script.  /home/vagrant/launcher
SCRIPT=$(readlink -f $0)
# Absolute path this script is in. /home/vagrant/ - works out to being user home folder
BASEDIR=`dirname $SCRIPT`
LAUNCHERS=/home/vagrant/launcher
REPOS=/home/vagrant/repos
UTILS=/home/vagrant/utils

# Paths to Tools
OPENSATDIR=$REPOS/OpenSAT     # noisemes
OPENSMILEDIR=$REPOS/opensmile-2.3.0/
TOCOMBOSAD=$REPOS/To-Combo-SAD
DIARTKDIR=$REPOS/ib_diarization_toolkit
#TALNETDIR=$REPOS/TALNet
DSCOREDIR=$REPOS/dscore
YUNITATORDIR=$REPOS/Yunitator
VCMDIR=$REPOS/vcm

FAILURES=false

echo "Starting tests"

cd /vagrant/data

if [ ! -s VanDam-Daylong.zip ]; then
    echo "Downloading test transcript..."
    wget -q -N https://homebank.talkbank.org/data/Public/VanDam-Daylong.zip
    unzip -q -o VanDam-Daylong.zip
fi

# This is the working directory for the tests; right beside the input
cd VanDam-Daylong/BN32/
WORKDIR=`pwd`

# Get daylong recording from the web
if [ ! -s BN32_010007.mp3 ]; then
    echo "Downloading test audio..."
    wget -q -N https://media.talkbank.org/homebank/Public/VanDam-Daylong/BN32/BN32_010007.mp3
fi

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
cat $BASE.stm | awk -v start=$START -v stop=$STOP -v file=$BASE -e '{if (($4 > start) && ($4 < stop)) print "SPEAKER",file"_test","1",($4 - start),($5 - $4),"<NA>","<NA>","speech","<NA>","<NA>" }' > $BASETEST.rttm
TEST_RTTM=$WORKDIR/$BASETEST.rttm
TEST_WAV=$WORKDIR/$BASETEST.wav


# Check for HTK
echo "Checking for HTK..."
if [ -s /usr/local/bin/HCopy ]; then
    echo "HTK is installed."
else
    echo "   HTK missing; did you first download HTK-3.4.1 from http://htk.eng.cam.ac.uk/download.shtml"
    echo "   and rename it to HTK.tar.gz? If so, then you may need to re-install it. Run: vagrant ssh -c \"utils/install_htk.sh\" "
fi

TESTDIR=$WORKDIR/test
rm -rf $TESTDIR; mkdir -p $TESTDIR
ln -fs $TEST_WAV $TESTDIR
cp $WORKDIR/$BASETEST.rttm $TESTDIR



# now test Noisemes
echo "Testing noisemes..."
cd $OPENSATDIR

$LAUNCHERS/noisemesSad.sh $DATADIR/test $KEEPTEMP > $TESTDIR/noisemes-test.log 2>&1 || { echo "   Noisemes failed - dependencies"; FAILURES=true;}

if [ -s $TESTDIR/noisemesSad_$BASETEST.rttm ]; then
    echo "Noisemes passed the test."
else
    FAILURES=true
    echo "   Noisemes failed - no RTTM output"
fi


# now test OPENSMILEDIR
echo "Testing OpenSmile SAD..."
cd $OPENSMILEDIR

$LAUNCHERS/opensmileSad.sh $DATADIR/test $KEEPTEMP >$TESTDIR/opensmile-test.log || { echo "   OpenSmile SAD failed - dependencies"; FAILURES=true;}

if [ -s $TESTDIR/opensmileSad_$BASETEST.rttm ]; then
    echo "OpenSmile SAD passed the test."
else
    FAILURES=true
    echo "   OpenSmile SAD failed - no RTTM output"
fi

# now test TOCOMBOSAD
echo "Testing ToCombo SAD..."
cd $TOCOMBOSAD

$LAUNCHERS/tocomboSad.sh $DATADIR/test $KEEPTEMP > $TESTDIR/tocombo_sad_test.log 2>&1 || { echo "   TOCOMBO SAD failed - dependencies"; FAILURES=true;}

if [ -s $TESTDIR/tocomboSad_$BASETEST.rttm ]; then
    echo "TOCOMBO SAD passed the test."
else
    FAILURES=true
    echo "   TOCOMBO SAD failed - no output RTTM"
fi


#  test DIARTK
echo "Testing DIARTK..."
cd $DIARTKDIR

cp $TEST_RTTM $TESTDIR
# run like the wind
$LAUNCHERS/diartk.sh $DATADIR/test rttm $KEEPTEMP > $TESTDIR/diartk-test.log 2>&1
if grep -q "command not found" $TESTDIR/diartk-test.log; then
    echo "   Diartk failed - dependencies (probably HTK)"
    FAILURES=true
else
    if [ -s $TESTDIR/diartk_goldSad_$BASETEST.rttm ]; then
	echo "DiarTK passed the test."
    else
	FAILURES=true
	echo "   Diartk failed - no output RTTM"
    fi
fi
#rm $TESTDIR/$BASETEST.rttm

#  test Yunitator
echo "Testing Yunitator..."
cd $YUNITATORDIR

# let 'er rip
$LAUNCHERS/yunitate.sh $DATADIR/test $KEEPTEMP > $TESTDIR/yunitator-test.log 2>&1 || { echo "   Yunitator failed - dependencies"; FAILURES=true;}
if [ -s $TESTDIR/yunitator_$BASETEST.rttm ]; then
    echo "Yunitator passed the test."
else
    FAILURES=true
    echo "   Yunitator failed - no output RTTM"
fi


# Test DSCORE
echo "Testing Dscore..."
cd $DSCOREDIR

cp -r test_ref test_sys $TESTDIR
rm -f test.df
python score_batch.py $TESTDIR/test.df $TESTDIR/test_ref $TESTDIR/test_sys > $TESTDIR/dscore-test.log ||  { echo "   Dscore failed - dependencies"; FAILURES=true;}
if [ -s $TESTDIR/test.df ]; then
    echo "DScore passed the test."
else
    echo "   DScore failed the test - output does not match expected"
    FAILURES=true
fi



# Testing VCM
echo "Testing VCM..."
cd $VCMDIR

$LAUNCHERS/vcm.sh $DATADIR/test $KEEPTEMP > $TESTDIR/vcm-test.log 2>&1 || { echo "   VCM failed - dependencies"; FAILURES=true;}
if [ -s $TESTDIR/vcm_$BASETEST.rttm ]; then
    echo "VCM passed the test."
else
    FAILURES=true
    echo "   VCM failed - no output RTTM"
fi

# test finished
if $FAILURES; then
    echo "Some tools did not pass the test, but you can still use others"
else
    echo "Congratulations, everything is OK!"
fi

# results
echo "######################################################################################"
echo "To wrap up, we will print out the results of the analyses that we ran during the test."
echo "Compare the following results, corresponding to your system, against the reference results printed out below."
echo "If the numbers are similar, then your system is working similarly to the original one."
echo "If you see bigger changes, then please paste this output onto an issue on https://github.com/srvk/DiViMe/issues/."
echo "RESULTS:"
for f in /vagrant/$DATADIR/test/*.rttm; do $UTILS/sum-rttm.sh $f; done
echo "****** REFERENCE RESULTS BEGINS ******."
echo "LINES: 101	DURATION SUM: 298.637	FILE: /vagrant/data/VanDam-Daylong/BN32/test/BN32_010007_test.rttm"
echo "LINES: 101	DURATION SUM: 298.637	FILE: /vagrant/data/VanDam-Daylong/BN32/test/diartk_goldSad_BN32_010007_test.rttm"
echo "LINES: 37	DURATION SUM: 31.9	FILE: /vagrant/data/VanDam-Daylong/BN32/test/noisemesSad_BN32_010007_test.rttm"
echo "LINES: 88	DURATION SUM: 212.22	FILE: /vagrant/data/VanDam-Daylong/BN32/test/opensmileSad_BN32_010007_test.rttm"
echo "LINES: 56	DURATION SUM: 63.66	FILE: /vagrant/data/VanDam-Daylong/BN32/test/tocomboSad_BN32_010007_test.rttm"
echo "LINES: 31	DURATION SUM: 24.7	FILE: /vagrant/data/VanDam-Daylong/BN32/test/vcm_BN32_010007_test.rttm"
echo "LINES: 105	DURATION SUM: 302	FILE: /vagrant/data/VanDam-Daylong/BN32/test/yunitator_BN32_010007_test.rttm"
echo "****** REFERENCE RESULTS ENDS ******."

echo "DSCORE:"
cat /vagrant/data/VanDam-Daylong/BN32/test/test.df
echo "****** REFERENCE DSCORE BEGINS ******."
echo "DER	B3Precision	B3Recall	B3F1	TauRefSys	TauSysRef	CE	MI	NMI"
echo "Phil_Crane	43.38	0.975590490013	0.672338020576	0.796061934402	0.599223772838	0.963770340456	0.103871357212	1.67823036445	0.793181875273"
echo "****** REFERENCE DSCORE ENDS ******."

