#!/bin/bash
# pipeline producing a 3-class diarization (all children, female adult, male adult), a word count estimator for all speaker types, and a vocal class for children speakers
# Okko Räsänen & A. Cristia

SCRIPT_DIR=$(dirname "$0")

if [ "$#" -ne 1 ]; then
DATA_FOLDER="data/to_analysis/"
else
DATA_FOLDER=$1
fi

if [ ! -d "/vagrant/${DATA_FOLDER}/logs/" ]; then
	mkdir /vagrant/${DATA_FOLDER}/logs/
fi

sh ~/launcher/yunitate.sh ${DATA_FOLDER} english > /vagrant/${DATA_FOLDER}/logs/yunitate.log
sh ~/launcher/vcm.sh ${DATA_FOLDER} english > /vagrant/${DATA_FOLDER}/logs/vcm.log
sh WCE_from_SAD_outputs.sh /vagrant/${DATA_FOLDER} yunitator_english > /vagrant/${DATA_FOLDER}/logs/WCE.log

if [ -d "/vagrant/${DATA_FOLDER}/detailed_outputs/" ]; then
rm /vagrant/${DATA_FOLDER}/detailed_outputs/*.rttm
else
mkdir /vagrant/${DATA_FOLDER}/detailed_outputs/
fi

mv /vagrant/${DATA_FOLDER}/*.rttm /vagrant/${DATA_FOLDER}/detailed_outputs/

if [ -d "/vagrant/${DATA_FOLDER}/wav_tmp/" ]; then
rm -rf /vagrant/${DATA_FOLDER}/wav_tmp/
fi

ls /vagrant/${DATA_FOLDER}/detailed_outputs/yunitator*.rttm | sed "s/.*english_//g" > /vagrant/${DATA_FOLDER}/files.txt

cat /vagrant/${DATA_FOLDER}/files.txt | while read -r line ; do
	#get first five cols & speaker col
	awk '{print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $8}' < /vagrant/${DATA_FOLDER}/detailed_outputs/yunitator_english_$line > /vagrant/${DATA_FOLDER}/base.temp

	#add WCE info
	awk '{print $8}' < /vagrant/${DATA_FOLDER}/detailed_outputs/WCE_yunitator_english_$line > /vagrant/${DATA_FOLDER}/wce.temp
	paste /vagrant/${DATA_FOLDER}/base.temp /vagrant/${DATA_FOLDER}/wce.temp > /vagrant/${DATA_FOLDER}/base2.temp

	#sort by speaker column to add the
	sort -k6 /vagrant/${DATA_FOLDER}/base2.temp > /vagrant/${DATA_FOLDER}/base3.temp

	#pull out chi info & complete with empties
	awk '{print "{vcm@ " $8 "}"}' < /vagrant/${DATA_FOLDER}/detailed_outputs/vcm_$line > /vagrant/${DATA_FOLDER}/vcm.temp

	#todo implement adding of ADS for adult lines
	nchi=`wc -l /vagrant/${DATA_FOLDER}/vcm.temp | awk '{print $1}'`
	nall=`wc -l /vagrant/${DATA_FOLDER}/base3.temp | awk '{print $1}'`
	if [ "$nall" -gt "$nchi" ] ; then
		i=$nchi
		while [ "$i" -lt "$nall" ] ; do
			echo "{xds@ 0}" >> /vagrant/${DATA_FOLDER}/vcm.temp
			i=$((i + 1))
		done
	fi
	paste /vagrant/${DATA_FOLDER}/base3.temp /vagrant/${DATA_FOLDER}/vcm.temp > /vagrant/${DATA_FOLDER}/base4.temp
	sort -k4 -n /vagrant/${DATA_FOLDER}/base4.temp | sed "s/.rttm//" | sed "s/NCS/N/" | sed "s/CNS/C/" | awk -F"\t" '{print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $7 "\t" $8 "\t" "<NA>" "\t"  $6}' > /vagrant/${DATA_FOLDER}/${line}.txt
	awk -F"\t" '{print $9 "-wce," $9 "," $4 "," $5 "," $6}' < /vagrant/${DATA_FOLDER}/${line}.txt > /vagrant/${DATA_FOLDER}/${line}_forELAN.txt
	 grep "vcm" /vagrant/${DATA_FOLDER}/${line}.txt | awk -F"\t" '{print $9 "-vcm," $9 "," $4 "," $5 "," $7}'| sed "s/xds@//" | tr -d "{" | tr -d "}" >> /vagrant/${DATA_FOLDER}/${line}_forELAN.txt

	rm /vagrant/${DATA_FOLDER}/*.temp
done
