This virtual machine (intended to be installed with Vagrant) contains a collection of tools (some currently under development) used by the diarization team at JSalt 2017. Please feel free to submit pull requests, especially documentation and examples, should you learn more about how to use these. This is meant to be a place where collaboration can occur to improve and share the state of the art of diarization tools.

# OpenSAT
Diarization using noisemes

To run, first install the VM following the pattern of the one at http://github.com/srvk/eesen-transcriber

After `vagrant up` completes, quickstart test: `vagrant ssh -c "OpenSAT/runOpenSAT.sh /vagrant/test.wav"`
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

# DiarTK

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

    extractFeatures.py: This script extracts the features for a dataset. You can use this to extract features from 159 or daylong.
    parseCha.py: It converts files to a cha format. Cha format is something that psicologist uses to anotate recordings (@Charles any thoughts about this?)
    wrap_*:  Each wrap_* scripts goes with a config_*. They form the different steps of the pipeline.
        a: Tunning the speech not speech. Lower threshold and upper threshold. Train a SVM. Takes the top 5 % of the energy and trains a classifier.
        b: Given the train model from a, it generate speech non speech test label. The labels are in STM format (audacity file).
        c: Now that we have the labels, we can define how many classes and train our classifier. 
        d: It allows you to test your model with any dataset (159, long day recordings).
        e: Given ground truth labels and your hypothesis you can score your model.
        f: Runs test and score multiple times
        wrap-*-subpr.py: Those scripts are used just to parallelize each step so you can test/score different implementations in parallel.
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
