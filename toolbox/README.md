## Toolbox ## 
A place to store utility programs. (Not run scripts for proper Tools like DiarTK, Yunitator, OpenSmile, etc. which have their own repository)

### rttm2labels.py ###
This tool accepts on standard input an RTTM file and produces on standard output a text file that can be imported and displayed along
audio waveforms in Audacity. Audacity prefers the label files to have a `.txt` extension, but any filename can work.
 1. Example usage: `cat test2.rttm | python toolbox/rttm2labels.py > test2.txt`
 2. Run Audacity, opening the corresponding WAV file, e.g. `audacity test2.wav`
 3. Using the menu File->Import->Labels... bring up the file selection dialog and navigate to the labels file e.g. test2.txt
 4. You should now see a labels track beneath the audio waveform track in Audacity's edit window
 
 ### other utilities here ###
 
