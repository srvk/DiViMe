# Formats

This section explains the input and output formats. 

## Overview

The basic file format within DiViMe is a modified form of [rttm](https://catalog.ldc.upenn.edu/docs/LDC2004T12/RTTM-format-v13.pdf), which is standard in key diarization tasks, and which allows us to evaluate most tools using a standardized evaluation routine. The different ways of using this same general format are explained below.

Many users, however, will be interested in knowing how to convert into and out of this format into something that is more commonly used for annotation. DiViMe includes routines to convert from any .TextGrid file (produced by the program [Praat](praat.org)); from any .cha file (produced by the program [CLAN](http://dali.talkbank.org/clan/)); and from .eaf files (produced by the program [ELAN](https://tla.mpi.nl/tools/tla-tools/elan/)) that have been generated using the [ACLEW Annotation Scheme](https://osf.io/b2jep/wiki/home/) template. Users who rely on a different program (or for .eaf, on a different template) are advised to use the tools in their program or similar others to convert into one of these, or directly into the [rttm](https://catalog.ldc.upenn.edu/docs/LDC2004T12/RTTM-format-v13.pdf) format explained further below. We also provide code to convert the .its files outputted by the [LENA(R)](www.lena.org) software, so you can evaluate them against your own coding and/or DiViMe's output.

The following subsections explain how to convert from each of these input formats into a basic reference [rttm](https://catalog.ldc.upenn.edu/docs/LDC2004T12/RTTM-format-v13.pdf).

### Input: TextGrid

Our process assumes that you will have the speech of each talker diarized in a different tier, using filled intervals when the person is talking, and empty intervals when they are not talking. 

Notice that all tiers count, so if you have some tiers that are non-speech, you should remove them from your textgrids before you start. For example, if you have three tiers associated with a talker, coding e.g., what they say, how they say it, and to whom, you should remove 2 of these three tiers, because otherwise each of these tiers will be treated as a different talker. 

Furthermore, any interval that is empty will be seen as *not* containing vocalizations from that speaker. Thus, if your coding is sparse (i.e., if you have a day-long recording, but have only coded some clips here and there), then you should extract the audio clips and annotations for the sections that have been coded, and not process the whole day-long recording. (If you do, then your evaluation will be off, because all the speech found in sections you have not coded count towards false positives, as if the system had found speech when none was there.)

Additionally, the name of the tier is what will be taken to be the speaker's name. Therefore, if you have tiers that code speech by a speaker but are named differently, change the tier's name before starting. In fact, some of the tools assume a specific set of names, and thus the tool's output can only be properly evaluated if you use those names. In particular, the child wearing the recording device should be called "CHI". Other children should be called "XC0", where the X is the child's sex (F for Female, M for Male, U for uncertain/undecided/unknown) and 0 is a number 0-9 to identify a unique child. Similarly, adults should be called "XA0" where the X is the child's sex (F for Female, M for Male, U for uncertain/undecided/unknown) and 0 is a number 0-9 to identify a unique adult. Further, you can also define "XU0", a person of unknown age; and "EE0," a voice from a non-human source, such as a toy, radio, or TV.

Once you have removed all tiers that do not pertain to speakers, made sure that all the empty intervals really are non-vocalizations, renamed the tiers with the speaker's name, and ideally used this set of names, you are ready to convert your .TextGrid files into [rttm](https://catalog.ldc.upenn.edu/docs/LDC2004T12/RTTM-format-v13.pdf). After you have put all the files you want to convert inside the folder data/mydata/, you would next run:

```
vagrant ssh -c "textgrid2rttm_folder.sh $j"
```

### Input: cha

Our process extracts time stamps from bullet points, assuming that all vocalizations are coded. Therefore, if some of your entries do not have bullet points (e.g., "*CHI: 0 [=! crying]."), they will be treated as if there was no speech/vocalizations at that point. Furthermore, additional pre-processing steps are necessary if your coding is sparse (i.e., if you have a day-long recording, but have only coded some clips here and there) since our automatic extraction method has no way of knowing that you have skipped sections. If this is the case, then you should extract the audio clips and annotations for the sections that have been coded, and not process the whole day-long recording. (If you do, then your evaluation will be off, because all the speech found in sections you have not coded count towards false positives, as if the system had found speech when none was there.)

Additionally, some of the tools assume a specific set of names, and thus the tool's output can only be properly evaluated if you use those names. In particular, the child wearing the recording device should be called "CHI". Other children should be called "XC0", where the X is the child's sex (F for Female, M for Male, U for uncertain/undecided/unknown) and 0 is a number 0-9 to identify a unique child. Similarly, adults should be called "XA0" where the X is the child's sex (F for Female, M for Male, U for uncertain/undecided/unknown) and 0 is a number 0-9 to identify a unique adult. Further, you can also define "XU0", a person of unknown age; and "EE0," a voice from a non-human source, such as a toy, radio, or TV.

Once you have made sure that all lines of interest has bullet points, that there are no regions of the recording that have been skipped, and (if you want to use all tools) that your speakers follow this naming convention, you are ready to convert your .cha files into [rttm](https://catalog.ldc.upenn.edu/docs/LDC2004T12/RTTM-format-v13.pdf). After you have put all the files you want to convert inside the folder data/mydata/, you would next run:

```
vagrant ssh -c "chat2rttm_folder.sh data/mydata/"
```
### Input: Eaf

Since .eaf files can vary a lot in structure, we only provide tools to properly process .eaf files that follow the [ACLEW Annotation Scheme](https://osf.io/b2jep/wiki/home/) template. One of the perks of using this format is that you can make full use of all tools in DiViMe, including a phonologization of your orthographic transcriptions into phonemic transcriptions, which will allow you to evaluate WCE in your data. For the phonologization stage, you need to provide the language, which can be: spanish, english, tzeltal. 

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



Tools that are of the speech/voice activity detection type return one [rttm](https://catalog.ldc.upenn.edu/docs/LDC2004T12/RTTM-format-v13.pdf) per audio file, named toolnameSad_filename.rttm, which looks like this:

```
SPEAKER file17 1 0.00 0.77 <NA> <NA> speech <NA>
SPEAKER file17 1 1.38 2.14 <NA> <NA> speech <NA>

```

The third column indicates the onset of a region; the forth column the duration of that region. All other columns may be ignored. Regions of non-speech are all the others (e.g., in this example, between .77 and 1.38).

## Output: rttm's from diarization tools

Diarization-type tools return one [rttm](https://catalog.ldc.upenn.edu/docs/LDC2004T12/RTTM-format-v13.pdf) per audio file, named toolnameDiar_filename.rttm, which looks like this:

```
SPEAKER file17 1 4.2 0.4 <NA> <NA> talker0 <NA>
SPEAKER file17 1 5.8 1.1 <NA> <NA> talker1 <NA> 
SPEAKER file17 1 6.9 1.2 <NA> <NA> talker2 <NA>
SPEAKER file17 1 8.1 0.7 <NA> <NA> talker1 <NA>  
```

The third column indicates the onset of a region, the forth column the duration of that region; and the identity of the speaker being indicated in the eighth column. All other columns may be ignored. Regions of non-speech are all the others (e.g., in this example, between 4.6 and 5.8).


## Output: rttm's from talker type tools

Talker type tools return one [rttm](https://catalog.ldc.upenn.edu/docs/LDC2004T12/RTTM-format-v13.pdf) per audio file, named toolname_filename.rttm, which looks like this:

```
SPEAKER file17 1 4.2 0.4 <NA> <NA> CHI <NA>
SPEAKER file17 1 5.8 1.1 <NA> <NA> FA <NA> 
SPEAKER file17 1 6.9 1.2 <NA> <NA> MA <NA>
SPEAKER file17 1 8.1 0.7 <NA> <NA> FA <NA>  
```

The third column indicates the onset of a region, the forth column the duration of that region; and the speaker type being indicated in the eighth column: CHI is the key child, C is a child (target or other), FA is female adult, MA is male adult. All other columns may be ignored. Regions of non-speech are all the others (e.g., in this example, between 4.6 and 5.8).

## Output: rttm's from vocal maturity tools

Vocal maturity tools return one [rttm](https://catalog.ldc.upenn.edu/docs/LDC2004T12/RTTM-format-v13.pdf) per audio file, named toolname_filename.rttm, which looks like this:


```
SPEAKER FILENAME 1 31.4 1.6 <NA> <NA> CNS 0.71 <NA>
SPEAKER FILENAME 1 34.6 1.1 <NA> <NA> NCS 0.81 <NA>
SPEAKER FILENAME 1 39.0 0.8 <NA> <NA> CRY 0.80 <NA>
SPEAKER FILENAME 1 47.9 0.5 <NA> <NA> NCS 0.62 <NA>
```
The third column indicates the onset of a region, the forth column the duration of that region; and the vocalization type being indicated in the eighth column: canonical syllable (CNS), non-cannoical syllable (NCS), crying (CRY), and others (OTH, normally refer to laughing); followed by the likelihood of that class (higher means the system was more "certain"). All other columns may be ignored. Regions of non-vocalization as well as regions where people other than the child vocalize are not marked (e.g., in this example, between 33 and 34.6).
