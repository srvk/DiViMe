# Initial questions

## What is the ACLEW DiViMe?

It is a collection of diarization tools, i.e., it allows users to add annotations onto a raw audio recording. At present, we have tools to do the following types of annotation:

1) Speech activity detection (answers the question: when is someone talking?)

2) Talker diarization (answers the question: who is talking?)

We are hoping to add more tools in the future, including register detection, syllable quantification, and vocal maturity estimation.

## Who is the ACLEW DiViMe for?

Our target users have "difficult" recordings, E.G. recorded in natural environment, from sensitive populations, etc. Therefore, we are assuming users who are unable to share their audio recordings. Our primary test case involves language acquisition in children 0-3 years of age.

We are hoping to make the use of these tools as easy as possible, but some command line programming will be unavoidable. If you are worried when reading this, we can recommend the Software Carpentry programming courses for researchers, and particularly their [unix bash](http://swcarpentry.github.io/shell-novice) and [version control](http://swcarpentry.github.io/git-novice/) bootcamps.

## What exactly is inside the ACLEW DiViMe?

A virtual machine is actually a mini-computer that gets set up inside your computer. This creates a virtual environment within which we can be sure that our tools run, and run in the same way across all computers (Windows, Mac, Linux). 

Inside this mini-computer, we have put the following tools:

1) Speech activity detection (answers the question: when is someone talking?)

 * [LDC Speech Activity Detection](https://github.com/aclew/DiViMe#ldc_sad)(coming soon)
 * [Speech Activity Detection Using Noisemes](#noisemes_sad)
 * [OpenSmile SAD](#opensmile_sad)
 * [Threshold Optimized Combo SAD](#tocombo_sad)


2) Talker diarization (answers the question: who is talking?)

 * [DiarTK](#diartk)

3) Evaluation

If a user has some annotations, they may want to know how good the ACLEW DiViMe parsed their audio recordings. In that case, you can use one tool we soon paln to provide to evaluate:

 * [LDC Diarization Scoring](https://github.com/aclew/DiViMe#ldc-diarization-scoring)



