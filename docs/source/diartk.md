# DiarTK

## General intro

This tool performs diarization, requiring as input not only .wav audio, but also speech/nonspeech in .rttm format, from human annotation, or potentially from one of the SAD or VAD tools included in this VM. 

The DiarTK model imported in the VM is a C++ open source toolkit by Vijayasenan & Valente (2012). The algorithm first extracts MFCC features, then performs non-parametric clustering of the frames using agglomerative information bottleneck clustering. At the end of the process, the resulting clusters correspond to a set of speakers. The most likely Diarization sequence between those speakers is computed by Viterbi realignement.

We use this tool with the following parameter values:

- weight MFCC = 1 (default)
- Maximum Segment Duration 250 (default)
- Maximum number of clusters possible: 10 (default)
- Normalized Mutual Information threshold: 0.5 (default)
- Beta value: 10 (passed as parameter)
- Number of threads: 3 (passed as parameter)


## Main references: 

D. Vijayasenan and F. Valente, “Diartk: An open source toolkit for research in multistream speaker diarization and its application to meetings recordings,” in Thirteenth Annual Conference of the International Speech Communication Association, 2012. https://pdfs.semanticscholar.org/71e3/9d42aadd9ec44a42aa5cd21202fedb5eaec5.pdf
