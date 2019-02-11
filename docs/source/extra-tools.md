# Extra tools

## Getting sample data

### ACLEW Starter Dataset

The ACLEW Starter dataset is freely available, and can be downloaded in order to test the tools.
To download it, using your terminal, as explained before, go in the DiViMe folder and do:
```$ vagrant ssh -c "launcher/get_aclewStarter.sh data/aclewStarter/"```

This will create a folder called aclewStarter inside data, in which you will find the audio files from the public dataset and their corresponding .rttm annotations. At the present time, there are only two matched annotation-wav files, totalling 10 minutes of running recordings

You can then use the tools mentioned before, by replacing the "data/" folder in the command given in the previous paragraph by "aclewStarter/", E.G for noisemes:

```$ vagrant ssh -c "launcher/noisemesSad.sh /"```

#### Reference for the ACLEW Starter dataset: 

Bergelson, E., Warlaumont, A., Cristia, A., Casillas, M., Rosemberg, C., Soderstrom, M., Rowland, C., Durrant, S. & Bunce, J. (2017). Starter-ACLEW. Databrary. Retrieved August 15, 2018 from http://doi.org/10.17910/B7.390.


## Using scripts in the Utilities

### elan2rttm.py

Convert annotations made using the ELAN tool, in .eaf format, into rttm transcriptions. Please note that, using this script, some information is lost, notably
the vocal maturity annotation (coded in tier vcm@CHI), does not appear in the RTTM format. These information could be retrieved and put in the rttm. If you need this information in the RTTM, please raise an issue on github.

### textgrid2rttm.py

Convert annotations made using Praat, in .TextGrid format, into rttm transcriptions. Requires:

* [pympi](https://github.com/dopefishh/pympi) 
* [tgt](https://github.com/hbuschme/TextGridTools/)

We provide code to translate annotations from other formats into RTTM:

**ELAN .eaf format**

WARNING: the current version does not handle subtypes when parsing annotations e.g. TIER\_ID 'CHI' would be written in the RTTM output file but 'vmc@CHI' would not. This is due to the time references being based on other TIER\_ID's annotations for subtypes. 

From within the machine, you would run the script as follows:

```
python utils/elan2rttm.py -i my_file.eaf -o my_output_folder
```

**Praat TextGrid format**

From within the machine, you would run the script as follows:

```
python utils/textgrid2rttm.py my_input_folder
```


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



