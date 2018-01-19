This virtual machine (intended to be installed with [Vagrant](https://www.vagrantup.com/) following the pattern of the one at http://github.com/srvk/eesen-transcriber) contains a collection of tools (some currently under development) used by the diarization team at JSalt 2017. Please feel free to submit pull requests, especially documentation and examples, as you learn more about how to use these. This is meant to be a place where collaboration can occur to improve and share the state of the art of diarization tools.

Note on installing HTK:

HTK is used by some of these tools (until we find a replacement). We are not allowed to distribute HTK, so you have to get it yourself. First download it, following the link that reads "HTK source code (tar+gzip archive)" on the HTK download page http://htk.eng.cam.ac.uk/download.shtml . Place the resulting file HTK-3.4.1.tar.gz in the root folder of this repository (alongside Vagrantfile) and then 'vagrant up' will install it into the VM automatically.

# Index of tools provided in this VM:

 * [Yunitator](https://github.com/srvk/DiarizationVM/blob/master/README.md#yunitator)
 * [Diairzation Using Noisemes](https://github.com/srvk/DiarizationVM#diarization-using-noisemes)
 * [DiarTK](https://github.com/srvk/DiarizationVM#diartk-also-known-as-ib-diarization-toolkit)
 * [LDC Speech Activity Detection](https://github.com/srvk/DiarizationVM#ldc-speech-activity-detection)
 * [LDC Diairization Scoring](https://github.com/srvk/DiarizationVM#ldc-diarization-scoring)
 * [LENA Clean](https://github.com/srvk/DiarizationVM#lena-clean)
 * [Interslice (part of Festvox)](https://github.com/srvk/DiarizationVM#interslice-part-of-festvox)
 * [LIUM](https://github.com/srvk/DiarizationVM#lium)

# Yunitator

Classifies speech into 5-7 classes. Trainable. Coming soon.

# Diarization Using Noisemes

To run

After `vagrant up` completes, from the host machine, a quickstart test: `vagrant ssh -c "OpenSAT/runOpenSAT.sh /vagrant/test.wav"`
which should produce the output:
```
Extracting features for test.wav ...
(MSG) [2] in SMILExtract : openSMILE starting!
(MSG) [2] in SMILExtract : config file is: /vagrant/MED_2s_100ms_htk.conf
(MSG) [2] in cComponentManager : successfully registered 95 component types.
(MSG) [2] in cComponentManager : successfully finished createInstances
                                 (19 component instances were finalised, 1 data memories were finalised)
(MSG) [2] in cComponentManager : starting single thread processing loop
(MSG) [2] in cComponentManager : Processing finished! System ran for 168 ticks.
DONE!
Filename /home/vagrant/OpenSAT/SSSF/data/feature/evl.med.htk/test.htk
Predicting for /home/vagrant/OpenSAT/SSSF/data/feature/evl.med.htk/test ...
Connection to 127.0.0.1 closed.
```
For more fine grained control, `vagrant ssh` into the VM and from a command line,
and for convenience, CD to the OpenSAT home directory with `cd OpenSAT`
The main script is runOpenSAT.sh and takes one argument: an audio file in .wav format.
Upon successful completion, output will be in the folder (relative to ~/OpenSAT)
`SSSF/data/hyp/<input audiofile basename>/confidence.pkl.gz`

For convenience, the data file is actually linked to storage on the host computer,
creating a folder `data` symlinked to the `data` folder mentioned above, and
visible to the VM as `/vagrant/data`

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

# DiarTK (also known as IB Diarization Toolkit)

To run quick selftest, first 
```
cd ~/ib_diarization_toolkit
```
then type 
```
bash scripts/run.diarizeme.sh data/mfcc/AMI_20050204-1206.fea data/scp/AMI_20050204-1206.scp result.dir/ AMI_20050204-1206
```
to run the selftest. The output should look like:
```
-----------------------------------Initialize HMM
```
This places first stage of output in the `result.dir` folder.
To get scores, and assuming dscore has been installed in the VM (it has!), give the shell command:
```
perl ../dscore/scorelib/md-eval-22.pl -m -afc -c 0.25 -r data/rttm/AMI_20050204-1206.rttm -s result.dir/AMI_20050204-1206.rttm
```
This should produce output:
```
command line (run on 2017 Sep 6 at 19:47:33) Version: 22  ../dscore/scorelib/md-eval-22.pl -m -afc -c 0.25 -r data/rttm/AMI_20050204-1206.rttm -s result.dir/AMI_20050204-1206.rttm

Time-based metadata alignment

Metadata evaluation parameters:
    time-optimized metadata mapping
        max gap between matching metadata events = 1 sec
        max extent to match for SU's = 0.5 sec

Speaker Diarization evaluation parameters:
    The max time to extend no-score zones for NON-LEX exclusions is 0.5 sec
    The no-score collar at SPEAKER boundaries is 0.25 sec

Exclusion zones for evaluation and scoring are:
                             -----MetaData-----        -----SpkrData-----
     exclusion set name:     DEFAULT    DEFAULT        DEFAULT    DEFAULT
     token type/subtype      no-eval   no-score        no-eval   no-score
             (UEM)              X                         X
         LEXEME/un-lex                    X                          
        NON-LEX/breath                                              X
        NON-LEX/cough                                               X
        NON-LEX/laugh                                               X
        NON-LEX/lipsmack                                            X
        NON-LEX/other                                               X
        NON-LEX/sneeze                                              X
        NOSCORE/<na>            X         X               X         X
 NO_RT_METADATA/<na>            X                                    
             SU/unannotated               X                          
'FEE029' => 'AMI_20050204-1206_spkr_0'
   194.48 secs matched to 'AMI_20050204-1206_spkr_0'
    13.92 secs matched to 'AMI_20050204-1206_spkr_1'
    12.18 secs matched to 'AMI_20050204-1206_spkr_3'
    14.04 secs matched to 'AMI_20050204-1206_spkr_5'
     2.61 secs matched to 'AMI_20050204-1206_spkr_6'
     7.24 secs matched to 'AMI_20050204-1206_spkr_9'
'FEE030' => 'AMI_20050204-1206_spkr_5'
     9.92 secs matched to 'AMI_20050204-1206_spkr_0'
     9.11 secs matched to 'AMI_20050204-1206_spkr_1'
     4.47 secs matched to 'AMI_20050204-1206_spkr_3'
    67.64 secs matched to 'AMI_20050204-1206_spkr_5'
     1.76 secs matched to 'AMI_20050204-1206_spkr_6'
     7.75 secs matched to 'AMI_20050204-1206_spkr_9'
'FEE032' => 'AMI_20050204-1206_spkr_9'
     9.65 secs matched to 'AMI_20050204-1206_spkr_0'
     1.44 secs matched to 'AMI_20050204-1206_spkr_1'
     4.98 secs matched to 'AMI_20050204-1206_spkr_3'
     7.28 secs matched to 'AMI_20050204-1206_spkr_5'
     0.81 secs matched to 'AMI_20050204-1206_spkr_6'
   138.52 secs matched to 'AMI_20050204-1206_spkr_9'
'MEE031' => 'AMI_20050204-1206_spkr_3'
     6.44 secs matched to 'AMI_20050204-1206_spkr_0'
     0.57 secs matched to 'AMI_20050204-1206_spkr_1'
   106.65 secs matched to 'AMI_20050204-1206_spkr_3'
     5.10 secs matched to 'AMI_20050204-1206_spkr_5'
     5.02 secs matched to 'AMI_20050204-1206_spkr_9'

*** Performance analysis for Speaker Diarization for c=1 f=AMI_20050204-1206 ***

    EVAL TIME =    712.73 secs
  EVAL SPEECH =    576.41 secs ( 80.9 percent of evaluated time)
  SCORED TIME =    455.71 secs ( 63.9 percent of evaluated time)
SCORED SPEECH =    400.01 secs ( 87.8 percent of scored time)
   EVAL WORDS =      0        
 SCORED WORDS =      0         (100.0 percent of evaluated words)
---------------------------------------------
MISSED SPEECH =      0.00 secs (  0.0 percent of scored time)
FALARM SPEECH =      0.00 secs (  0.0 percent of scored time)
 MISSED WORDS =      0         (100.0 percent of scored words)
---------------------------------------------
SCORED SPEAKER TIME =    408.56 secs (102.1 percent of scored speech)
MISSED SPEAKER TIME =      8.56 secs (  2.1 percent of scored speaker time)
FALARM SPEAKER TIME =      0.00 secs (  0.0 percent of scored speaker time)
 SPEAKER ERROR TIME =     27.37 secs (  6.7 percent of scored speaker time)
SPEAKER ERROR WORDS =      0         (100.0 percent of scored speaker words)
---------------------------------------------
 OVERALL SPEAKER DIARIZATION ERROR = 8.79 percent of scored speaker time  `(c=1 f=AMI_20050204-1206)
---------------------------------------------
 Speaker type confusion matrix -- speaker weighted
  REF\SYS (count)      unknown               MISS              
unknown                   4 / 100.0%          0 /   0.0%
  FALSE ALARM             2 /  50.0%
---------------------------------------------
 Speaker type confusion matrix -- time weighted
  REF\SYS (seconds)    unknown               MISS              
unknown              400.01 /  97.9%       8.56 /   2.1%
  FALSE ALARM          0.00 /   0.0%
---------------------------------------------

*** Performance analysis for Speaker Diarization for ALL ***

    EVAL TIME =    712.73 secs
  EVAL SPEECH =    576.41 secs ( 80.9 percent of evaluated time)
  SCORED TIME =    455.71 secs ( 63.9 percent of evaluated time)
SCORED SPEECH =    400.01 secs ( 87.8 percent of scored time)
   EVAL WORDS =      0        
 SCORED WORDS =      0         (100.0 percent of evaluated words)
---------------------------------------------
MISSED SPEECH =      0.00 secs (  0.0 percent of scored time)
FALARM SPEECH =      0.00 secs (  0.0 percent of scored time)
 MISSED WORDS =      0         (100.0 percent of scored words)
---------------------------------------------
SCORED SPEAKER TIME =    408.56 secs (102.1 percent of scored speech)
MISSED SPEAKER TIME =      8.56 secs (  2.1 percent of scored speaker time)
FALARM SPEAKER TIME =      0.00 secs (  0.0 percent of scored speaker time)
 SPEAKER ERROR TIME =     27.37 secs (  6.7 percent of scored speaker time)
SPEAKER ERROR WORDS =      0         (100.0 percent of scored speaker words)
---------------------------------------------
 OVERALL SPEAKER DIARIZATION ERROR = 8.79 percent of scored speaker time  `(ALL)
---------------------------------------------
 Speaker type confusion matrix -- speaker weighted
  REF\SYS (count)      unknown               MISS              
unknown                   4 / 100.0%          0 /   0.0%
  FALSE ALARM             2 /  50.0%
---------------------------------------------
 Speaker type confusion matrix -- time weighted
  REF\SYS (seconds)    unknown               MISS              
unknown              400.01 /  97.9%       8.56 /   2.1%
  FALSE ALARM          0.00 /   0.0%
---------------------------------------------
```
## More on DiarTK

I had some luck, finally, figuring out the crazy formats required to run DiarTK.  It seems
like we have to do a lot of work first, before it can be used - and then, all it provides is
clustering.  I'll try and talk about the inputs in sections.

1. HTK Features. First we need HTK installed - it is, in the VM, in ~/htk.  Next we need
a configuration file that instructs HTK to produce MFCC features in a usable format.

Since DiarTK gives us no info on the specifics of these MFCC features, the best we can hope
(at first) is to try to match as closely as possible the settings in the example input provided with DiarTK. 
My best guess at a config file so far, which works for some test cases, looks like this:

```
# Coding parameters                                                                                                                 
SOURCEFORMAT = WAV *
TARGETKIND = MFCC_K *
TARGETRATE = 100000.0 *
#SAVECOMPRESSED = T                                                                  
SAVEWITHCRC = T
WINDOWSIZE = 250000.0
USEHAMMING = T
PREEMCOEF = 0.97
NUMCHANS = 26
CEPLIFTER = 22
NUMCEPS = 19
ENORMALISE = F
```
* Of these, I know with confidence the values with asterisks are required, and with less confidence,
the necessity (or optimum values of) the others. Shame that DiarTK never once
mentions what might be optimum values for these MFCC features(!)

2. Speech/non-speech (.scp) file

This was also somewhat mysterious, but less so than I'd thought. The format is described in
the help message for DiarTK as containing time values for "frames". I think they mean frames
of the same size of the HTK MFCC features (10 ms)

Aside: Looking at the provided example, we notice the speech/non-speech file contains overlaps.
So it seems to accept multiple, overlapping speakers. I'm not sure how DiarizationVM users
are going to create such speech/nonspeech .SCP files, but wouldn't it be great if the
format accepted was RTTM! :)

3. Output

Seems that DiarTK creates speaker IDs in the RTTM output based on the input filename,
that is, speaker IDs like "spkr_3, spkr_2, spr_0" etc. as a suffix, appended to input filename
with underscores.

CONCLUSION

I will be providing more code, in the form of a run script and example HTK config and
example speech/nonspeech segmentation
that have worked for me - somewhat. I have not delved into experimenting with different
MFCC configurations (the black arts!), but have at least verified that we can take audio,
take a "known good" SCP file corresponding to that, and automatically create HTK MFCC
features, pipe them into DiarTK, and get it to run to completion. (with 'errors' but also
producing what looks like reasonable RTTM)

Next Steps:

 * Try running this on other audio
 * Improve the run script (with respect to output naming conventions)
 * Accept RTTM format for speech/nonspeech segments

Example inputs:

 * audio from the VM: "/vagrant/test2.wav"
 * the following speech/nonspeech .scp file (adapted from a diarization provided by LIUM)

test2_9_646=test2.fea[9,646]
test2_646_934=test2.fea[646,934]
test2_934_1434=test2.fea[934,1434]

Example output in *diartk_output/diartk_result.out*:
```
SPEAKER diartk_result 1 0.09 1.86 <NA> <NA> diartk_result_spkr_0 <NA>
SPEAKER diartk_result 1 1.95 2.50 <NA> <NA> diartk_result_spkr_1 <NA>
SPEAKER diartk_result 1 4.45 2.86 <NA> <NA> diartk_result_spkr_2 <NA>
SPEAKER diartk_result 1 7.31 2.50 <NA> <NA> diartk_result_spkr_3 <NA>
SPEAKER diartk_result 1 9.81 4.53 <NA> <NA> diartk_result_spkr_4 <NA>
```
This might still be "bad results" based on the following DiarTK log, the fact there's an
error, and the fact that it produced 5 clusterings of what was only 1 speaker (Bill Gates).
But it's also "good results" in the sense that the system goes all the way to produce an
RTTM file from 'unseen' audio and segments, not just the provided sample

*diartk_output/diartk_result.out*:
```
 AIB diarization started at 421028


 MFCC:   diartk_output/diartk.fea  weight MFCC  1

 Maximum Segment Duration 250


 AIB is running with the following parameters

 Maximum number of clusters possible:           10
 Normalized Mutual Information threshold:               0.5
 Beta value:            10
 Number of threads:             3


 Reading and Processing the scp file
number of segments inside = 1
Number of vectors = 1426
Feat file diartk_output/diartk.fea of type 0
Reading feature file diartk_output/diartk.fea
frame dim: 19
num_vec = 1426
Attempting memory allocation.
Memory successully allocated.
Reading file ...
all segments read
Number of segments in the file = 6
num_vec = 1426  idx = 0
compute features after: 0.003785


 The matrix seems ok
 Final Matrix size after zero removal 6 6
 The initial MI values are: 0.198307 1.79176 1.78782
 Initializing the Delta -- Computing 6 times 6 Distances
Running time 0


 Now Clustering

 Size: 5 Ity: 0.198307 Ht: 1.79176 Ity_div_Itx:  1  Ht_div_Hx:   1
 Size: 4 Ity: 0.182216 Ht: 1.56071 Ity_div_Itx:  0.918859  Ht_div_Hx:   0.871049
 Size: 3 Ity: 0.159873 Ht: 1.24245 Ity_div_Itx:  0.806192  Ht_div_Hx:   0.693426
 Size: 2 Ity: 0.135922 Ht: 1.0114 Ity_div_Itx:  0.685412  Ht_div_Hx:   0.564475
 Size: 1 Ity: 0.0825654 Ht: 0.450561 Ity_div_Itx:  0.416352  Ht_div_Hx:   0.251463

 Size: 0 Ity: 4.35763e-16 Ht: 5.55112e-17 Ity_div_Itx:  2.19742e-15  Ht_div_Hx:   3.09814e-17
Saving this solution
0  4.35763e-16  0.198307  2.19742e-15
1  0.0825654  0.198307  0.416352
2  0.135922  0.198307  0.685412
3  0.159873  0.198307  0.806192
4  0.182216  0.198307  0.918859
5  0.198307  0.198307  1
Key to solution 6 NMI value0.5
 The clustering has finished. Now saving the solution in diartk_output/diartk_result.clust.out
 ...and saying goodbye


last speech frame = 1434 total number of speech frames = 1425
training the rkl hmm
ERROR!!!!
For the Segmentation, nSamples = 1425, nClass = 6
Segmentation Over with Viterbi score = 152094.875000
The htk file sample rate 100000
Diarization stopped at 421028
Running time 0 seconds
compute features after: 0.003785
aib clustering after: 0.001519
realignment after: 0.026994
```
Compare this to 'good' output from the DiarTK provided examples, in result.dir/AMI_20050204-1206.out
```
AIB diarization started at 421000


 MFCC:   data/mfcc/AMI_20050204-1206.fea  weight MFCC  1

 Maximum Segment Duration 250


 AIB is running with the following parameters

 Maximum number of clusters possible:           10
 Normalized Mutual Information threshold:               0.5
 Beta value:            10
 Number of threads:             3


 Reading and Processing the scp file
number of segments inside = 205
Number of vectors = 57862
Feat file data/mfcc/AMI_20050204-1206.fea of type 0
Reading feature file data/mfcc/AMI_20050204-1206.fea
frame dim: 19
num_vec = 57862
Attempting memory allocation.
Memory successully allocated.
Reading file ...
all segments read
Number of segments in the file = 348
num_vec = 57862  idx = 0
compute features after: 5.59014


 The matrix seems ok
 Final Matrix size after zero removal 348 348
 The initial MI values are: 2.21969 5.8522 5.55255
 Initializing the Delta -- Computing 348 times 348 Distances
Running time 5


 Now Clustering

 Size: 9 Ity: 0.809603 Ht: 1.97374 Ity_div_Itx:  0.364737  Ht_div_Hx:   0.337264
 Size: 8 Ity: 0.781671 Ht: 1.94187 Ity_div_Itx:  0.352154  Ht_div_Hx:   0.331819
 Size: 7 Ity: 0.738984 Ht: 1.83024 Ity_div_Itx:  0.332923  Ht_div_Hx:   0.312744
 Size: 6 Ity: 0.69973 Ht: 1.78634 Ity_div_Itx:  0.315238  Ht_div_Hx:   0.305243
 Size: 5 Ity: 0.656557 Ht: 1.70897 Ity_div_Itx:  0.295788  Ht_div_Hx:   0.292022
 Size: 4 Ity: 0.58882 Ht: 1.5636 Ity_div_Itx:  0.265272  Ht_div_Hx:   0.267182
 Size: 3 Ity: 0.513768 Ht: 1.3676 Ity_div_Itx:  0.23146  Ht_div_Hx:   0.233689
 Size: 2 Ity: 0.403177 Ht: 0.965252 Ity_div_Itx:  0.181637  Ht_div_Hx:   0.164938
 Size: 1 Ity: 0.225073 Ht: 0.555933 Ity_div_Itx:  0.101398  Ht_div_Hx:   0.0949955

 Size: 0 Ity: -5.96019e-12 Ht: -3.70814e-14 Ity_div_Itx:  -2.68515e-12  Ht_div_Hx:   -6.33632e-15
Saving this solution
0  -5.96019e-12  2.21969  -2.68515e-12
1  0.225073  2.21969  0.101398
2  0.403177  2.21969  0.181637
3  0.513768  2.21969  0.23146
4  0.58882  2.21969  0.265272
5  0.656557  2.21969  0.295788
6  0.69973  2.21969  0.315238
7  0.738984  2.21969  0.332923
8  0.781671  2.21969  0.352154
9  0.809603  2.21969  0.364737
Key to solution 10 NMI value0.5
 The clustering has finished. Now saving the solution in result.dir//AMI_20050204-1206.clust.out
 ...and saying goodbye


last speech frame = 198312 total number of speech frames = 57862
training the rkl hmm
Warning: Mean is inf!
Warning: Mean is inf!
Warning: Mean is inf!
Warning: Mean is inf!
Warning: Mean is inf!
For the Segmentation, nSamples = 57862, nClass = 10
Segmentation Over with Viterbi score = -33770.875000
The htk file sample rate 100000
Diarization stopped at 421000
Running time 19 seconds
compute features after: 5.59014
aib clustering after: 14.9433
realignment after: 3.34305
```

# LDC Speech Activity Detection

See README in [ldc_sad_hmm](https://github.com/riebling/ldc_sad_hmm/blob/master/README.md)  
Tools are installed in `~/ldc_sad_hmm`

# LDC Diarization Scoring

See README in [dscore](https://github.com/riebling/dscore/blob/master/README.md)  
Tools are installed in `~/dscore`

# LENA Clean

See [lena-clean](https://github.com/rajatkuls/lena-clean)  
Tools are installed in `~/lena-clean`

A brief description of the code (https://github.com/rajatkuls/lena-clean):

First, it checks the energy of all frames of the dataset. It takes the 5% with higher energy and then trains a classifier over this 5% of data. The class targets for this data will be the categories that you need (e.g. adult father, adult mother, baby, etc.). Once this is trained, the algorithm will check the energy of each frame, if it overcomes a certain threshold the frame will be classified.

    * extractFeatures.py: This script extracts the features for a dataset. You can use this to extract features from 159 or daylong.
    * parseCha.py: It converts files to a cha format. Cha format is something that psicologist uses to anotate recordings (@Charles any thoughts about this?)
    * wrap_*:  Each wrap_* scripts goes with a config_*. They form the different steps of the pipeline.
        - Tunning the speech not speech. Lower threshold and upper threshold. Train a SVM. Takes the top 5 % of the energy and trains a classifier.
        - Given the train model from a, it generate speech non speech test label. The labels are in STM format (audacity file).
        - Now that we have the labels, we can define how many classes and train our classifier. 
        - It allows you to test your model with any dataset (159, long day recordings).
        - Given ground truth labels and your hypothesis you can score your model.
        - Runs test and score multiple times
    * wrap-*-subpr.py: Those scripts are used just to parallelize each step so you can test/score different implementations in parallel.
    
Here you can find some presentation made during summer workshop: https://docs.google.com/presentation/d/1lxorvcWccjJdvKxyU9K6AfXuXCjEcNXX2by2scKJAZo/edit?ts=59cd0f98

# Interslice (part of Festvox)

See [Festvox Documentation](http://www.festvox.org)  
Tools are installed in `~/festvox/src/interslice`

Hints on running interslice:
```
cd /home/vagrant/festvox/src/interslice
export FESTVOXDIR=/home/vagrant/festvox
export ESTDIR=/home/vagrant/speech_tools
scripts/do_islice_v2.sh setup
scripts/do_islice_v2.sh islice <txt file> <wav file>
```
# LIUM

See [http://lium3.univ-lemans.fr/](http://lium3.univ-lemans.fr/)

To run an example, cd to the `LIUM` folder and try the `diarization.sh` example script, which takes 2 arguments: name of input WAV file, and a folder into which to place output (files named show.*):
```
vagrant@vagrant-ubuntu-trusty-64:~/LIUM$ ./diarization.sh /vagrant/test2.wav outfile
#####################################################
#   show
#####################################################
07:12.607                CONFIG| cmdLine: --fInputMask=/vagrant/test2.wav 1 0 1000000000 U U U 1 --fInputDesc=audio2sphinx,1:1:0:0:0:0,13,0:0:0 --sInputMask=outfile/show.uem.seg --sOutputMask=./outfile/show.i.seg show
07:12.616 MSegInit       INFO  | Initialization of the segmentation	{make() / 10}
07:12.820 AudioFeatureSetWARNIN| segment is out of featureSet, correct end of segment :1000000000-->1435	{checkEndOfSegmentation() / 10}
07:12.821 MSegInit       FINER | check segment : 0 1435	{detectEqualFeatures() / 10}
07:12.822 MSegInit       WARNIN| two consecutive features are the same, index = 1	{detectEqualFeatures() / 10}
07:12.822 MSegInit       WARNIN| two consecutive features are the same, index = 2	{detectEqualFeatures() / 10}
07:12.823 MSegInit       WARNIN| two consecutive features are the same, index = 3	{detectEqualFeatures() / 10}
07:12.823 MSegInit       WARNIN| two consecutive features are the same, index = 4	{detectEqualFeatures() / 10}
07:12.824 MSegInit       WARNIN| two consecutive features are the same, index = 5	{detectEqualFeatures() / 10}
07:12.825 MSegInit       WARNIN| two consecutive features are the same, index = 6	{detectEqualFeatures() / 10}
07:12.825 MSegInit       WARNIN| two consecutive features are the same, index = 7	{detectEqualFeatures() / 10}
07:12.871 MSegInit       FINER | check segment : 9 1435	{detectLikelihoodProblem() / 10}
07:12.900 ClusterSet     INFO  | --> write ClusterSet : ./outfile/show.i.seg / show	{write() / 10}
07:12.079                CONFIG| cmdLine: --fInputDesc=audio2sphinx,1:3:2:0:0:0,13,0:0:0 --fInputMask=/vagrant/test2.wav 1 0 1000000000 U U U 1 --sInputMask=./outfile/show.i.seg --sOutputMask=./outfile/show.pms.seg --dPenality=500,500,10 --tInputMask=models/sms.gmms show
07:12.122 MDecode        INFO  | fast decoding, Number of GMM=3	{make() / 10}
07:12.124 MDecode        FINE  | 	 decoder.accumulation starting at 9 to 1434	{make() / 10}
07:12.355 FastDecoderWithWARNIN| score == Double.NEGATIVE_INFINITY start=9 end=10 value=0.0	{computeLogLikelihoodModel() / 10}
07:12.357 FastDecoderWithWARNIN| score == Double.NEGATIVE_INFINITY start=9 end=10 value=0.0	{computeLogLikelihoodModel() / 10}
07:12.358 FastDecoderWithWARNIN| score == Double.NEGATIVE_INFINITY start=9 end=10 value=0.0	{computeLogLikelihoodModel() / 10}
07:12.459 MDecode        FINE  | 	 decoder.get result	{make() / 10}
07:12.459 ClusterSet     INFO  | --> write ClusterSet : ./outfile/show.pms.seg / show	{write() / 10}
07:12.679                CONFIG| cmdLine: --kind=FULL --sMethod=GLR --fInputMask=/vagrant/test2.wav 1 0 1000000000 U U U 1 --fInputDesc=audio2sphinx,1:1:0:0:0:0,13,0:0:0 --sInputMask=./outfile/show.i.seg --sOutputMask=./outfile/show.s.seg show
07:12.689 MSeg           INFO  | Segmentation	{make() / 10}
07:12.690 MSeg           FINE  | 	 do Measures	{make() / 10}
07:12.009 MSeg           FINE  | 	 do Borders	{make() / 10}
07:12.015 MSeg           FINE  | 	 do Clusters	{make() / 10}
07:12.017 ClusterSet     INFO  | --> write ClusterSet : ./outfile/show.s.seg / show	{write() / 10}
./diarization.sh: line 120: [: ==: unary operator expected
07:12.200                CONFIG| cmdLine: --fInputMask=/vagrant/test2.wav 1 0 1000000000 U U U 1 --fInputDesc=audio2sphinx,1:1:0:0:0:0,13,0:0:0 --sInputMask=./outfile/show.s.seg --sOutputMask=./outfile/show.l.seg --cMethod=l --cThr=2.5 show
07:12.210 MainTools      WARNIN| error: file not found show.gmm	{readGMMContainer() / 10}
07:12.211 MClust         INFO  | Clustering: l	{make() / 10}
07:12.214 MClust         INFO  | BEGIN CLUSTERING date: Tue Oct 31 19:12:31 UTC 2017 time in ms:1509477151211	{make() / 10}
07:12.436 MClust         FINE  | 	merge: score = -372.03638756048736 ci = 0(S0) cj = 1(S1)	{gaussianHACRightToLeft() / 10}
07:12.437 ClusterSet     INFO  | --> MERGE: S0 in S1	{mergeCluster() / 10}
07:12.438 MClust         FINE  | 	merge: score = -619.0098331642811 ci = 0(S0) cj = 1(S2)	{gaussianHACRightToLeft() / 10}
07:12.439 ClusterSet     INFO  | --> MERGE: S0 in S2	{mergeCluster() / 10}
07:12.440 ClusterSet     INFO  | --> write ClusterSet : ./outfile/show.l.seg / show	{write() / 10}
07:12.621                CONFIG| cmdLine: --fInputMask=/vagrant/test2.wav 1 0 1000000000 U U U 1 --fInputDesc=audio2sphinx,1:1:0:0:0:0,13,0:0:0 --sInputMask=./outfile/show.l.seg --sOutputMask=./outfile/show.h.seg --cMethod=h --cThr=6 show
07:12.630 MainTools      WARNIN| error: file not found show.gmm	{readGMMContainer() / 10}
07:12.630 MClust         INFO  | Clustering: h	{make() / 10}
07:12.633 MClust         INFO  | BEGIN CLUSTERING date: Tue Oct 31 19:12:31 UTC 2017 time in ms:1509477151630	{make() / 10}
07:12.857 ClusterSet     INFO  | --> write ClusterSet : ./outfile/show.h.seg / show	{write() / 10}
07:12.030                CONFIG| cmdLine: --nbComp=8 --kind=DIAG --fInputMask=/vagrant/test2.wav 1 0 1000000000 U U U 1 --fInputDesc=audio2sphinx,1:1:0:0:0:0,13,0:0:0 --sInputMask=./outfile/show.h.seg --tOutputMask=./outfile/show.init.gmms show
07:12.039 MTrainInit     INFO  | Initialize models	{make() / 10}
07:12.040 MTrainInit     FINE  | 	 initialize cluster=S0	{make() / 10}
07:12.437                CONFIG| cmdLine: --nbComp=8 --kind=DIAG --fInputMask=/vagrant/test2.wav 1 0 1000000000 U U U 1 --fInputDesc=audio2sphinx,1:1:0:0:0:0,13,0:0:0 --sInputMask=./outfile/show.h.seg --tOutputMask=./outfile/show.gmms --tInputMask=./outfile/show.init.gmms show
07:12.454 MTrainEM       INFO  | Train models using EM	{make() / 10}
07:12.455 MTrainEM       FINE  | 	 train cluster=S0	{compute() / 10}
07:12.686 GMMFactory     FINER | NbComp=8 first llh=-4.619751947159961	{getEM() / 10}
07:12.700 GMMFactory     FINER | 	 i=0 llh=-1.959379174119463 delta=2.660372773040498	{getEM() / 10}
07:12.710 GMMFactory     FINER | 	 i=1 llh=-1.2108954825487788 delta=0.7484836915706843	{getEM() / 10}
07:12.719 GMMFactory     FINER | 	 i=2 llh=-0.9504858899167001 delta=0.26040959263207863	{getEM() / 10}
07:12.727 GMMFactory     FINER | 	 i=3 llh=-0.6364698265571541 delta=0.314016063359546	{getEM() / 10}
07:12.737 GMMFactory     FINER | 	 i=4 llh=-0.4195932254912232 delta=0.21687660106593093	{getEM() / 10}
07:12.756 GMMFactory     FINER | 	 i=5 llh=-0.329466469336977 delta=0.0901267561542462	{getEM() / 10}
07:12.761 GMMFactory     FINER | 	 i=6 llh=-0.26273271648254976 delta=0.06673375285442723	{getEM() / 10}
07:12.767 GMMFactory     FINER | 	 i=7 llh=-0.21115767854964748 delta=0.05157503793290227	{getEM() / 10}
07:12.770 GMMFactory     FINER | 	 i=8 llh=-0.18847750171683253 delta=0.022680176832814952	{getEM() / 10}
07:12.773 GMMFactory     FINER | 	 i=9 llh=-0.180143586370226 delta=0.008333915346606519	{getEM() / 10}
07:12.947                CONFIG| cmdLine: --fInputMask=/vagrant/test2.wav 1 0 1000000000 U U U 1 --fInputDesc=audio2sphinx,1:1:0:0:0:0,13,0:0:0 --sInputMask=./outfile/show.h.seg --sOutputMask=./outfile/show.d.seg --dPenality=250 --tInputMask=outfile/show.gmms show
07:12.966 MDecode        INFO  | fast decoding, Number of GMM=1	{make() / 10}
07:12.968 MDecode        FINE  | 	 decoder.accumulation starting at 9 to 1433	{make() / 10}
07:12.213 MDecode        FINE  | 	 decoder.get result	{make() / 10}
07:12.214 ClusterSet     INFO  | --> write ClusterSet : ./outfile/show.d.seg / show	{write() / 10}
07:12.388                CONFIG| cmdLine: --fInputMask=/vagrant/test2.wav 1 0 1000000000 U U U 1 --fInputDesc=audio2sphinx,1:1:0:0:0:0,13,0:0:0 --sInputMask=./outfile/show.d.seg --sOutputMask=./outfile/show.adj.h.seg show
07:12.397 MfccMlpConcat  INFO  | Adjust the bounady of segmentation	{make() / 10}
07:12.398 ClusterSet     INFO  | --> write ClusterSet : ./outfile/show.adj.h.seg / show	{write() / 10}
07:12.574                CONFIG| cmdLine: --fInputDesc=audio2sphinx,1:3:2:0:0:0,13,0:0:0 --fInputMask=/vagrant/test2.wav 1 0 1000000000 U U U 1 --fltSegMinLenSpeech=150 --fltSegMinLenSil=25 --sFilterClusterName=music --fltSegPadding=25 --sFilterMask=./outfile/show.pms.seg --sInputMask=./outfile/show.adj.h.seg --sOutputMask=./outfile/show.flt1.seg show
07:12.581 SFilter        INFO  | Filter segmentation using: music	{make() / 10}
07:12.631 SFilter        FINER | remove segment less than param.segMinLenSpeech=150	{removeSmall() / 10}
07:12.632 ClusterSet     INFO  | --> write ClusterSet : ./outfile/show.flt1.seg / show	{write() / 10}
07:12.827                CONFIG| cmdLine: --fInputDesc=audio2sphinx,1:3:2:0:0:0,13,0:0:0 --fInputMask=/vagrant/test2.wav 1 0 1000000000 U U U 1 --fltSegMinLenSpeech=150 --fltSegMinLenSil=25 --sFilterClusterName=jingle --fltSegPadding=25 --sFilterMask=./outfile/show.pms.seg --sInputMask=./outfile/show.flt1.seg --sOutputMask=./outfile/show.flt2.seg show
07:12.834 SFilter        INFO  | Filter segmentation using: jingle	{make() / 10}
07:12.877 SFilter        FINER | remove segment less than param.segMinLenSpeech=150	{removeSmall() / 10}
07:12.878 ClusterSet     INFO  | --> write ClusterSet : ./outfile/show.flt2.seg / show	{write() / 10}
07:12.038 Parameter     WARNIN| : unrecognized option '--sSegMaxLenModel=2000'
07:12.043                CONFIG| cmdLine: --sFilterMask=./outfile/show.pms.seg --sFilterClusterName=iS,iT,j --sInputMask=./outfile/show.flt2.seg --sSegMaxLen=2000 --sSegMaxLenModel=2000 --sOutputMask=./outfile/show.spl.seg --fInputMask=/vagrant/test2.wav 1 0 1000000000 U U U 1 --fInputDesc=audio2sphinx,1:3:2:0:0:0,13,0:0:0 --tInputMask=models/s.gmms show
07:12.300 ClusterSet     INFO  | --> write ClusterSet : ./outfile/show.spl.seg / show	{write() / 10}
07:12.480                CONFIG| cmdLine: --sGender --sByCluster --fInputDesc=audio2sphinx,1:3:2:0:0:0,13,1:1:0 --fInputMask=/vagrant/test2.wav 1 0 1000000000 U U U 1 --sInputMask=./outfile/show.spl.seg --sOutputMask=./outfile/show.g.seg --tInputMask=models/gender.gmms show
07:12.553 MScore         INFO  | Compute Score	{make() / 10}
07:12.554 MScore         FINER | GMM size:4	{make() / 10}
07:12.910 MScore         FINER | clustername = S0 name=MS =-Infinity	{make() / 10}
07:12.911 MScore         FINER | clustername = S0 name=MT =-Infinity	{make() / 10}
07:12.912 MScore         FINER | clustername = S0 name=FS =-Infinity	{make() / 10}
07:12.913 MScore         FINER | clustername = S0 name=FT =-Infinity	{make() / 10}
07:12.913 ClusterSet     INFO  | --> write ClusterSet : ./outfile/show.g.seg / show	{write() / 10}
07:12.112                CONFIG| cmdLine: --fInputMask=/vagrant/test2.wav 1 0 1000000000 U U U 1 --fInputDesc=audio2sphinx,1:3:2:0:0:0,13,1:1:300:4 --sInputMask=./outfile/show.g.seg --sOutputMask=./outfile/show.seg --cMethod=ce --cThr=1.7 --tInputMask=models/ubm.gmm --emCtrl=1,5,0.01 --sTop=5,models/ubm.gmm --tOutputMask=./outfile/show.c.gmm show
07:12.174 MClust         INFO  | Clustering: ce	{make() / 10}
07:12.177 MClust         INFO  | BEGIN CLUSTERING date: Tue Oct 31 19:12:35 UTC 2017 time in ms:1509477155174	{make() / 10}
07:12.034 GMMFactory     FINER | i=0 llh=-32.88580767116764 Cluster name=S0 cluster length=1381	{getMAP() / 10}
07:12.192 GMMFactory     FINER | i=1 llh=-31.911115935530056 gain=0.9746917356375846 Cluster name=S0 cluster length=1381	{getMAP() / 10}
07:12.318 GMMFactory     FINER | i=2 llh=-31.610593795965368 gain=0.30052213956468776 Cluster name=S0 cluster length=1381	{getMAP() / 10}
07:12.444 GMMFactory     FINER | i=3 llh=-31.470742971962924 gain=0.13985082400244409 Cluster name=S0 cluster length=1381	{getMAP() / 10}
07:12.567 GMMFactory     FINER | i=4 llh=-31.390051404841582 gain=0.08069156712134173 Cluster name=S0 cluster length=1381	{getMAP() / 10}
07:12.570 GMMFactory     FINER | 	{getMAP() / 10}
07:12.597 ClusterSet     INFO  | --> write ClusterSet : ./outfile/show.seg / show	{write() / 10}
```

Many output files are produced, some are various stages of processing. The 'final' output is named `show.seg` but for speech transcription purposes, the file `show.s.seg` is often more useful; the largest number of smallest segments, for example:

```
vagrant@vagrant-ubuntu-trusty-64:~/LIUM$ cat outfile/show.s.seg
;; cluster S0 
/vagrant/test2.wav 1 9 637 U U U S0
;; cluster S1 
/vagrant/test2.wav 1 646 288 U U U S1
;; cluster S2 
/vagrant/test2.wav 1 934 500 U U U S2
```

(Note that each utterance gets a new speaker ID, e.g. S0, S1, S2) To limit the number of speakers, it should be possible to specify a parameter in the very last stage of the script.
The last step of the diarization script:
```
# NCLR clustering                                                                                                                          
# Features contain static and delta and are centered and reduced (--fInputDesc)                                                            
c=1.7
spkseg=./$datadir/$show.c.seg
$java -Xmx1024m -classpath "$LOCALCLASSPATH" fr.lium.spkDiarization.programs.MClust --help $trace \
 --fInputMask=$features --fInputDesc=$fInputDescCLR --sInputMask=$gseg \
--sOutputMask=./$datadir/show.seg --cMethod=ce --cThr=$c --tInputMask=$ubm \
--emCtrl=1,5,0.01 --sTop=5,$ubm --tOutputMask=./$datadir/$show.c.gmm $show
```

The [documentation about restricting number of speakers](http://www-lium.univ-lemans.fr/diarization/doku.php/howto#how_to_restrict_the_number_of_speakers_to_detect):

I think they meant to say add the option `--cMinimumOfCluster=2` in the last clustering,
which would be the MClust program that does NCLR clustering.  The IDs of speakers may look confusing, they are not consecutive, but just based on clustering removing lots of the IDs and only the remaining "so-many".
