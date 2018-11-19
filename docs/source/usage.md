# Use instructions

## Overview

This is an overview of the full tool presentation found in the next stage, recapping the main steps:

1. Put your data in /data/
2. Do `$ vagrant up` to "wake the machine up"
3. Choose between: running a speech activity detection system followed by a diarization system (steps 3 and 4 below), or a tool that directly segments recordings into 3 main roles, namely child, male adult, female adult (step 5 below)
4. If you have some annotations, you can evaluate how the tools did (step 6 below)
5. Finally, remember to put the machine back to sleep with `$ vagrant halt`

Next we provide instructions for all tools. More detailed information about each tool can be found in separate readme's.

## Short instructions for all tools

1. Put sound files (and annotations, if you have any) inside the "data" folder inside the DiViMe folder. If your files aren't .wav some of the tools may not work. Please consider converting them into wav with some other program, such as [ffmpeg](https://www.ffmpeg.org/). It is probably safer to make a copy (rather than moving your files into the data folder), in case you later decide to delete the whole folder. 

 If you have any annotations, put them also in the same "data" folder. Annotations can be in .eaf, .textgrid, or .rttm format, and *they should be named exactly as your wav files*. It is probably safer to make a copy (rather than moving them), in case you later decide to delete the whole vagrant folder. 

2. Launch the virtual machine anytime by navigating to your DiViMe folder on your terminal and performing:

`$ vagrant up`

3. For the SAD tools, type a command like this one:

`$ vagrant ssh -c "launcher/noisemesSad.sh data/"`


This will create a set of new rttm files, with the name of the tool added at the beginning. For example, imagine you have a file called participant23.wav, and you decide to run two SADs:


```
$ vagrant ssh -c "launcher/opensmileSad.sh data/"
$ vagrant ssh -c "launcher/noisemesSad.sh data/"
```

This will result in your having the following three files in your /data/ folder:

- participant23.wav
- opensmileSad_participant23.rttm
- noisemesSad_participant23.rttm

If you look inside one of these .rttm's, say the opensmileSad one, it will look as follows:

```
SPEAKER	participant23	1	0.00	0.77	<NA>	<NA>	speech	<NA>
SPEAKER	participant23	1	1.38	2.14	<NA>	<NA>	speech	<NA>
```

This means that opensmileSad considered that the first 770 milliseconds of the audio were speech; followed by 610 milliseconds of non-speech, followed by 2.14 seconds of speech; etc.

4. There is one **pure diarization** tool: diartk. Here is the command to run, for the data/ input folder:

`$ vagrant ssh -c "launcher/diartk.sh  data/ noisemesSad"`  

Pure diarization tools only perform talker diarization (i.e., *who* speaks) but not speech activity detection (*when* is someone speaking). Therefore, this system requires some form of SAD. The third parameter ('noisemes') tells the system which SAD annotation to use, from among the list:

- ldcSad: this means you want the system to use the output of the LDC_SAD system. If you have not run LDC_SAD, the system will run it for you.
- noisemesSad: this means you want the system to use the output of the noisemesSad system. If you have not run LDC_SAD, the system will run it for you.
- opensmileSad: this means you want the system to use the output of the opensmile system. If you have not run opensmile, the system will run it for you.
- tocomboSad: this means you want the system to use the output of the tocomboSad system. If you have not ran tocombosad, the system will run it for you.
- textgrid: this means you want the system to use your textgrid annotations. Notice that all tiers count, so if you have some tiers that are non-speech, you should remove them from your textgrids before you start. Please note that the system will convert your textgrids into .rttm in the process.
- eaf: this means you want the system to use your eaf annotations. Notice that all tiers count, so if you have some tiers that are non-speech, you should remove them from your eaf files before you start. Please note that the system will convert your eafs into .rttm in the process.
- rttm: this means you want the system to use your rttm annotations. Notice that all annotations that say "speech" in the eigth column count as such. 

Finally, if no parameter is provided, the system will give an error.

5. There is one **role assignment** tool, which classifies spoken turns into three roles: children, female adults, male adults. It exists in two versions. 

The version we call "yunitator" takes the raw recording as input. To call this one, do

`$ vagrant ssh -c "launcher/yunitator.sh data/"`


The version we call "yuniSeg" takes the raw recording as well as a SAD as input. To call this one, do

`$ vagrant ssh -c "launcher/yuniSeg.sh data/ noisemesSad"`

Both of them return one rttm per sound file, with an estimation of where there are vocalizations by children, female adults, and male adults.

For more information on the model underlying them, see the Yunitator section below.

6. If you have some annotations that you have made, you probably want to know how well our tools did - how close they were to your hard-earned human annotations. To find out, type a command like the one below:

`$ vagrant ssh -c "launcher/eval.sh data/ noisemesSad"`

Notice there are 2 parameters provided to the evaluation suite. The first parameter tells the system which folder to analyze (in this case, the whole data/ folder). The second parameter indicates which tool's output to evaluate (in this case, noisemesSad). The system will use the .rttm annotations if they exist; or the .eaf ones if the former are missing; or the .textgrid of neither .rttm nor .eaf are found. 
If you want to evaluate a diarization produced by the diartk tool, you will have to specify a third parameter, to tell the system which SAD was used to compute the diartk outputs you want to evaluate. E.G. :
`$ vagrant ssh -c "launcher/eval.sh data/ diartk noisemesSad`

7. Last but not least, you should **remember to halt the virtual machine**. If you don't, it will continue running in the background, taking up useful resources! To do so, simply navigate to the DiViMe folder on your terminal and type in:

`$ vagrant halt`





