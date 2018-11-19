#!/bin/bash
#
# Shell script to convert .CHA format to .STM format
# 
# ./cha2stm.sh <basename>.cha produces <basename>.stm
#
# To have this use replacement words instead of marking OOV words as "<unk>"
# swap (uncomment) the last line to change the arguments to parse_cha_xml.sh

BASEDIR=$(dirname $0)

if [ $# -ne 1 ]; then
  echo "Usage: cha2stm.sh <basename>.cha"
  echo
  exit 1;
fi

filename=$(basename "$1")
dirname=$(dirname "$1")
extension="${filename##*.}"
basename="${filename%.*}"

# Install Java 8 and CHATTER
# First get chatter
mkdir -p ~/bin/lib
(
cd ~/bin/lib
if [ ! -f chatter.jar ]; then
  wget http://talkbank.org/software/chatter.jar || exit 1
fi

# now get java 8
if [ -d zulu8.17.0.3-jdk8.0.102-linux_x64 ]; then
  :
  #echo "Not installing Java 8 since it is already there." 1>&2
else
  echo "Downloading and installing Java 8" 1>&2
  wget http://cdn.azul.com/zulu/bin/zulu8.17.0.3-jdk8.0.102-linux_x64.tar.gz 1>&2 || exit 1
  tar -zxvf zulu8.17.0.3-jdk8.0.102-linux_x64.tar.gz 1>&2
  rm zulu8.17.0.3-jdk8.0.102-linux_x64.tar.gz 1>&2
  echo "Done installing Java 8" 1>&2
fi
)

if [ -f $dirname/$basename.cha ]; then
  #
  # First convert CHA to CHATTER xml
  ~/bin/lib/zulu8.17.0.3-jdk8.0.102-linux_x64/bin/java -cp ~/bin/lib/chatter.jar org.talkbank.chatter.App -inputFormat cha -outputFormat xml -output $dirname/$basename.xml $dirname/$basename.cha

  # Convert CHATTER xml to STM
  #python scripts/parse_cha_xml.py $dirname/$basename.xml --stm --replacement
  python $BASEDIR/parse_cha_xml.py $dirname/$basename.xml --stm --oov
fi
