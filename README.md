This repo contains the development version of the ACLEW Diarization Virtual Machine (DiViMe). 

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

 * [LDC Speech Activity Detection](https://github.com/aclew/DiViMe#ldc_sad)
 * [Speech Activity Detection Using Noisemes](https://github.com/aclew/DiViMe#noisemes_sad)
 * [OpenSmile SAD]()
 * [ToCombo SAD]()


2) Talker diarization (answers the question: who is talking?)

 * [DiarTK](https://github.com/aclew/DiViMe#diartk)

3) Evaluation

If a user has some annotations, they may want to know how good the ACLEW DiViMe parsed their audio recordings. In that case, you can use one tool we provide to evaluate:

 * [LDC Diarization Scoring](https://github.com/aclew/DiViMe#ldc-diarization-scoring)


# Installation instructions

Try the following first:

1. Install [Vagrant](https://www.vagrantup.com/): Click on the download link and follow the prompted instructions

1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads): When we last checked, the links for download for all operating systems were under the header "VirtualBox 5.2.8 platform packages", so look for a title like that one.

2. Clone this repo:

    - Open terminal
    - Navigate to the directory in which you want the VM to be hosted
    - type in:

`$ git clone https://github.com/aclew/DiViMe`

3. Change into it by 

`$ cd divime`

2. Install HTK

HTK is used by some of these tools (until we find and implement an open-source replacement). We are not allowed to distribute HTK, so unfortunately you have to get it yourself. 

- Go to the HTK download page http://htk.eng.cam.ac.uk/download.shtml
- Register by following the instructions on the left (under "Getting HTK": Register)
- Check that you have received your password via email; you will need it for the next step. 
- Find the link that reads "HTK source code" under your system (if you have a mac, it will be under "Linux/unix downloads"). Notice that you will need your username and password (from the previous step). The download is probably called HTK-3.4.1.tar.gz, although the numbers may change if they update their code. 
- Move the HTK-*.tar.gz file into the root folder of this repository (alongside Vagrantfile), and rename it HTK.tar.gz

4. Type 

`$ vagrant up`

The first time you do this, it will take at least 20 minutes to install all the packages that are needed to build the virtual machine.

The instructions above make the simplest assumptions as to your environment. If you have Amazon Web Services, an ubuntu system, or you do not have admin rights in your computer, you might need to read the [instructions to the eesen-transcriber](https://github.com/srvk/eesen-transcriber/blob/master/INSTALL.md) for fancier options.  Or you can just open an issue [here](https://github.com/aclew/DiViMe/issues), describing your situation.

Advanced topic: [Installing With Docker](https://github.com/srvk/DiViMe/wiki/InstallingWithDocker)

# Checking your installation

The very first time you use DiViMe, it is a good idea to run a quickstart test:

1. Open a terminal
2. Navigate inside the DiViMe folder
3. Do 
`$ vagrant up`
4. Do
`$ vagrant ssh -c "tools/test.sh"`

This should produce the output:

```
Testing noisemes...
Noisemes passed the test.
Testing DIARTK...
DiarTK passed the test.
Congratulations, everything is OK!
Connection to 127.0.0.1 closed.
```

If something fails, please open an issue [here](https://github.com/aclew/DiViMe/issues). Please paste the complete output there.


# Update instructions

If there is a new version of DiViMe, you'll need to perform the following 3 steps from within the DiViME folder on your terminal:


```
$ vagrant destroy
$ git pull
$ vagrant up
```

# Uninstallation instructions

If you want to get rid of the files completely, you should perform the following 3 steps from within the DiViME folder on your terminal:

```
$ vagrant destroy
$ cd ..
$ rm -r -f divime
```





# Use instructions


## Short instructions for all tools

1. Put the files you want to analyze inside the "data" folder inside the DiViMe folder. If your files aren't .wav some of the tools may not work. Please consider converting them into wav with some other program, such as [ffmpeg](https://www.ffmpeg.org/). It is probably safer to make a copy (rather than moving your files into the data folder), in case you later decide to delete the whole folder. 

2. If you have any annotations, put them also in the same "data" folder. Annotations can be in .eaf, .textgrid, or .rttm format, and *they should be named exactly as your wav files*. It is probably safer to make a copy (rather than moving them), in case you later decide to delete the whole vagrant folder. 

[//]: # (Julien, you had a solution for not moving data at all -- can you please describe it in simple terms?)

3. Launch the virtual machine anytime by navigating to your DiViMe folder on your terminal and performing:

`$ vagrant up`

4. For the SAD tools, type a command like the one below, being careful to type the SAD tool name instead of SADTOOLNAME:

`$ vagrant ssh -c "tools/SADTOOLNAME.sh data/"`

The SAD options are:
- SADTOOLNAME = ldc_sad (coming soon)
- SADTOOLNAME = noisemes_sad
- SADTOOLNAME = noisemes_full
- SADTOOLNAME = opensmile_sad
- SADTOOLNAME = tocombo_sad

This will create a set of new rttm files, with the name of the tool added at the beginning. For example, imagine you have a file called participant23.wav, and you decide to run both the LDC_SAD and the Noisemes analyses. You will run the following commands:


```
$ vagrant ssh -c "tools/ldc_sad.sh data/"
$ vagrant ssh -c "tools/noisemes_sad.sh data/"
```

And this will result in your having the following three files in your /data/ folder:

- participant23.wav
- ldc_sad_participant23.rttm
- noisemes_sad_participant23.rttm

If you look inside one of these .rttm's, say the ldc_sad one, it will look as follows:

```
SPEAKER	participant23	1	0.00	0.77	<NA>	<NA>	speech	<NA>
SPEAKER	participant23	1	0.77	0.61	<NA>	<NA>	nonspeech	<NA>
SPEAKER	participant23	1	1.38	2.14	<NA>	<NA>	speech	<NA>
SPEAKER	participant23	1	3.52	0.82	<NA>	<NA>	nonspeech	<NA>
```

This means that LDC_SAD considered that the first 770 milliseconds of the audio were speech; followed by 610 milliseconds of non-speech, followed by 2.14 seconds of speech; etc.


5. For the diarization tools, type a command like the one below, being careful to type the diarization tool name instead of DiarTOOLNAME:

`$ vagrant ssh -c "tools/DiarTOOLNAME.sh data/ noisemes"`

The DiarTOOLNAME options are:
- DiarTOOLNAME = diartk
- DiarTOOLNAME = yunitate

Notice there is one more parameter provided to the system in the call; in the example above "noisemes". This is because the DiarTK tool only does talker diarization (i.e., who speaks) but not speech activity detection (when is someone speaking). Therefore, this system requires some form of SAD. With this last parameter, you are telling the system which annotation to use. At present, you can choose between:

- ldc_sad: this means you want the system to use the output of the LDC_SAD system. If you have not run LDC_SAD, the system will run it for you.
- noisemes: this means you want the system to use the output of the noisemes system. If you have not run LDC_SAD, the system will run it for you.
- opensmile: this means you want the system to use the output of the opensmile system. If you have not run opensmile, the system will run it for you.
- tocombosad: this means you want the system to use the output of the tocombo_sad system. If you have not ran tocombosad, the system will run it for you.
- textgrid: this means you want the system to use your textgrid annotations. Notice that all tiers count, so if you have some tiers that are non-speech, you should remove them from your textgrids before you start. Please note that the system will convert your textgrids into .rttm in the process.
- eaf: this means you want the system to use your eaf annotations. Notice that all tiers count, so if you have some tiers that are non-speech, you should remove them from your eaf files before you start. Please note that the system will convert your eafs into .rttm in the process.
- rttm: this means you want the system to use your rttm annotations. Notice that all annotations that say "speech" in the eigth column count as such. 


Finally, if no parameter is provided, the system will default to ldc_sad.

6. If you have some annotations that you have made, you probably want to know how well our tools did - how close they were to your hard-earned human annotations. To find out, type a command like the one below:

`$ vagrant ssh -c "tools/eval.sh data/ noisemes"`

Notice there are 2 parameters provided to the evaluation suite. The first parameter tells the system which folder to analyze (in this case, the whole data/ folder). The second parameter indicates which tool's output to evaluate (in this case, noisemes). The system will use the .rttm annotations if they exist; or the .eaf ones if the former are missing; or the .textgrid of neither .rttm nor .eaf are found. 
If you want to evaluate a diarization produced by the diartk tool, you will have to specify a third parameter, to tell the system which SAD was used to compute the diartk outputs you want to evaluate. E.G. :
`$ vagrant ssh -c "tools/eval.sh data/ diartk noisemes_sad`

7. Last but not least, you should **remember to halt the virtual machine**. If you don't, it will continue running in the background, taking up useful resources! To do so, simply navigate to the DiViMe folder on your terminal and type in:

`$ vagrant halt`

## More details for each tool 

### LDC_SAD

Instructions coming.


### Noisemes_sad

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

To learn more, read the source file
Wang, Y., Neves, L., & Metze, F. (2016, March). Audio-based multimedia event detection using deep recurrent neural networks. In Acoustics, Speech and Signal Processing (ICASSP), 2016 IEEE International Conference on (pp. 2742-2746). IEEE. [pdf](http://www.cs.cmu.edu/~yunwang/papers/icassp16.pdf)

#### Instructions for direct use

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

### Some more technical details

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

### DiarTK

This tool performs diarization, requiring as input not only .wav audio, but also speech/nonspeech in .rttm format as generated by one of the tools above. A script to run DiarTK (also known as ib_diarization_toolkit) can be found in `tools/diartk.sh`. Here is it's usage:
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

### LDC Diarization Scoring

Instructions coming

https://github.com/aclew/varia

# Troubleshooting

## Installation issues
### Virtual Machine creation
If your computer freezes after `vagrant up`, it may be due to several things. 
If your OS is ubuntu 16.04, there's a known incompatibility between VirtualBox and the 4.13 Linux kernel on ubuntu 16.04. What you may do is to install a previous version of the kernel, for example the 4.10, following [these instructions](https://doc.ubuntu-fr.org/kernel#installation_simple), or install the latest version of virtualbox which should fix the problem.
If you are not on ubuntu 16.04, or if the previous fix didn't work, it may also be due to the fact that Vagrant is trying to create a Virtual Machine that asks for too much resources. Please ensure that you have enough space on your computer (you should have at least 15Gb of free space) and check that the memory asked for is okay. If not, you can lower the memory of the VM by changing line 25 of the VagrantFile,
```
vbox.memory = 3072
```
to a lower number, such as
```
vbox.memory = 2048
```
### Resuming the Virtual Machine
If you already used the VM once, shut down your computer, turned it back on and can't seem to be able to do `vagrant up` again, you can simply do
```
vagrant destroy
```
and recreate the VM using
```
vagrant up
```
If you don't want to destroy it, you can try opening the VirtualBox GUI, go to `File -> Settings or Preferences -> Network `, click on the `Host-only Networks` tab, then click the network card icon with the green plus sign in the right, if there are no networks yet listed. The resulting new default network should appear with the name ‘vboxnet0’.
You can now try again with `vagrant up`
### Tools
If ldc_sad doesn't seem to work after vagrant up, first, please check that you indeed have the htk archive in your folder. If you don't, please put it there and launch:
```
vagrant up --provision
```
This step will install HTK inside the VM, which is used by several tools including ldc_sad.
## Problems with some of the Tools
### Noisemes
If you use the noisemes_sad or the noisemes_full tool, one problem you may encounter is that it doesn't treat all of your files and gives you an error that looks like this:
```
Traceback (most recent call last):
  File "SSSF/code/predict/1-confidence-vm5.py", line 59, in <module>
    feature = pca(readHtk(os.path.join(INPUT_DIR, filename))).astype('float32')
  File "/home/vagrant/G/coconut/fileutils/htk.py", line 16, in readHtk
    data = struct.unpack(">%df" % (nSamples * sampSize / 4), f.read(nSamples * sampSize))
MemoryError
```
If this happens to you, it's because you are trying to treat more data than the system/your computer can handle.
What you can do is simply put the remaining files that weren't treated in a seperate folder and treat this folder seperately (and do this until all of your files are treated if it happens again on very big datasets).
After that, you can put back all of your data in the same folder.
## Input Format For Transcriptions
If your transcriptions are in TextGrid format but the conversion doesn't seem to work, it's probably because it isn't in the right TextGrid format. 
The input TextGrid the system allows is a TextGrid in which all the tiers have speech segments (so remove tiers with no speech segments) and all the annotated segments for each tiers is indeed speech (so remove segments that are noises or other non-speech type). 
