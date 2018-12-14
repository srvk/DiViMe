# Formats

This section explains the input and output formats for each type of tool, and how to convert your files between them.

## Overview

The basic file format within DiViMe is a modified form of rttm, which is standard in key diarization tasks, and which allows us to evaluate all tools using a standardized evaluation routine. The different ways of using this same general format are explained below.

Many users, however, will be interested in knowing how to convert into and out of this format into something that is more commonly used for annotation of day-long and other developmental recordings. DiViMe includes routines to convert from any .TextGrid file (produced by the program [Praat](praat.org)); from any .cha file (produced by the program [CLAN](MISSING LINK)); and from .eaf files (produced by the program [ELAN](MISSING LINK)) that have been generated using the [ACLEW Annotation Scheme](https://osf.io/b2jep/wiki/home/). Users who rely on a different program (or for .eaf, on a different file structure) are advised to use the tools in their program or similar others to convert into one of these, or directly into the rttm format explained below.

The following subsections explain how to convert from each of these input formats into a basic reference rttm.

### Input: TextGrid

TextGrid is a standard format for speech annotation, used by the Praat software. Our process assumes that you will have the speech of each talker diarized in a different tier, using filled intervals when the person is talking, and empty intervals when they are not talking. 

Notice that all tiers count, so if you have some tiers that are non-speech, you should remove them from your textgrids before you start. For example, if you have three tiers associated with a talker, coding e.g., what they say, how they say it, and to whom, you should remove 2 of these three tiers, because otherwise each of these tiers will be treated as a different talker. 

Furthermore, any interval that is empty will be seen as *not* containing vocalizations from that speaker. Thus, if your coding is sparse (i.e., if you have a day-long recording, but have only coded some clips here and there), then you should extract the audio clips and annotations for the sections that have been coded, and not process the whole day long recording. (If you do, then your evaluation will be off, because all the speech systems found in sections you have not coded count towards false positives, as if the system had found speech when none was there.)

Additionally, the name of the tier is what will be taken to be the speaker's name. Therefore, if you have tiers that code speech of some speaker but are named differently, change the tier's name before starting. In fact, some of the tools assume a specific set of names, and thus the tool's output can only be properly evaluated if you use those names. In particular, the child wearing the recording device should be called "CHI". Other children should be called "XC0", where the X is the child's sex (F for Female, M for Male, U for uncertain/undecided/unknown) and 0 is a number 0-9 to identify a unique child. Similarly, adults should be called "XA0" where the X is the child's sex (F for Female, M for Male, U for uncertain/undecided/unknown) and 0 is a number 0-9 to identify a unique adult. Further, you can also define "XU0", a person of unknown age; and "EE0," a voice from a non-human source, such as a toy, radio, or TV.

Once you have removed all tiers that do not pertain to speakers, made sure that all the empty intervals really are non-vocalizations, renamed the tiers with the speaker's name, and ideally used this set of names, you are ready to convert your .TextGrid files into rttm. Assuming you have put all the textgrids you want to convert inside the folder data/mydata/, you would next run:

```
vagrant ssh -c "textgrid2rttm.py data/mydata/"
```

### Input: cha


### Input: Eaf

Eaf is a standard format for speech annotation, that allows for rich annotation, used by the Elan software. Since .eaf's can vary a lot in structure, we only provide tools to properly process .eaf files that follow the [ACLEW Annotation Scheme](https://osf.io/b2jep/wiki/home/). Assuming you have put all the textgrids you want to convert inside the folder data/mydata/, you would next run:

```
vagrant ssh -c "eaf2txt.py data/mydata/"
vagrant ssh -c "eaf2enriched_txt.sh data/mydata/"
```

The first line serves to create the rttm that will be used by most tools. The second creates an annotation that will be needed for the WCE.

If your annotations do not follow the ACLEW Annotation Scheme, please look into converting them into something else (.TextGrid or .cha) using ELAN's conversion tools; or potentially try to modify your annotations to fit the [ACLEW Annotation Scheme](https://osf.io/b2jep/wiki/home/).

### Input: its





## Speech or Voice activity detection output

RTTM is an annotation format for audio files well designed for diarization. Explanations about how to write and read .rttm files can be found [here](https://catalog.ldc.upenn.edu/docs/LDC2004T12/RTTM-format-v13.pdf)
This format is used by the [DiViMe](https://github.com/srvk/DiViMe).


Tools that are of the SAD type (SAD or VAD) return one rttm per audio file, named toolnameSad_filename.rttm, which looks like this:

```
SPEAKER file17 1 0.00 0.77	<NA> <NA> speech <NA>
SPEAKER file17 1 1.38 2.14	<NA> <NA> speech <NA>

```

The fourth column indicates the onset of a speech region; the forth column the duration of that speech region. All other columns may be ignored. Regions of non-speech are all the others (e.g., in this example, between .77 and 1.38).

## Diarization style (diarization or role assignment) output

RTTM is an annotation format for audio files well designed for diarization. Explanations about how to write and read .rttm files can be found [here](https://catalog.ldc.upenn.edu/docs/LDC2004T12/RTTM-format-v13.pdf)
This format is used by the [DiViMe](https://github.com/srvk/DiViMe).


Diarization-type tools return one rttm per audio file, named toolnameDiar_filename.rttm, which looks like this:

```
SPEAKER file17  1       4.2     0.4  <NA>   talker0	<NA>
SPEAKER file17  1       4.6     1.2  <NA>   talker0	<NA>
SPEAKER file17  1       5.8     1.1  <NA>   talker1	<NA> 
SPEAKER file17  1       6.9     1.2  <NA>   talker0	<NA>
SPEAKER file17  1       8.1     0.7  <NA>   talker1	<NA>  
```


The fourth column indicates the onset of a region, the identity being indicated in ; the forth column the duration of that speech region. All other columns may be ignored. Regions of non-speech are all the others (e.g., in this example, between .77 and 1.38).




