# Noisemes_sad

## General intro

Noiseme SAD was actually not specifically built as a SAD but rather as  a broader “noiseme classifier”. It is a neural network that can predict frame-level probabilities of 17 types of sound events (called “noisemes”), including speech, singing, engine noise, etc. The network consists of one single bidirectional LSTM layer with 400 hidden units in each direction. It was trained on 10h of basically web videos data (Strassel et al., 2012), with the Theano toolkit. The OpenSMILE toolkit (Eyben et al., 2013) is used to extract 6,669 low-level acoustic features, which are reduced to 50 dimensions with PCA. For our purposes, we summed the probabilities of the classes “speech” and “speech non-english” and labeled a region as speech if this probability was higher than all others.





## Instructions for direct use (ATTENTION, MAY BE OUTDATED)

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



## Main references: 

Wang, Y., Neves, L., & Metze, F. (2016, March). Audio-based multimedia event detection using deep recurrent neural networks. In Acoustics, Speech and Signal Processing (ICASSP), 2016 IEEE International Conference on (pp. 2742-2746). IEEE. [pdf](http://www.cs.cmu.edu/~yunwang/papers/icassp16.pdf)


## Associated references:

S.Burger,Q.Jin,P.F.Schulam,andF.Metze,“Noisemes:Man- ual annotation of environmental noise in audio streams,” Carnegie Mellon University, Pittsburgh, PA; U.S.A., Tech. Rep. CMU-LTI- 12-07, 2012.
S.Strassel,A.Morris,J.G.Fiscus,C.Caruso,H.Lee,P.D.Over, J. Fiumara, B. L. Shaw, B. Antonishek, and M. Michel, “Creating havic: Heterogeneous audio visual internet collection,” in Proc.
LREC. Istanbul, Turkey: ELRA, May 2012.
F. Eyben, F. Weninger, F. Gross, and B. Schuller, “Recent developments in opensmile, the munich open-source multimedia fea- ture extractor,” in Proceedings of the 21st ACM international con- ference on Multimedia. ACM, 2013, pp. 835–838.