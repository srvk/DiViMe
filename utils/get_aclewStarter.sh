#!/bin/bash
#
# author = the ACLEW Team
#
# Use this script to download the aclew Starter from databrary and start using
# it with the DiViMe.
# This script should be launched from the DiViMe folder, which also contains
# the VagrantFile.

# Absolute path to this script. /home/user/bin/foo.sh
SCRIPT=$(readlink -f $0)
# Absolute path this script is in. /home/user/bin
BASEDIR=`dirname $SCRIPT`

# url to dataset in zip format
aclewStarter_url=https://nyu.databrary.org/volume/390/zip/true
aclewStarter_folder=databrary390-Bergelson-Warlaumont-Cristia-Casillas-Rosemberg-Soderstrom-Rowland-Durrant-Bunce-Starter-ACLEW

# create data directory to store dataset and download zip file
if [[ ! -d "aclewStarter" ]]; then
    mkdir $BASEDIR/aclewStarter
fi

cd $BASEDIR/aclewStarter

echo "downloading the ACLEW Starter Dataset..."
wget $aclewStarter_url

# unzip archive and keep data when there is both the audio file and 
# the transcription. Delete the archive file 
unzip true
rm true

# regroup wavs and transcriptions and remove those that don't have a match
cd $aclewStarter_folder
mkdir transcript
mkdir wav

mv sessions/*/*.wav wav/
mv materials*/*.eaf transcript/

echo "processing all the ACLEW Starter files..."
for eaf in $(ls transcript/); do
    base=$(echo $eaf | cut -d '-' -f 1)
    if [[ -f wav/${base}.wav ]]; then
        mv transcript/$eaf transcript/${base}.eaf
        vagrant ssh -c "python varia/elan2rttm.py -i /vagrant/aclewStarter/$aclewStarter_folder/transcript/${base}.eaf -o /vagrant/aclewStarter/"
        mv wav/${base}.wav ../
    else
        rm transcript/$eaf
    fi
done

# When all the files are seen, delete the extracted raw folder
cd ../
rm -rf $aclewStarter_folder

echo "You can now use the ACLEW Starter dataset!"
