# Using DiViMe

## Overview

This is an overview of the full tool presentation found in the next stage, recapping the main steps:

1. Put your data in the ```data``` shared directory.
2. Do `$ vagrant up` to "wake the machine up"


Next we provide instructions for all tools. More detailed information about each tool can be found in separate readme's.

Assuming the installation of the virtual machine is complete and some of the tests have passed, you can now use at least some of the tools in the virtual machine. We explain more about each step below, but in a nutshell, the steps to use DiViMe are always the same:

1. Put the data you want to process in the ```data/``` directory (or any subdirectory within ```data/```)
2. Go to the DiViMe folder 
3. Do `$ vagrant up` to "wake the machine up"
4. Use tools on data, typically by doing `vagrant ssh -c "script.sh [arguments]"`. You can also run a recipe. 
5. Finally, remember to put DiViMe back to sleep with `$ vagrant halt`


## Further information on Step 1, putting your data into the ```data/``` directory

Put the sound files that you want analyzed (and annotations, if you have any) inside the shared ```data``` folder. It is probably safer to make a copy of your files (rather than moving them), in case you later decide to delete the whole folder. 

You can drop a whole folder into ```data```. You will provide the path to the specific folder to be analyzed when running the tools (as per instructions below). All `.wav` files in that folder will be analyzed. 

If your files aren't .wav some of the tools may not work. Please consider converting them into wav with some other program, such as [ffmpeg](https://www.ffmpeg.org/). It is probably safer to make a copy (rather than moving your files into the data folder), in case you later decide to delete the whole folder. 

If you have any annotations, put them also in the same "data" folder. Annotations can be in .eaf, .textgrid, or .rttm format, and *they should be named exactly as your wav files*. For more information on these formats, see the Format section. 

IMPORTANT: If you already analyzed a file with a given tool, re-running the tool will result in the previous analysis being overwritten.

## Further information on Step 2, going to the DiViMe folder

To interact with the virtual machine, you must use a terminal. If you don't know what this means, we recommend that you first follow the [Software Carpentry Shell Tutorial](https://swcarpentry.github.io/shell-novice/) (up to 00:45, namely "Introducing the shell", and "Navigating files and directories"). 

Next, navigate in the terminal window to the DiViMe directory that was created when you did `git clone https://github.com/srvk/DiViMe` when installing DiViMe.


## Further information on Step 3, Waking the machine up

Remember that you will be using a mini-computer within your computer. Typically, the machine will be down - i.e., it will not be running. This is good, because when it is running, it will use memory and other resources from your computer (which we call "the host", because it is hosting the other computer). With this step, you launch the virtual machine:

`$ vagrant up`

## Further information on Step 4, Using tools on data

### Overview of tools

If all tools passed the test, then you'll be able to automatically add the following types of annotation to your audio files:

1) Speech activity detection (_when is someone talking?_): The tools available for this task are the following: noisemesSad, tocomboSad, opensmileSad, ldcSad

2) Talker diarization (_who is talking?_) The tools available for this task are the following: diartkDiar

3) Role diarization (_what kind of person is talking?_) The tools available for this task are the following: yunitator

4) Vocal type classification (_what kind of vocalization is this one?_) The tools available for this task are the following: vcm

5) Evaluation (_how good is the automatic annotation?_) There is an evaluation available for the following tools: noisemesSad, tocomboSad, opensmileSad, ldcSad, diartkDiar, yunitator

### Overview of "pipelines"

DiViMe is a platform for tools to analyze naturalistic, unannotated audiorecordings. We consider this process to involve three kinds of processes: 

- speech activity detection and voice activity detection = “detecting vocalizations”, 
- diarization = “deciding to whom the vocalizations belong”, and 
- “additional annotations”


Some tools actually combine two of these stages (e.g. a tool may do both speech activity detection and role attribution in one fell swoop). This [flowchart](https://docs.google.com/presentation/d/1vh2rTFdVZDZKh4WQ-UEzzPvHpr4-k-Q6Lf-5fvotRXw/edit#slide=id.g44f4e7b6a3_0_9) may help. 

We call a *pipeline* a sequence of those processes; i.e., it involves using one tool after another. For example, you may do *speech activity detection* + *talker diarization* + *vocal type classification*

Starting from an audio file with no annotation, typically, you may want to run a *speech activity detection* tool followed by a *talker diarization* tool; then you will end up with an annotation showing who spoke when. However, you may not know who "talker0" and "talker1" are. (You could decide this by listening to some samples of each, and mapping them to different roles. However, we do not provide tools to do this.)

Alternatively, we provide a *role diarization* tool that directly segments recordings into 3 main roles, namely child, male adult, female adult; and these separated from silence.

In both cases, you may want to classify each vocalizations into different types with the *vocal type classification* tool.

### How to run a Speech or Voice activity detection tool

For these tools, type a command like this one:

`$ vagrant ssh -c "noisemesSad.sh data/mydata/"`

You can read that command as follows:

*vagrant ssh -c*: This tells DiViMe that it needs to run a tool.

*noisemesSad.sh*: This first argument tells DiViMe which tool to run. The options are: noisemesSad.sh, tocomboSad.sh, opensmileSad.sh, ldcSad.sh

*data/mydata/*: This second argument tells DiViMe where are the sound files to analyze. Note that the directory containing the input files should be located in the ```data/``` directory (or it can be ```data/``` itself). The directory does not need to be called `mydata` - you can choose any name.


For each input wav file, there will be one rttm file created in the same directory, with the name of the tool added at the beginning. For example, imagine you have put a single file called participant23.wav into ```data/```, and you decided to run two SADs:


```
$ vagrant ssh -c "opensmileSad.sh data/"
$ vagrant ssh -c "noisemesSad.sh data/"
```

This will result in your having the following three files in your ```data/``` folder:

- participant23.wav
- opensmileSad_participant23.rttm
- noisemesSad_participant23.rttm

If you look inside one of these .rttm's, say the opensmileSad one, it will look as follows:

```
SPEAKER	participant23	1	0.00	0.77	<NA>	<NA>	speech	<NA>
SPEAKER	participant23	1	1.38	2.14	<NA>	<NA>	speech	<NA>
```

This means that opensmileSad considered that the first 770 milliseconds of the audio were speech; followed by 610 milliseconds of non-speech, followed by 2.14 seconds of speech; etc.

### How to run a Talker diarization tool

For these tools, type a command like this one:

`$ vagrant ssh -c "diartk.sh data/mydata/ noisemesSad"`

You can read that command as follows:

*vagrant ssh -c*: This tells DiViMe that it needs to run a tool.

*diartk.sh*: This first argument tells DiViMe which tool to run. The options are: diartk.sh.

*data/mydata/*: This second argument tells DiViMe where are the sound files to analyze. Note that the directory containing the input files should be located in the ```data/``` directory (or it can be ```data/``` itself). The directory does not need to be called `mydata` - you can choose any name.

*noisemesSad*: Remember that this tool does "talker diarization": Given some speech, attribute it to a speaker. Therefore, this type of tool necessitates speech/voice activity detection. This third argument tells DiViMe what file contains information about which sections of the sound file contain speech. 

You can only use one of the following options: textgrid, eaf, rttm, ldcSad, opensmileSad, tocomboSad, noisemesSad. We explain each of these options next.

You can provide annotations done by a human or in some other way, and encoded as one of the following three file types:

- textgrid: this means you want the system to use your textgrid annotations. Notice that all tiers count, so if you have some tiers that are non-speech, you should remove them from your textgrids before you start. Please note that the system will convert your textgrids into .rttm in the process.
- eaf: this means you want the system to use your eaf annotations. Notice that we only know how to properly process .eaf files that follow the [ACLEW Annotation Scheme](https://osf.io/b2jep/wiki/home/). Please note that the system will convert your eafs into .rttm in the process.
- rttm: this means you want the system to use your rttm annotations. Notice that all annotations that say "speech" in the eight column count as such. 


Alternatively, you can provide use automatic annotations generated by DiViMe's speech/voice activity detection systems, encoded in rttm files. In this case, you would pass one of the following options:

- ldcSad: this means you want the system to use the output of the ldcSad system. If you have not run this system before, the system will fail.
- this system before: this means you want the system to use the output of the noisemesSad system. If you have not run noisemesSad, the system will fail.
- opensmileSad: this means you want the system to use the output of the opensmile system. If you have not run this system before, the system will fail.
- tocomboSad: this means you want the system to use the output of the tocomboSad system. If you have not ran this system before, the system will fail.

If the third parameter is not provided, the system will give an error.

If all three parameters are provided, then the system will first find all the annotation files matching the third parameter (e.g., all the files *.TextGrid; or all the tocomboSad_*.rttm files), and then find the corresponding sound files. For example, imagine you have put into your ```data/mydata/``` folder the following files:

- participant23.wav
- opensmileSad_participant23.rttm
- participant24.wav
- participant24.TextGrid


If you run:

`$ vagrant ssh -c "diartk.sh data/mydata/ opensmileSad"`

then only participant23.wav will be analyzed.


If you run:

`$ vagrant ssh -c "diartk.sh data/mydata/ textgrid"`

then only participant24.wav will be analyzed.

At the end of the process, there will be an added rttm file for each analyzed file. For instance, if you have just one sound file (participant23.wav) at the beginning and you run opensmileSad followed by diartk,  then you will end up with the following three files:

- participant23.wav: your original sound file
- opensmileSad_participant23.rttm: the output of opensmileSad, which states where there is speech
- diartk_opensmileSad_participant23.rttm: the output of opensmileSad followed by diartk, which states which speech sections belong to which speakers.

If you look inside a diartk_*.rttm file, it will look as follows:

```
SPEAKER file17  1       4.2     0.4  <NA>   talker0	<NA>
SPEAKER file17  1       4.6     1.2  <NA>   talker0	<NA>
SPEAKER file17  1       5.8     1.1  <NA>   talker1	<NA> 
SPEAKER file17  1       6.9     1.2  <NA>   talker0	<NA>
SPEAKER file17  1       8.1     0.7  <NA>   talker1	<NA>  
```

This means that diartk considered that one talker spoke starting at 4.2 seconds for .4 seconds; starting at 4.6 for 1.2 seconds; then someone else spoke starting at 5.8 seconds and for 1.1 seconds; etc.

### How to run a Role assignment tool

For these tools, type a command like this one:

`$ vagrant ssh -c "yunitator.sh data/mydata/"`

You can read that command as follows:

*vagrant ssh -c*: This tells DiViMe that it needs to run a tool.

*yunitator.sh*: This first argument tells DiViMe which tool to run. The options are: yunitator.

*data/mydata/*: This second argument tells DiViMe where are the sound files to analyze. Note that the directory containing the input files should be located in the ```data/``` directory (or it can be ```data/``` itself). The directory does not need to be called `mydata` - you can choose any name.

It returns one rttm per sound file, with an estimation of where there are vocalizations by children, female adults, and male adults.

### How to run a Vocalization classification tool

NO INFORMATION YET

### How to run an Evaluation

If you have some annotations that you have made, you probably want to know how well our tools did - how close they were to your hard-earned human annotations. 

#### Evaluating Speech/Voice activity detection

Type a command like the one below:

`$ vagrant ssh -c "evalSAD.sh data/ noisemesSad"`

You can read that command as follows:

*vagrant ssh -c*: This tells DiViMe that it needs to run a tool.

*evalSAD.sh*: This first argument tells DiViMe which tool to run. The options are: evalSAD.sh.

*data/mydata/*: This second argument tells DiViMe where are the sound files to analyze. Note that the directory containing the input files should be located in the ```data/``` directory (or it can be ```data/``` itself). The directory does not need to be called `mydata` - you can choose any name.

*noisemesSad*: The third argument indicates which tool's output to evaluate (in this case, noisemesSad). All of our Speech/Voice activity detection tools can be evaluated with this.

For the evaluation process, YOU MUST PROVIDE files that have the coding by humans. For each sound file that has been analyzed with that tool (e.g., in the example, for each file called noisemesSad*.rttm), the system will generate the name of the sound file (by removing "noisemesSad" and ".rttm". Then it will look for .rttm annotations; for instance, in our running example, it will look for a file called participant23.rttm. If this does not exist, it will look for .eaf files (i.e., participant23.eaf). Finally, if those don't exist, it will check for .textgrid ones (i.e., participant23.TextGrid).

#### Evaluating Speech/Voice activity detection

Type a command like the one below:

`$ vagrant ssh -c "evalDiar.sh data/ diartk_noisemesSad"`

You can read that command as follows:

*vagrant ssh -c*: This tells DiViMe that it needs to run a tool.

*evalSAD.sh*: This first argument tells DiViMe which tool to run. The options are: evalSAD.sh.

*data/mydata/*: This second argument tells DiViMe where are the sound files to analyze. Note that the directory containing the input files should be located in the ```data/``` directory (or it can be ```data/``` itself). The directory does not need to be called `mydata` - you can choose any name.

* diartk_noisemesSad*: The third argument indicates which output to evaluate. 

**THIS NEEDS WORK**

For the evaluation process, YOU MUST PROVIDE files that have the coding by humans. For each sound file that has been analyzed with that tool (e.g., in the example, for each file called noisemesSad*.rttm), the system will generate the name of the sound file (by removing "noisemesSad" and ".rttm". Then it will look for .rttm annotations; for instance, in our running example, it will look for a file called participant23.rttm. If this does not exist, it will look for .eaf files (i.e., participant23.eaf). Finally, if those don't exist, it will check for .textgrid ones (i.e., participant23.TextGrid).



## Further information on Step 5, putting DiViMe back to sleep

Last but not least, you should **remember to halt the virtual machine**. If you don't, it will continue running in the background, taking up useful resources! To do so, simply navigate to the DiViMe folder on your terminal and type in:

`$ vagrant halt`





