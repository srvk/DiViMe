This repo contains the clean, user-friendly version of the ACLEW Diarization Virtual Machine (DiViMe). You can find the development version [here](https://github.com/srvk/DiarizationVM). 

# Initial questions

## What is the ACLEW DiViMe?

It is a collection of diarization tools, i.e., it allows users to add annotations onto a raw audio recording. At present, we have tools to do the following types of annotation:

1) Speech activity detection (answers the question: when is someone talking?)

2) Talker diarization (answers the question: who is talking?)

We are hoping to add more tools in the future, including register detection, syllable quantification, and vocal maturity estimation.

## Who is the ACLEW DiViMe for?

Our target users have "difficult" recordings, e.g. recorded in natural environment, from sensitive populations, etc. Therefore, we are assuming users who are unable to share their audio recordings. Our primary test case involves language acquisition in children 0-3 years of age.

We are hoping to make the use of these tools as easy as possible, but some command line programming will be unavoidable. If you are worried when reading this, we can recommend the Software Carpentry programming courses for researchers, and particularly their [unix bash](http://swcarpentry.github.io/shell-novice) and [version control](http://swcarpentry.github.io/git-novice/) bootcamps.

## What exactly is inside the ACLEW DiViMe?

A virtual machine is actually a mini-computer that gets set up inside your computer. This creates a virtual environment within which we can be sure that our tools run, and run in the same way across all computers (Windows, Mac, Linux). 

Inside this mini-computer, we have put the following tools:

1) Speech activity detection (answers the question: when is someone talking?)

 * [Diarization Using Noisemes](https://github.com/srvk/DiarizationVM#diarization-using-noisemes)
 * [LDC Speech Activity Detection](https://github.com/srvk/DiarizationVM#ldc-speech-activity-detection)


2) Talker diarization (answers the question: who is talking?)

 * [DiarTK](https://github.com/srvk/DiarizationVM#diartk-also-known-as-ib-diarization-toolkit)

3) Evaluation

If a user has some annotations, they may want to know how good the ACLEW DiViMe parsed their audio recordings. In that case, you can use one tool we provide to evaluate:

 * [LDC Diarization Scoring](https://github.com/srvk/DiarizationVM#ldc-diarization-scoring)


# Installation instructions

The following instructions make the simplest assumptions as to your environment. If you have Amazon Web Services, an ubuntu system, or you do not have admin rights in your computer, you might need to read the [instructions to the eesen-transcriber](https://github.com/srvk/eesen-transcriber/blob/master/INSTALL.md) for fancier options.  But try the following first:

1. Install [Vagrant](https://www.vagrantup.com/): Click on the download link and follow the prompted instructions

2. Clone this repo:

    - Open terminal
    - Navigate to the directory in which you want the VM to be hosted
    - type in:
$ git clone https://github.com/aclew/DiarizationVM

3. Change into it by 
$ cd DiarizationVM

2. Install HTK
HTK is used by some of these tools (until we find and implement an open-source replacement). We are not allowed to distribute HTK, so unfortunately you have to get it yourself. 

- Go to the HTK download page http://htk.eng.cam.ac.uk/download.shtml
- Register by following the instructions on the left (under "Getting HTK": Register)
- Check that you have received your password via email; you will need it for the next step. 
- Find the link that reads "HTK source code" under your system (if you have a mac, it will be under "Linux/unix downloads"). Notice that you will need your username and password (from the previous step). The download is probably called HTK-3.4.1.tar.gz, although the numbers may change if they update their code. 
- Move the HTK-*.tar.gz file into (in the root folder of this repository (alongside Vagrantfile) and then 'vagrant up' will install it into the VM automatically.

4. Launch the virtual machine by
$ vagrant up

# Use instructions

https://github.com/aclew/varia

## For all tools

Put the files you want to analyze inside the "data" folder inside the DiViMe folder. It is probably safer to make a copy (rather than moving them), in case you later decide to delete the whole vagrant folder. 

[//]: # (Julien, you had a solution for not moving data at all -- can you please describe it in simple terms?)

## LDS SAD

Instructions coming.


## Diarization Using Noisemes

### General intro

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

To learn more, read the source file
Wang, Y., Neves, L., & Metze, F. (2016, March). Audio-based multimedia event detection using deep recurrent neural networks. In Acoustics, Speech and Signal Processing (ICASSP), 2016 IEEE International Conference on (pp. 2742-2746). IEEE. [pdf](http://www.cs.cmu.edu/~yunwang/papers/icassp16.pdf)

### Instructions for use

#### Test (do once only)
The very first time you use this, you probably want to run a quickstart test:

1. Open a terminal
2. Navigate inside the vagrant
3. Do 
$ vagrant up
4. Do
$ vagrant ssh -c "OpenSAT/runOpenSAT.sh /vagrant/test.wav"

This should produce the output:

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

If something fails, please open an issue [here](https://github.com/aclew/DiarizationVM/issues). Please paste the output of the error there.

#### Regular use

You can analyze just one file as follows. Imagine that <$MYFILEP> is the name of the file you want to analyze, which you've put inside the "data" folder in the VM.

$ vagrant ssh -c "OpenSAT/runOpenSAT.sh /vagrant/data/<$MYFILE>"


You can also analyze a group of files as follows:

$ vagrant ssh -c "OpenSAT/runDiarNoisemes.sh /vagrant/data/"

This will analyze all .wav's inside the "data" folder.

Created annotations will be stored inside the same "data" folder.

### Some more technical details

For more fine grained control, you can log into the VM and from a command line, and play around from inside the "Diarization with noisemes" directory, called "OpenSAT":

$ vagrant ssh
$ cd OpenSAT


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

## DiarTK (also known as IB Diarization Toolkit)

Instructions coming.

## LDC evaluation toolkit

Instructions coming.
