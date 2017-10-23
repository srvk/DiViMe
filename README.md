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

# Interslice (part of Festvox)

See [Festvox Documentation](http://www.festvox.org)  
Tools are installed in `~/festvox/src/interslice`



