# WUT
This repository contains wrappers to use all the tools available inside the ACLEW Diarization VM.
These wrappers were created in order to create a more simple user experience

## Overall summary

### SAD tools
```
ldc_sad.sh
noisemes_sad.sh
noisemes_full.sh
opensmile_sad.sh
tocombo_sad.sh
```
### Talker Diarization tools
```
diartk.sh
yunitate.sh
yuniSeg.sh
```
### Scoring tools
```
eval.sh
evalDiar.sh
evalSAD.sh
```
### VM Self-test
```
test.sh
```
### Utilities
```
chat2stm.sh
check_folder.sh
chunk.sh
high_volubility.py
parse_cha_xml.py
```


## Further information about some of these



### elan2rttm.py

Convert annotations made using the ELAN tool, in .eaf format, into rttm transcriptions. Please note that, using this script, some information is lost, notably
the vocal maturity annotation (coded in tier vcm@CHI), does not appear in the RTTM format. These information could be retrieved and put in the rttm. If you need this information in the RTTM, please raise an issue on github.

### textgrid2rttm.py

Convert annotations made using Praat, in .TextGrid format, into rttm transcriptions. Requires:

* [pympi](https://github.com/dopefishh/pympi) 
* [tgt](https://github.com/hbuschme/TextGridTools/)

### adjust_timestamps.py

This script is specific to the data in ACLEW, with the ACLEW annotations conventions. It takes as input a daylong recording in wav format (available on databrary), and a transcription in .eaf format that contains annotated segment coded in an "on_off" tier (or "code" tier for some corpora that were annotated before the new convention).
It then takes each annotated segment of 2 minutes, extract it from the daylong recording to output a small wav file of 2 minutes, with the name: 
corpus_id_onset_offset.wav
where corpus is the name of the original corpus, id is the name of the daylong recording (which is itself the id given to the recorded child), onset is where the segment starts in the daylong recording (in seconds, with 6 digits padded with 0's if necessary), offset is where the segment ends in the daylong recording (with the same convention).
For each of these segments extracted, it also writes the annotations in rttm format, with the timestamps adapted to correspond to the small wav, and with the same name as the small wav previously written.

### remove_overlap_rttm.py

Take a transcription in RTTM format, and convert it to a SAD annotation in RTTM format. The SAD annotation contains less information, as it only indicated "speech" segment (i.e. the talker is written as "speech", no matter who the original talker is), and there are no overlap between speech segments.

### make_big_corpus.sh 

This script is called to treat all the daylong recording with their annotations, using the previous adjust_timestamps.py script. It also creates gold SAD rttm using the remove_overlap_rttm.py script previously described. 

## Further info on the formats

### RTTM

RTTM is an annotaion format for audio files well designed for diarization. Explanations about how to write and read .rttm files can be found [here](https://catalog.ldc.upenn.edu/docs/LDC2004T12/RTTM-format-v13.pdf)
This format is used by the [DiViMe](https://github.com/srvk/DiViMe).

We provide code to translate annotations from other formats into RTTM:

**ELAN .eaf fromat**

WARNING: the current version does not handle subtypes when parsing annotations e.g. TIER\_ID 'CHI' would be written in the RTTM output file but 'vmc@CHI' would not. This is due to the time references being based on other TIER\_ID's annotations for subtypes. 

You should run the script as follows:

```
python elan2rttm.py -i my_file.eaf -o my_output_folder
```

**Praat TextGrid format**

You should run the script as follows:

```
python textgrid2rttm.py my_input_folder
```
### TextGrid

TextGrid is a standard format for speech annotation, used by the Praat software.

### Eaf

Eaf is a standard format for speech annotation, that allows for rich annotation, used by the Elan software.
