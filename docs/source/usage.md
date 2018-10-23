# Use instructions


## Short instructions for all tools

1. Put the files you want to analyze inside the "data" folder inside the DiViMe folder. If your files aren't .wav some of the tools may not work. Please consider converting them into wav with some other program, such as [ffmpeg](https://www.ffmpeg.org/). It is probably safer to make a copy (rather than moving your files into the data folder), in case you later decide to delete the whole folder. 

2. If you have any annotations, put them also in the same "data" folder. Annotations can be in .eaf, .textgrid, or .rttm format, and *they should be named exactly as your wav files*. It is probably safer to make a copy (rather than moving them), in case you later decide to delete the whole vagrant folder. 

3. Launch the virtual machine anytime by navigating to your DiViMe folder on your terminal and performing:

`$ vagrant up`

4. For the SAD tools, type a command like the one below, being careful to type the SAD tool name instead of SADTOOLNAME:

`$ vagrant ssh -c "tools/SADTOOLNAME.sh data/"`

The SAD options are:
- SADTOOLNAME = ldc_sad (coming soon)
- SADTOOLNAME = noisemes_sad
- SADTOOLNAME = opensmile_sad
- SADTOOLNAME = tocombo_sad

This will create a set of new rttm files, with the name of the tool added at the beginning. For example, imagine you have a file called participant23.wav, and you decide to run both the LDC_SAD and the Noisemes analyses. You will run the following commands:


```
$ vagrant ssh -c "tools/opensmile_sad.sh data/"
$ vagrant ssh -c "tools/noisemes_sad.sh data/"
```

And this will result in your having the following three files in your /data/ folder:

- participant23.wav
- opensmile_sad_participant23.rttm
- noisemes_sad_participant23.rttm

If you look inside one of these .rttm's, say the opensmile_sad one, it will look as follows:

```
SPEAKER	participant23	1	0.00	0.77	<NA>	<NA>	speech	<NA>
SPEAKER	participant23	1	1.38	2.14	<NA>	<NA>	speech	<NA>
```

This means that opensmile_sad considered that the first 770 milliseconds of the audio were speech; followed by 610 milliseconds of non-speech, followed by 2.14 seconds of speech; etc.

5. There is one **pure diarization** tool: diartk. Here is the command to run, for the data/ input folder:

`$ vagrant ssh -c "tools/diartk.sh  data/ noisemes_sad"`  

Pure diarization tools only perform talker diarization (i.e., *who* speaks) but not speech activity detection (*when* is someone speaking). Therefore, this system requires some form of SAD. The third parameter ('noisemes') tells the system which SAD annotation to use, from among the list:

- ldc_sad: this means you want the system to use the output of the LDC_SAD system. If you have not run LDC_SAD, the system will run it for you.
- noisemes_sad: this means you want the system to use the output of the noisemes_sad system. If you have not run LDC_SAD, the system will run it for you.
- opensmile_sad: this means you want the system to use the output of the opensmile system. If you have not run opensmile, the system will run it for you.
- tocombo_sad: this means you want the system to use the output of the tocombo_sad system. If you have not ran tocombosad, the system will run it for you.
- textgrid: this means you want the system to use your textgrid annotations. Notice that all tiers count, so if you have some tiers that are non-speech, you should remove them from your textgrids before you start. Please note that the system will convert your textgrids into .rttm in the process.
- eaf: this means you want the system to use your eaf annotations. Notice that all tiers count, so if you have some tiers that are non-speech, you should remove them from your eaf files before you start. Please note that the system will convert your eafs into .rttm in the process.
- rttm: this means you want the system to use your rttm annotations. Notice that all annotations that say "speech" in the eigth column count as such. 

Finally, if no parameter is provided, the system will default to noisemes_sad.

6. There is one **role assignment** tool, which classifies spoken turns into three roles: children, female adults, male adults. It exists in two versions. 

The version we call "yunitator" takes the raw recording as input. To call this one, do

`$ vagrant ssh -c "tools/yunitator.sh data/"`


The version we call "yuniSeg" takes the raw recording as well as a SAD as input. To call this one, do

`$ vagrant ssh -c "tools/yuniSeg.sh data/ noisemes_sad"`

Both of them return one rttm per sound file, with an estimation of where there are vocalizations by children, female adults, and male adults.

For more information on the model underlying them, see the Yunitator section below.

7. If you have some annotations that you have made, you probably want to know how well our tools did - how close they were to your hard-earned human annotations. To find out, type a command like the one below:

`$ vagrant ssh -c "tools/eval.sh data/ noisemes_sad"`

Notice there are 2 parameters provided to the evaluation suite. The first parameter tells the system which folder to analyze (in this case, the whole data/ folder). The second parameter indicates which tool's output to evaluate (in this case, noisemes_sad). The system will use the .rttm annotations if they exist; or the .eaf ones if the former are missing; or the .textgrid of neither .rttm nor .eaf are found. 
If you want to evaluate a diarization produced by the diartk tool, you will have to specify a third parameter, to tell the system which SAD was used to compute the diartk outputs you want to evaluate. E.G. :
`$ vagrant ssh -c "tools/eval.sh data/ diartk noisemes_sad`

8. Last but not least, you should **remember to halt the virtual machine**. If you don't, it will continue running in the background, taking up useful resources! To do so, simply navigate to the DiViMe folder on your terminal and type in:

`$ vagrant halt`

### ACLEW Starter Dataset

The ACLEW Starter dataset is freely available, and can be downloaded in order to test the tools.
To download it, using your terminal, as explained before, go in the DiViMe folder and do:
`$ ./get_aclewStarter.sh`
This will create a folder called aclewStarter, in which you will find the audio files from the public dataset and their corresponding .rttm annotations.

You can then use the tools mentioned before, by replacing the "data/" folder in the command given in the previous paragraph by "aclewStarter/", E.G for noisemes:
```$ vagrant ssh -c "tools/noisemes_sad.sh aclewStarter/"```

Reference for the ACLEW Starter dataset: 

Bergelson, E., Warlaumont, A., Cristia, A., Casillas, M., Rosemberg, C., Soderstrom, M., Rowland, C., Durrant, S. & Bunce, J. (2017). Starter-ACLEW. Databrary. Retrieved August 15, 2018 from http://doi.org/10.17910/B7.390.

## More details for each tool 

### LDC_SAD

Main reference for this tool: 

Ryant, N. (2018). LDC SAD. https://github.com/Linguistic-Data-Consortium, accessed: 2018-06-17.

#### General intro

LDC SAD relies on HTK (Young et al., 2002) to band-pass filter and extract PLP features, prior to applying a broad phonetic class recognizer trained on the Buckeye Corpus (Pitt et al., 2002) using a GMM-HMM model. An official release by the LDC is currently in the works.


Associated references:
Young, S., Evermann, G., Gales, M., Hain, T. , Kershaw, D., Liu, X., Moore, G., Odell, J., Ollason, D., Povey,D. et al. (2002) The HTK book. Cambridge University Engineering Department.
Pitt, M. A., Johnson, K., Hume, E., Kiesling, S., &  Raymond, W. (2005). The Buckeye corpus of conversational speech: labeling conventions and a test of transcriber reliability. Speech Communication, 45(1), 89–95.

### Noisemes_sad

Main reference for this tool: 

Wang, Y., Neves, L., & Metze, F. (2016, March). Audio-based multimedia event detection using deep recurrent neural networks. In Acoustics, Speech and Signal Processing (ICASSP), 2016 IEEE International Conference on (pp. 2742-2746). IEEE. [pdf](http://www.cs.cmu.edu/~yunwang/papers/icassp16.pdf)


#### General intro

This system will classify slices of the audio recording into one of 17 noiseme classes:

-	background	
-	speech	
-	speech non English	
-	mumble	
-	singing	alone
-	music + singing
-	music alone
-	human sounds
-	cheer	
-	crowd sounds
-	animal sounds
-	engine
-	noise_ongoing
-	noise_pulse
-	noise_tone
-	noise_nature
-	white_noise
-	radio


#### Instructions for direct use (ATTENTION, MAY BE OUTDATED)

You can analyze just one file as follows. Imagine that <$MYFILE> is the name of the file you want to analyze, which you've put inside the `data/` folder in the current working directory.

```
$ vagrant ssh -c "OpenSAT/runOpenSAT.sh data/<$MYFILE>"
```

You can also analyze a group of files as follows:

```
$ vagrant ssh -c "OpenSAT/runDiarNoisemes.sh data/"
```

This will analyze all .wav's inside the "data" folder.

Created annotations will be stored inside the same "data" folder.

#### Some more technical details

For more fine grained control, you can log into the VM and from a command line, and play around from inside the "Diarization with noisemes" directory, called "OpenSAT":

```
$ vagrant ssh
$ cd OpenSAT
```

The main script is runOpenSAT.sh and takes one argument: an audio file in .wav format.
Upon successful completion, output will be in the folder (relative to ~/OpenSAT)
`SSSF/data/hyp/<input audiofile basename>/confidence.pkl.gz`

The system will grind first creating features for all the .wav files it found, then will place those features in a subfolder `feature`. Then it will load a model, and process all the features generated, producing output in a subfolder `hyp/` two files per input: `<inputfile>.confidence.mat` and `<inputfile>.confidence.pkl.gz` - a confidence matrix in Matlab v5 mat-file format, and a Python compressed data 'pickle' file. Now, as well, in the `hyp/` folder, `<inputfile>.rttm` with labels found from a config file [noisemeclasses.txt](https://github.com/riebling/OpenSAT/blob/master/noisemeclasses.txt)

-More details on output format-

The 18 classes are as follows:
```
0	background	
1	speech	
2	speech_ne	
3	mumble	
4	singing	
5	music_sing
6	music
7	human	
8	cheer	
9	crowd	
10	animal
11	engine
12	noise_ongoing
13	noise_pulse
14	noise_tone
15	noise_nature
16	white_noise
17	radio
```
The frame length is 0.1s. The system also uses a 2-second window, so the i-th frame starts at (0.1 * i - 2) seconds and finishes at (0.1 * i) seconds. That's why 60 seconds become 620 frames. 'speech_ne' means non-English speech

-Sample RTTM output snippet-
```
SPEAKER family  1       4.2     0.4     noise_ongoing <NA>    <NA>    0.37730383873
SPEAKER family  1       4.6     1.2     background    <NA>    <NA>    0.327808111906
SPEAKER family  1       5.8     1.1     speech        <NA>    <NA>    0.430758684874
SPEAKER family  1       6.9     1.2     background    <NA>    <NA>    0.401730179787
SPEAKER family  1       8.1     0.7     speech        <NA>    <NA>    0.407463937998
SPEAKER family  1       8.8     1.1     background    <NA>    <NA>    0.37258502841
SPEAKER family  1       9.9     1.7     noise_ongoing <NA>    <NA>    0.315185159445 
```

The script `runClasses.sh` works like `runDiarNoisemes.sh`, but produces the more detailed results as seen above.

### OpenSmile_SAD

Main references for this tool: 

Eyben, F. Weninger, F. Gross, F., &1 Schuller, B. (2013a). Recent developments in OpenSmile, the Munich open-source multimedia feature extractor. Proceedings of the 21st ACM international conference on Multimedia, 835–838.  

Eyben, F., Weninger, F., Squartini, S., & Schuller, B. (2013b). Real-life voice activity detection with lstm recurrent neural networks and an application to hollywood movies. In Acoustics, Speech and Signal Processing (ICASSP), 2013 IEEE International Conference on (pp. 483-487). IEEE.

#### General intro

openSMILE SAD relies on openSMILE (Eyben et al., 2013a) to generate an 18-coefficient RASTA-PLP plus first order delta features. It then uses a long short-term memory recurrent neural network (see details in Eyben et al., 2013b) that has been pre-trained on two corpora of read and spontaneous speech by adults recorded in laboratory conditions, augmented with various noise types. 

#### Some more technical details

These are the parameters that are being used with values that depart from the openSMILE default settings (quoted material comes from either of the openSMILE manuals):

monoMixdown = 1, means "mix down all recorded channels to 1 mono channel"
noHeader = 0, means read the RIFF header (don't need to specify the parameters ‘sampleRate’, ‘channels’, and possibly ‘sampleSize’)
preSil = 0.1 "Specifies the amount of silence at the turn beginning in seconds, i.e. the lag of the turn
detector. This is the length of the data that will be added to the current segment prior to
the turn start time received in the message from the turn detector component"; we use a tighter criterion than the default (.2)
postSil = 0.1 "Specifies the amount of silence at the turn end in seconds. This is the length of the data
that will be added to the current segment after to the turn end time received in the message
from the turn detector component."; we use a tighter criterion than the default (.3)

You can change these parameters locally by doing:
```
$ vagrant ssh
$ nano /vagrant/conf/vad/vad_segmenter_aclew.conf
```

openSMILE manuals consulted:

- Eyben, F., Woellmer, M., & Schuller, B. (2013). openSMILE: The Munich open Speech and Music Interpretation by Large space Extraction toolkit. Institute for Human-Machine Communication, version 2.0. http://download2.nust.na/pub4/sourceforge/o/project/op/opensmile/openSMILE_book_2.0-rc1.pdf
- Eyben, F., Woellmer, M., & Schuller, B. (2016). openSMILE: open Source Media Interpretation by Large feture-space Extraction toolkit. Institute for Human-Machine Communication, version 2.3. https://www.audeering.com/research-and-open-source/files/openSMILE-book-latest.pdf



### TOCombo_SAD

Main references for this tool: 

A. Ziaei, A. Sangwan, J.H.L. Hansen, "Effective word count estimation for long duration daily naturalistic audio recordings," Speech Communication, vol. 84, pp. 15-23, Nov. 2016. 
S.O. Sadjadi, J.H.L. Hansen, "Unsupervised Speech Activity Detection using Voicing Measures and Perceptual Spectral Flux," IEEE Signal Processing Letters, vol. 20, no. 3, pp. 197-200, March 2013.

#### General intro

TO BE ADDED 

### DiarTK

Main reference for this tool: 

D. Vijayasenan and F. Valente, “Diartk: An open source toolkit for research in multistream speaker diarization and its application to meetings recordings,” in Thirteenth Annual Conference of the International Speech Communication Association, 2012.

#### General intro

TO BE ADDED 


#### Instructions for direct use

This tool performs diarization, requiring as input not only .wav audio, but also speech/nonspeech in .rttm format as generated by one of the tools above. A script to run DiarTK (also known as ib_diarization_toolkit) can be found in `tools/diartk.sh`. Here is its usage:
```
Usage: diartk.sh <dirname> <transcription>
where dirname is the name of the folder
containing the wav files, and transcription
specifies which transcription you want to use.
Choices are:
  ldc_sad
  noisemes
  textgrid
  eaf
  rttm
```
To invoke the tool from outside the VM, invoke it with a command like:
```
vagrant ssh -c 'tools/diartk.sh data noisemes'
```
where `data/` is in the current working directory, and contains .wav audio as well as speech/nonspeech RTTM files with names based on the tool that generated them, from the set of possible SAD providers `ldc_sad`, `noisemes`, `textgrid`, `eaf`, `rttm` for example `noisemes_sad_myaudio.rttm` or `ldc_sad_myaudio.rttm`


### Yunitator

There is no official reference for this tool. 

#### General intro

Given that there is no reference for this tool, we provide a more extensive introduction based on a presentation Florian Metze gave on 2018-08-13 in an ACLEW Meeting.

The data used for training were:

- ACLEW Starter+ dataset (see Le Franc et al. 2018 Interspeech for explanations and reference)
- Tsimane dataset (idem)
- Data collected from Namibian and Vanuatu children (total of about 24h; recorded, sampled, and annotated like the Tsimane dataset)
- VanDam public 5-min dataset (about 13h; https://homebank.talkbank.org/access/Public/VanDam-5minute.html); noiseme-sad used to detect and remove intraturn silences

Talker identity annotations collapsed into the following 4 types:

- children (including both the child wearing the device and other children; class prior: .13)
- female adults (class prior .09)
- male adults (class prior .03)
- non-vocalizations  (class prior .75)

The features were MED (multimedia event detection) feature, extracted with OpenSMILE. They were extracted in 2s windows moving 100ms each step. There were 6,669 dims at first, PCA’ed down to 50 dims

The model was a RNN, with 1 bidirectional GRU layer and 200 units in each direction. There was a softmax output layer, which therefore doesn’t predict overlaps..

The training regime used 5-fold cross-validation, with 5 models trained on 4/5 of the data and tested on the remainder. The outputs are poooled together to measure performance. The final model was trained on all the data.

The loss function was cross entropy with classes weighted by 1/prior. The batch size was 5 sequences of 625 frames (in order to accommodate the fact that many of the clips were 1 minute long). The optimizer was Adam, the inital LR was .001 and the LR schedule was *=.999 every epoch.

The resulting F1 for the key classes were:

- Child .55 (Precision .5, recall .61)
- Female adult .44 (P .41, R .48)
- Male adult .24 (P .22, R .28)



### LDC Diarization Scoring

Main references for this tool: 

Ryant, N. (2018). LDC SAD. https://github.com/Linguistic-Data-Consortium, accessed: 2018-06-17.
Ryant, N. (2018). Diarization evaluation. https://github.com/nryant/dscore, accessed: 2018-06-17.

#### General intro

For SAD, we employ the evaluation included in the LDC SAD, which returns the false alarm (FA) rate (proportion of frames labeled as speech that were non-speech in the gold annotation) and missed speech rate (proportion of frames labeled as non-speech that were speech in the gold annotation). For TD, we employ the evaluation developed for the DiHARD Challenge, which returns a Diarization error rate (DER), which sums percentage of speaker error (mismatch in speaker IDs), false alarm speech (non-speech segments assigned to a speaker) and missed speech (unassigned speech).

One important consideration is in order: What to do with files that have no speech to begin with, or where the system does not return any speech at the SAD stage or any labels at the TD stage. This is not a case that is often discussed in the litera- ture because recordings are typically targeted at moments where there is speech. However, in naturalistic recordings, some ex- tracts may not contain any speech activity, and thus one must adopt a coherent framework for the evaluation of such instances. We opted for the following decisions.

If the gold annotation was empty, and the SAD system returned no speech labels, then the FA = 0 and M = 0; but if the SAD system returned some speech labels, then FA = 100 and M = 0. Also, if the gold annotation was not empty and the sys- tem did not find any speech, then this was treated as FA = 0 and M=100.

As for the TD evaluation, the same decisions were used above for FA and M, and the following decisions were made for mismatch. If the gold annotation was empty, regardless of what the system returned, the mismatch rate was treated as 0. If the gold annotation was empty but a pipeline returned no TD labels (either because the SAD in that system did not detect any speech, or because the diarization failed), then this was penalized via a miss of 100 (as above), but not further penalized in terms of talker mismatch, which was set at 0.


