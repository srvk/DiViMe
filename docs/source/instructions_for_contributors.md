# Instructions for contributors


## Before you start

1. Install DiViMe as per the installation instructions.

2. Run the test.sh routine and the test-daylong.sh routine. They will each download audio recordings and annotations that you will need to make sure your tool is compatible with the rest of the work flow.

3. Open Vagrantfile in any text editor and add there what needs to be installed to get your tool to work in this environment. Typically, you'll have something like

`$ git clone http://github.com/srvk/OpenSAT`

## Adapting your tool to the VM environment

4. STEPS MISSING HERE -- EXPLAIN HOW TO TEST THAT TOOL WORKS IN ENVIRONMENT

## Integrating your tool into the DiViMe workflow

6. Write a wrapper allowing users to call on your tool. 

- The wrapper should be written in bash, and it should be called TOOLNAME_STAGE.sh. 
- You choose your own tool's name. Use anything you want except the other names already in use.
- The fixed stages names are: sad (for both speech activity detection and voice activity detection), diar (for speaker diarization and role assignment), and add (for adding annotation dependent on role assignment). Other tools do not have fixed stages names, but you should consider whether they depend only on the sound file input (then use sad) or the talker role input (then use add type).
- Read on for input/output requirements depending on stage.
- This flowchart may help: https://docs.google.com/presentation/d/1vh2rTFdVZDZKh4WQ-UEzzPvHpr4-k-Q6Lf-5fvotRXw/edit#slide=id.g44f4e7b6a3_0_9


5. All tools should read in all .wav files inside data/ and, optionally, associated annotation files, which are in rttm format. 

6. All tools should write into the data/ folder an annotation file for each .wav file; this annotation file should respect the rttm format.

6. Your tool may generate two types of ancillary files: Intermediary representation files, such as features extracted from the wav files; and log files, with detailed information of what was done and how. Intermediary representation files should be deleted. Log files may be stored in the temp/ folder, which will only be accessible from within the VM, and should be deleted if they are large (>5MB). As a reminder, our target user may not be technically advanced, and thus including long technical logs may do more to confuse than to help.

7. For all annotations, we are using the following rttm format throughout (From NIST's 2009 eval plan https://web.archive.org/web/20170119114252/http://www.itl.nist.gov/iad/mig/tests/rt/2009/docs/rt09-meeting-eval-plan-v2.pdf):

** todo: this example is bad: cells are not intelligible and the example in fact violates rttm recommendations**

```
SPEAKER	file17	1	0.00	0.77	<NA>	<NA>	speech	<NA>
SPEAKER	file17	1	0.77	0.61	<NA>	<NA>	nonspeech	<NA>
SPEAKER	file17	1	1.38	2.14	<NA>	<NA>	speech	<NA>
SPEAKER	file17	1	3.52	0.82	<NA>	<NA>	nonspeech	<NA>
```

The columns are: Type file chnl tbeg tdur ortho stype name conf Slat

8. If your tool is of the SAD type (SAD or VAD), it only requires sound as input. It should return one rttm per audio file, named toolname_sad_filename.rttm, which will look like this:

```
SPEAKER	file17	1	0.00	0.77	<NA>	<NA>	speech	<NA>
SPEAKER	file17	1	1.38	2.14	<NA>	<NA>	speech	<NA>

```

9. If your tool is of the Diarization style (diarization or role assignment), it requires both sound and a SAD/VAD as input. Assume the SAD/VAD will be an rttm like the one exemplified in the immediately previous step. Your wrapper should allow the user to pass a sad/vad name tool as parameter. If the user does not provide the vad name, then use the default sad/vad (see end of instructions for list of default tools). In both cases, your wrapper should first check these sad/vad exist and if not, execute a command to generate them (see Instructions for use for instructions on how to use DiViMe's included tools).

10. Your SAD-type tool should return one rttm per audio file, named toolname_diar_filename.rttm, which must look like this:

** todo: copy-paste the example above, remove all information not present at diar or role stage **

10. If your tool is not a VAD/SAD but it is a classifier that assumes only raw acoustic input, then declare it as a sad/vad, and follow the instructions for vad/sad above, except that you'll adapt the rttm output to the classes you typically have. For example, one tool classifies audio into noiseme categories. It returns rttm's like this one:

** todo: put example here, but make sure that the "type" class is not violated by the contents of the subtype column. For example, this is bad (noise should not be class SPEAKER):**

```
SPEAKER family  1       4.2     0.4     noise_ongoing <NA>    <NA>    0.37730383873
SPEAKER family  1       4.6     1.2     background    <NA>    <NA>    0.327808111906
SPEAKER family  1       5.8     1.1     speech        <NA>    <NA>    0.430758684874
SPEAKER family  1       6.9     1.2     background    <NA>    <NA>    0.401730179787
SPEAKER family  1       8.1     0.7     speech        <NA>    <NA>    0.407463937998
SPEAKER family  1       8.8     1.1     background    <NA>    <NA>    0.37258502841
SPEAKER family  1       9.9     1.7     noise_ongoing <NA>    <NA>    0.315185159445 
```

11. If your tool is a classifier that works only on a subtype of speaker (e.g., only on children's speech), then assume that each wav is accompanied by an rttm that has this information noted in column XX.

** todo: add default tool section**

** todo: address "process multiple files in parallel, if possible (like using sbatch?)"**
