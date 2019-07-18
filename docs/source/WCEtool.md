# Word count estimation (WCE) tool

This section contains documentation for word count estimation tool.


## Basic description

The purpose of the WCE tool is to provide an estimate of the number of words in an utterance that is provided as an input to the algorithm. It is based on automatic syllabification of speech, followed by mapping of syllable counts + a number of other acoustic features to word counts. The basic functionality is described in Räsänen et al. (submitted).

There are two basic ways to use the current tool:

1) An out-of-the-box version that can be used directly on any speech data , and
2) An adapted version, where the WCE system is first adapted to data provided by the user, and then performs more accurately on similar data. NOTE: This version is going to be obsolote, as the DiViMe will move on to using language-independent syllable count estimation instead of word ount estimation.

In practice, out-of-the-box variant provides only syllable count estimates for the input data, while the adaptation mode can be used
to re-train the system to provide meaningful word count estimates in any language or other data domain. These two operation modes are detailed further below.

Note that the tool assumes that the incoming signals are already segmented into utterances (e.g., using a SAD and/or a diarization tool), as it does not
have an internal module for separating speech from non-speech contents.

By default, the WCE tool is using a bi-directional long short-term memory (LSTM) -based syllabifier, trained on four different languages. The package also
contains a syllabifier stage from speaking-rate estimator published by Wang & Narayanan (2007), as implemented for MATLAB in Räsänen et al. (2018), and an
oscillator-based syllabifier described in Räsänen et al. (2018). The default syllabifier can be changed from configuration files (see "Changing configuration").

All research or other use utilizing this WCE tool should cite the following paper:

Räsänen, O., Seshadri, S., Karadayi, J., Riebling, E., Bunce, J., Cristia, A., Metze, F., Casillas, M., Rosemberg, C., Bergelson, E., & Soderstrom, M. (submitted). Automatic word count estimation from daylong child-centered recordings in various language environments using language-independent syllabification of speech. In review.

## Instructions for direct use (out-of-the-box version)

To get syllable count estimates on your audio files, run

vagrant ssh -c "~/launcher/estimateWCE.sh data/my_audiofolder/ data/WCE_output.txt"

which will run WCE on all .wav files in data/my_audiofolder/ and output results to data/WCE_output.txt.

## Instructions for running out-of-the-box WCE for SAD-based utterance segments

If you have .rttm files corresponding to your .wav files that define speech segments in each recording (see  SAD tool documentation on DiViMe), you can place your .wav files and corresponding .rttm files into <datadir> on the VM (e.g., /vagrant/data/mydatafolder/), and then run:
 
vagrant ssh -c "~/launcher/WCE_from_SAD_outputs.sh <datadir> <sadname>"

e.g.,

vagrant ssh -c "~/launcher/WCE_from_SAD_outputs.sh /vagrant/data/mydatafolder/ opensmileSad

Output syllable counts will be wirtten as .rttm files of format WCE_<sadname>_<wavname>.rttm and located in <datadir>.
 
NOTE: The .rttm files must be named as <sadname>_<wavname>.rttm, where <wavname> is the original .wav file name located in the same <datadir>.


## Instructions for language-adapted use: OBSOLETE. WILL BE UPDATED IN A NEW VERSION OF THE SYSTEM.


## Main references for this tool:

Räsänen, O., Seshadri, S. & Casillas, M. (2018). Comparison of Syllabification Algorithms and Training Strategies for Robust Word Count Estimation across Different Languages and Recording Conditions. Proc. Interspeech-201,  Hyderabad, India, pp. 1200–1204.

Räsänen, O., Seshadri, S., Karadayi, J., Riebling, E., Bunce, J., Cristia, A., Metze, F., Casillas, M., Rosemberg, C., Bergelson, E., & Soderstrom, M.  (submitted). Automatic word count estimation from daylong child-centered recordings in various language environments using language-independent syllabification of speech. In review.

Räsänen, O., Doyle, G., & Frank, M. C. (2018). Pre-linguistic segmentation of speech into syllable-like units. Cognition, 171, 130–150.

Wang, D., & Narayanan, S. (2007). Robust speech rate estimation for spontaneous speech. IEEE Transactions on Audio, Speech, and Language Processing, 15, 2190–2201.


## Questions and bug reports

Send questions & Bug reports to Okko Räsänen (firstname.surname @ aalto.fi)
