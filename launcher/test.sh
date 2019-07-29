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
OPENSATDIR=$REPOS/Yunitator # same code for noisemes and Yunitator
OPENSMILEDIR=$REPOS/opensmile-2.3.0/
TOCOMBOSAD=$REPOS/To-Combo-SAD
DIARTKDIR=$REPOS/ib_diarization_toolkit
#TALNETDIR=$REPOS/TALNet
DSCOREDIR=$REPOS/dscore
YUNITATORDIR=$REPOS/Yunitator
VCMDIR=$REPOS/vcm

FAILURES=false

(
    cd /vagrant
    echo -e "Welcome to DiViMe's test.sh\n\$ git show-branch"
    git show-branch
    echo "$ git log -1"
    git log -1
    echo "$ git diff --name-status"
    git diff --name-status
    echo "################################################################################"
    echo "Starting tests"
)

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
TESTDIR=$WORKDIR/test


# Check for HTK
if false; then
echo "Checking for HTK..."
if [ -s /usr/local/bin/HCopy ]; then
    echo "HTK is installed."
else
    #echo "   HTK missing; did you first download HTK-3.4.1 from http://htk.eng.cam.ac.uk/download.shtml ?"
    #echo "   If so, then you may need to re-install it. Run: vagrant ssh -c \"utils/install_htk.sh\" "
    echo "   HTK missing. You can probably ignore this warning, HTK is no longer needed."
fi
fi

rm -rf $TESTDIR; mkdir -p $TESTDIR
ln -fs $TEST_WAV $TESTDIR
cp $WORKDIR/$BASETEST.rttm $TESTDIR


# now test Noisemes
echo "Testing noisemes..."

$LAUNCHERS/noisemesSad.sh $DATADIR/test $KEEPTEMP > $TESTDIR/noisemes-test.log 2>&1 || { echo "   Noisemes failed - dependencies"; FAILURES=true;}

if [ -s $TESTDIR/noisemesSad_$BASETEST.rttm ]; then
    echo "Noisemes passed the test."
else
    FAILURES=true
    echo "   Noisemes failed - no RTTM output"
fi


# now test OPENSMILEDIR
echo "Testing OpenSmile SAD..."

$LAUNCHERS/opensmileSad.sh $DATADIR/test $KEEPTEMP >$TESTDIR/opensmile-test.log || { echo "   OpenSmile SAD failed - dependencies"; FAILURES=true;}

if [ -s $TESTDIR/opensmileSad_$BASETEST.rttm ]; then
    echo "OpenSmile SAD passed the test."
else
    FAILURES=true
    echo "   OpenSmile SAD failed - no RTTM output"
fi


# now test TOCOMBOSAD
echo "Testing ToCombo SAD..."

$LAUNCHERS/tocomboSad.sh $DATADIR/test $KEEPTEMP > $TESTDIR/tocombo_sad_test.log 2>&1 || { echo "   ToCombo SAD failed - dependencies"; FAILURES=true;}

if [ -s $TESTDIR/tocomboSad_$BASETEST.rttm ]; then
    echo "ToCombo SAD passed the test."
else
    FAILURES=true
    echo "   ToCombo SAD failed - no output RTTM"
fi


#  test DIARTK
echo "Testing DiarTk..."

cp $TEST_RTTM $TESTDIR

# run like the wind
$LAUNCHERS/diartk.sh $DATADIR/test rttm $KEEPTEMP > $TESTDIR/diartk-test.log 2>&1
if grep -q "command not found" $TESTDIR/diartk-test.log; then
    echo "   DiarTk failed - dependencies (probably HTK)"
    FAILURES=true
else
    if [ -s $TESTDIR/diartk_goldSad_$BASETEST.rttm ]; then
	echo "DiarTk passed the test."
    else
	FAILURES=true
	echo "   DiarTk failed - no output RTTM"
    fi
fi
#rm $TESTDIR/$BASETEST.rttm


#  test Yunitator
echo "Testing Yunitator..."

# let 'er rip
yun="old"
$LAUNCHERS/yunitate.sh $DATADIR/test $yun $KEEPTEMP > $TESTDIR/yunitator-test.log 2>&1 || { echo "   Yunitator failed - dependencies"; FAILURES=true;}
if [ -s $TESTDIR/yunitator_${yun}_$BASETEST.rttm ]; then
    echo "Yunitator passed the test."
else
    FAILURES=true
    echo "   Yunitator failed - no output RTTM"
fi


# Test the evaluation
echo "Testing the evaluation pipeline..."
source activate divime
rm -f $TESTDIR/accuracy_noisemesSad_report.csv
$LAUNCHERS/eval.sh $TESTDIR noisemesSad accuracy > $TESTDIR/eval-test.log ||  { echo "   The evaluation pipeline failed - dependencies"; FAILURES=true;}
# $TESTDIR/.. assumes that eval.sh puts the reference one directory up from the hypotheses
if [ -s $TESTDIR/../accuracy_noisemesSad_report.csv ]; then
    echo "The evaluation pipeline passed the test."
else
    echo "   The evaluation pipeline failed the test - output does not match expected"
    FAILURES=true
fi
conda deactivate


# Testing VCM
echo "Testing VCM..."

$LAUNCHERS/vcm.sh $DATADIR/test $yun $KEEPTEMP > $TESTDIR/vcm-test.log 2>&1 || { echo "   VCM failed - dependencies"; FAILURES=true;}
if [ -s $TESTDIR/vcm_$BASETEST.rttm ]; then
    echo "VCM passed the test."
else
    FAILURES=true
    echo "   VCM failed - no output RTTM"
fi


# Testing WCE
echo "Testing WCE..."

sh estimateWCE.sh $DATADIR/test/ $TESTDIR/WCE_$BASETEST.csv
if [ -s $TESTDIR/WCE_$BASETEST.csv ]; then
    echo "WCE passed the test"
else
    echo "WCE tests failed"
    FAILURES=true
fi


# test finished
if $FAILURES; then
    echo "Some tools did not pass the test, but you can still use others"
else
    echo "Congratulations, everything is OK!"
fi

# results
echo "################################################################################"
echo "To wrap up, we will print out the results of the analyses that we ran during the test."
echo "Compare the following results against the reference results printed out below."
echo "If the numbers are similar, then your system is working ok."
echo "If you see bigger changes, then please paste this output onto an issue on https://github.com/srvk/DiViMe/issues/."
echo "****** YOUR RESULTS BEGIN ******."
for f in /vagrant/$DATADIR/test/*.rttm; do $UTILS/sum-rttm.sh $f; done
echo "****** REFERENCE RESULTS BEGIN ******."
echo "LINES: 101	DURATION SUM: 298.637	FILE: /vagrant/data/VanDam-Daylong/BN32/test/BN32_010007_test.rttm"
echo "LINES: 10	DURATION SUM: 296.23	FILE: /vagrant/data/VanDam-Daylong/BN32/test/diartk_goldSad_BN32_010007_test.rttm"
echo "LINES: 37	DURATION SUM: 31.9	FILE: /vagrant/data/VanDam-Daylong/BN32/test/noisemesSad_BN32_010007_test.rttm"
echo "LINES: 88	DURATION SUM: 212.22	FILE: /vagrant/data/VanDam-Daylong/BN32/test/opensmileSad_BN32_010007_test.rttm"
echo "LINES: 56	DURATION SUM: 63.66	FILE: /vagrant/data/VanDam-Daylong/BN32/test/tocomboSad_BN32_010007_test.rttm"
echo "LINES: 31	DURATION SUM: 24.7	FILE: /vagrant/data/VanDam-Daylong/BN32/test/vcm_BN32_010007_test.rttm"
echo "LINES: 60	DURATION SUM: 42.3	FILE: /vagrant/data/VanDam-Daylong/BN32/test/yunitator_BN32_010007_test.rttm"
echo "****** REFERENCE RESULTS END ******."

echo "Evaluation pipeline YOURS:"
cat /vagrant/data/VanDam-Daylong/BN32/test/eval-test.log
echo "Evaluation pipeline REFERENCE:"
echo "                      detection accuracy true positive true negative false positive false "
echo "                                       %                                                  "
echo "item                                                                                      "
echo "BN32_010007_test.rttm              11.24         30.80          3.11           0.20         267.57"
echo "TOTAL                              11.24         30.80          3.11           0.20         267.57"
