# Speech or Voice activity detection tools

This section contains documentation from the different Speech or Voice activity detection tools. 


## LDC SAD

### General intro

LDC SAD relies on HTK (Young et al., 2002) to band-pass filter and extract PLP features, prior to applying a broad phonetic class recognizer trained on the Buckeye Corpus (Pitt et al., 2002) using a GMM-HMM model. An official release by the LDC is currently in the works.

### Main references: 

Ryant, N. (2018). LDC SAD. https://github.com/Linguistic-Data-Consortium, accessed: 2018-06-17.


### Associated references:

Young, S., Evermann, G., Gales, M., Hain, T. , Kershaw, D., Liu, X., Moore, G., Odell, J., Ollason, D., Povey,D. et al. (2002) The HTK book. Cambridge University Engineering Department.
Pitt, M. A., Johnson, K., Hume, E., Kiesling, S., &  Raymond, W. (2005). The Buckeye corpus of conversational speech: labeling conventions and a test of transcriber reliability. Speech Communication, 45(1), 89–95.

### Questions and bug reports

Not available

## NoisemesSad

### General intro

Noiseme SAD was actually not specifically built as a SAD but rather as  a broader “noiseme classifier”. It is a neural network that can predict frame-level probabilities of 17 types of sound events (called “noisemes”), including speech, singing, engine noise, etc. The network consists of one single bidirectional LSTM layer with 400 hidden units in each direction. It was trained on 10h of basically web videos data (Strassel et al., 2012), with the Theano toolkit. The OpenSMILE toolkit (Eyben et al., 2013) is used to extract 6,669 low-level acoustic features, which are reduced to 50 dimensions with PCA. For our purposes, we summed the probabilities of the classes “speech” and “speech non-english” and labeled a region as speech if this probability was higher than all others.





### Instructions for direct use (ATTENTION, MAY BE OUTDATED)

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

##### Some more technical details

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
5	musicSing
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



### Main references: 

Wang, Y., Neves, L., & Metze, F. (2016, March). Audio-based multimedia event detection using deep recurrent neural networks. In Acoustics, Speech and Signal Processing (ICASSP), 2016 IEEE International Conference on (pp. 2742-2746). IEEE. [pdf](http://www.cs.cmu.edu/~yunwang/papers/icassp16.pdf)


### Associated references:

S.Burger,Q.Jin,P.F.Schulam,andF.Metze,“Noisemes:Man- ual annotation of environmental noise in audio streams,” Carnegie Mellon University, Pittsburgh, PA; U.S.A., Tech. Rep. CMU-LTI- 12-07, 2012.
S.Strassel,A.Morris,J.G.Fiscus,C.Caruso,H.Lee,P.D.Over, J. Fiumara, B. L. Shaw, B. Antonishek, and M. Michel, “Creating havic: Heterogeneous audio visual internet collection,” in Proc.
LREC. Istanbul, Turkey: ELRA, May 2012.
F. Eyben, F. Weninger, F. Gross, and B. Schuller, “Recent developments in opensmile, the munich open-source multimedia fea- ture extractor,” in Proceedings of the 21st ACM international con- ference on Multimedia. ACM, 2013, pp. 835–838.

### Questions and bug reports

http://github.com/srvk/OpenSAT/issues

## OpenSmile SAD


### General intro

openSMILE SAD relies on openSMILE (Eyben et al., 2013a) to generate an 18-coefficient RASTA-PLP plus first order delta features. It then uses a long short-term memory recurrent neural network (see details in Eyben et al., 2013b) that has been pre-trained on two corpora of read and spontaneous speech by adults recorded in laboratory conditions, augmented with various noise types. 

### Some more technical details

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
$ nano /vagrant/conf/vad/vadSegmenter_aclew.conf
```

openSMILE manuals consulted:

- Eyben, F., Woellmer, M., & Schuller, B. (2013). openSMILE: The Munich open Speech and Music Interpretation by Large space Extraction toolkit. Institute for Human-Machine Communication, version 2.0. http://download2.nust.na/pub4/sourceforge/o/project/op/opensmile/openSMILE_book_2.0-rc1.pdf
- Eyben, F., Woellmer, M., & Schuller, B. (2016). openSMILE: open Source Media Interpretation by Large feture-space Extraction toolkit. Institute for Human-Machine Communication, version 2.3. https://www.audeering.com/research-and-open-source/files/openSMILE-book-latest.pdf


### Main references for this tool: 

Eyben, F. Weninger, F. Gross, F., &1 Schuller, B. (2013a). Recent developments in OpenSmile, the Munich open-source multimedia feature extractor. Proceedings of the 21st ACM international conference on Multimedia, 835–838.  

Eyben, F., Weninger, F., Squartini, S., & Schuller, B. (2013b). Real-life voice activity detection with lstm recurrent neural networks and an application to hollywood movies. In Acoustics, Speech and Signal Processing (ICASSP), 2013 IEEE International Conference on (pp. 483-487). IEEE.

### Questions and bug reports

https://www.audeering.com/technology/opensmile/#support

## TOCombo SAD

### General intro

This tool's name stands for "Threshold-Optimized" "combo" SAD; we explain each part in turn. It is a SAD because the goal is to extract speech activity. It is called "combo" because it combines linearly 4 different aspects of voicing (harmonicity , clarity, prediction gain, periodicity) in addition to one perceptual spectral flux feature (see details in Sadjadi & Hansen, 2013). These are extracted in 32-ms frames (with a 10 ms stride). The specific version included here corresponds to the Combo SAD introduced in Ziaei et al. (2014) and used further in Ziaei et al (2016). In this work, a threshold was optimized for daylong recordings, which typically have long silent periods, in order to avoid the usual overly large false alarm rates found in typical SAD systems provided with these data.

### Main references: 

Ziaei, A., Sangwan, A., & Hansen, J. H. (2014). A speech system for estimating daily word counts. In Fifteenth Annual Conference of the International Speech Communication Association. http://193.6.4.39/~czap/letoltes/IS14/IS2014/PDF/AUTHOR/IS141028.PDF
A. Ziaei, A. Sangwan, J.H.L. Hansen, "Effective word count estimation for long duration daily naturalistic audio recordings," Speech Communication, vol. 84, pp. 15-23, Nov. 2016. 
S.O. Sadjadi, J.H.L. Hansen, "Unsupervised Speech Activity Detection using Voicing Measures and Perceptual Spectral Flux," IEEE Signal Processing Letters, vol. 20, no. 3, pp. 197-200, March 2013.

### Questions and bug reports

Not available

# Talker diarization tools

This section contains documentation from the different Talker diarization tools (i.e., given a speech segment, decide who speaks). 


## DiarTK

### General intro

This tool performs diarization, requiring as input not only .wav audio, but also speech/nonspeech in .rttm format, from human annotation, or potentially from one of the SAD or VAD tools included in this VM. 

The DiarTK model imported in the VM is a C++ open source toolkit by Vijayasenan & Valente (2012). The algorithm first extracts MFCC features, then performs non-parametric clustering of the frames using agglomerative information bottleneck clustering. At the end of the process, the resulting clusters correspond to a set of speakers. The most likely Diarization sequence between those speakers is computed by Viterbi realignement.

We use this tool with the following parameter values:

- weight MFCC = 1 (default)
- Maximum Segment Duration 250 (default)
- Maximum number of clusters possible: 10 (default)
- Normalized Mutual Information threshold: 0.5 (default)
- Beta value: 10 (passed as parameter)
- Number of threads: 3 (passed as parameter)


### Main references: 

D. Vijayasenan and F. Valente, “Diartk: An open source toolkit for research in multistream speaker diarization and its application to meetings recordings,” in Thirteenth Annual Conference of the International Speech Communication Association, 2012. https://pdfs.semanticscholar.org/71e3/9d42aadd9ec44a42aa5cd21202fedb5eaec5.pdf

### Questions and bug reports

http://htk.eng.cam.ac.uk/bugs/buglist.shtml


# Other tools

This section contains documentation from other tools. 



## Yunitator

### General intro


Given that there is no reference for this tool, we provide a more extensive introduction based on a presentation Florian Metze gave on 2018-08-13 in an ACLEW Meeting.

The data used for training were:

- ACLEW Starter dataset 
- VanDam public 5-min dataset (about 13h; https://homebank.talkbank.org/access/Public/VanDam-5minute.html); noiseme-sad used to detect and remove intraturn silences

Talker identity annotations collapsed into the following 4 types:

- children (including both the child wearing the device and other children; class prior: .13)
- female adults (class prior .09)
- male adults (class prior .03)
- non-vocalizations  (class prior .75)

The features were MED (multimedia event detection) feature, extracted with OpenSMILE. They were extracted in 2s windows moving 100ms each step. There were 6,669 dims at first, PCA-ed down to 50 dims

The model was a RNN, with 1 bidirectional GRU layer and 200 units in each direction. There was a softmax output layer, which therefore doesn't predict overlaps..

The training regime used 5-fold cross-validation, with 5 models trained on 4/5 of the data and tested on the remainder. The outputs are poooled together to measure performance. The final model was trained on all the data.

The loss function was cross entropy with classes weighted by 1/prior. The batch size was 5 sequences of 500 frames. The optimizer was SGD with Nesterov momentum=.9, the inital LR was .01 and the LR schedule was *=0.8 if frame accuracy doesn’t reach new best in 4 epochs

The resulting F1 for the key classes were:

- Child .55 (Precision .55, recall .55)
- Male adult .43 (P .31, R .61)
- Female adult .55 (P .5, R .62)


### Main references: 

There is no official reference for this tool. 

### Questions and bug reports

Not available

## VCM

### General intro
Two independent models: one (modelLing) to predicts linguistic vs. non-linguistic infant vocalisations; the other one (modelSyll) predicts canonical vs. non-canonical syllables if given a linguistic infant vocalization. 

Specifically, the modelLing was trained on an infant linguistic dataset (refer to this paper: https://static1.squarespace.com/static/591f756559cc68d09fc2e308/t/5b3a94cb758d4645603085db/1530565836736/ZhangEtAl_2018.pdf), and modelSyll was trained on another infant syllable vocalisation dataset (refer to this paper: https://pdfs.semanticscholar.org/2b25/bc84d2c4668e6d17f4f9343106f726198cd0.pdf). 

Feature set: 88 eGeMAPS extracted by openSMILE-2.3.0 on the segment level. 

Model: two hidden layers feed-forward neural networks with 1024 hidden nodes per each hidden layer. A log_softmax layer is stacked as an output layer. The optimiser was set to SGD with a learning rate 0.01, and the batch size is 64.  

Setups: Both the infant linguistic and syllable vocalisation datasets were split into train, development, and test partitions following a speaker independent strategy. 

Results: The results are 67.5% UAR and 76.6% WAR on the test set for the lingustic voc classification; and are 70.4% UAR and 69.2% WAR for the syllable voc classification. 


### Main references: 

There is no official reference for this tool. 

### Questions and bug reports

https://github.com/MilesICL/vcm/issues/


## TalNet

### General intro

There is no information on this tool.

### Main references: 

There is no official reference for this tool. 

### Questions and bug reports

Not available

