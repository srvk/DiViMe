# OpenSmile SAD


## General intro

openSMILE SAD relies on openSMILE (Eyben et al., 2013a) to generate an 18-coefficient RASTA-PLP plus first order delta features. It then uses a long short-term memory recurrent neural network (see details in Eyben et al., 2013b) that has been pre-trained on two corpora of read and spontaneous speech by adults recorded in laboratory conditions, augmented with various noise types. 

## Some more technical details

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
$ nano /vagrant/conf/vad/vad_segmenter_aclew.conf
```

openSMILE manuals consulted:

- Eyben, F., Woellmer, M., & Schuller, B. (2013). openSMILE: The Munich open Speech and Music Interpretation by Large space Extraction toolkit. Institute for Human-Machine Communication, version 2.0. http://download2.nust.na/pub4/sourceforge/o/project/op/opensmile/openSMILE_book_2.0-rc1.pdf
- Eyben, F., Woellmer, M., & Schuller, B. (2016). openSMILE: open Source Media Interpretation by Large feture-space Extraction toolkit. Institute for Human-Machine Communication, version 2.3. https://www.audeering.com/research-and-open-source/files/openSMILE-book-latest.pdf


## Main references for this tool: 

Eyben, F. Weninger, F. Gross, F., &1 Schuller, B. (2013a). Recent developments in OpenSmile, the Munich open-source multimedia feature extractor. Proceedings of the 21st ACM international conference on Multimedia, 835–838.  

Eyben, F., Weninger, F., Squartini, S., & Schuller, B. (2013b). Real-life voice activity detection with lstm recurrent neural networks and an application to hollywood movies. In Acoustics, Speech and Signal Processing (ICASSP), 2013 IEEE International Conference on (pp. 483-487). IEEE.