=========== END =====

TO ADD SOMEWHERE ELSE
Specific examples for the different tool types
- If your tool is of the SAD type (SAD or VAD), it only requires sound as input. It should return one rttm per audio file, named toolnameSad_filename.rttm, which will look like this:

```
SPEAKER file17 1 0.00 0.77	<NA> <NA> speech <NA>
SPEAKER file17 1 1.38 2.14	<NA> <NA> speech <NA>

```

- If your tool is of the Diarization style (diarization or role assignment), it requires both sound and a SAD/VAD as input. Assume the SAD/VAD will be an rttm like the one exemplified in the previous bulletpoint. Your wrapper should allow the user to pass a sad/vad name tool as parameter. If the user does not provide the vad name, then provide them with a clear error, such as “TOOLNAME failed because you did not provide a sad/vad annotation file. Please refer to the docs for the list of available sad/vad tools.”. Your diarization-type tool should return one rttm per audio file, named toolnameDiar_filename.rttm, which must look like this:

```
SPEAKER family  1       4.2     0.4     noise_ongoing <NA>    <NA>    0.37730383873
SPEAKER family  1       4.6     1.2     background    <NA>    <NA>    0.327808111906
SPEAKER family  1       5.8     1.1     speech        <NA>    <NA>    0.430758684874
SPEAKER family  1       6.9     1.2     background    <NA>    <NA>    0.401730179787
SPEAKER family  1       8.1     0.7     speech        <NA>    <NA>    0.407463937998
SPEAKER family  1       8.8     1.1     background    <NA>    <NA>    0.37258502841
SPEAKER family  1       9.9     1.7     noise_ongoing <NA>    <NA>    0.315185159445 
```

- If your tool is not a VAD/SAD but it is a classifier that assumes only raw acoustic input, then declare it as a sad/vad, and follow the instructions for vad/sad above, except that you'll adapt the rttm output to the classes you typically have. For example, one tool classifies audio into noiseme categories. It returns rttm's like this one:


```
SPEAKER family  1       4.2     0.4     noise_ongoing <NA>    <NA>    0.37730383873
SPEAKER family  1       4.6     1.2     background    <NA>    <NA>    0.327808111906
SPEAKER family  1       5.8     1.1     speech        <NA>    <NA>    0.430758684874
SPEAKER family  1       6.9     1.2     background    <NA>    <NA>    0.401730179787
SPEAKER family  1       8.1     0.7     speech        <NA>    <NA>    0.407463937998
SPEAKER family  1       8.8     1.1     background    <NA>    <NA>    0.37258502841
SPEAKER family  1       9.9     1.7     noise_ongoing <NA>    <NA>    0.315185159445 
```
** todo: expand diar tool section**

- If your tool is a classifier or annotator that works only on a subtype of speaker (e.g., only on children's speech, or only on adults’ speech), then assume that each wav is accompanied by an rttm that has this information noted in column XX.

** todo: expand add tool section**

