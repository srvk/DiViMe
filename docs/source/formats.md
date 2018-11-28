# Formats

This section explains the input and output formats. Each type of tool returns a different type of output, depending on the key information.

### Input: TextGrid

TextGrid is a standard format for speech annotation, used by the Praat software. Notice that all tiers count, so if you have some tiers that are non-speech, you should remove them from your textgrids before you start. Please note that the system will convert your textgrids into .rttm in the process.

### Input: Eaf

Eaf is a standard format for speech annotation, that allows for rich annotation, used by the Elan software. Notice that we only know how to properly process .eaf files that follow the [ACLEW Annotation Scheme](https://osf.io/b2jep/wiki/home/). Please note that the system will convert your eafs into .rttm in the process.


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




