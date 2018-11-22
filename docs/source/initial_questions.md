# Initial questions

## What is the ACLEW DiViMe?

It is a collection of diarization tools, i.e., it allows users to add annotations onto a raw audio recording. At present, we have tools to do the following types of annotation:

1) Speech activity detection (answers the question: when is someone talking?)

2) Talker diarization (answers the question: who is talking?)

3) Role diarization (answers the question: what kind of person is talking?)

We are hoping to add more tools in the future, including register detection, syllable quantification, and vocal maturity estimation.

## Who is the ACLEW DiViMe for?

Our target users have "difficult" recordings, E.G. recorded in natural environment, from sensitive populations, etc. Therefore, we are assuming users who are unable to share their audio recordings. Our primary test case involves language acquisition in children 0-3 years of age.

We are hoping to make the use of these tools as easy as possible, but some command line programming will be unavoidable. If you are worried when reading this, we can recommend the Software Carpentry programming courses for researchers, and particularly their [unix bash](http://swcarpentry.github.io/shell-novice) and [version control](http://swcarpentry.github.io/git-novice/) bootcamps.

## What exactly is inside the ACLEW DiViMe?

A virtual machine is actually a mini-computer that gets set up inside your computer. This creates a virtual environment within which we can be sure that our tools run, and run in the same way across all computers (Windows, Mac, Linux). 

Inside this mini-computer, we have tried to put several tools for each one of our three questions. Please note that some of the tools are developed by fellow researchers and programmers, and since we do not control them, we cannot be absolutely certain they will work. Therefore, we provide a general introduction to the contents in the usage section, and a specific list of tools in dedicated Detailed instructions sections.


## How should I cite ACLEW DiViMe?

The main citation is this paper, which explains the structure and idea, and provides some evaluation:

Adrien Le Franc, Eric Riebling, Julien Karadayi, Yun Wang, Camila Scaff, Florian Metze, and Alejandrina Cristia.
The ACLEW DiViMe: An easy-to-use diarization tool. In Proc. INTERSPEECH, Hyderabad; India, September 2018.

The idea of using virtual machines to package speech tools comes from this work:
Florian Metze, Eric Fosler-Lussier, and Rebecca Bates. The speech recognition virtual kitchen. In Proc. INTERSPEECH, Lyon; France, August 2013. https://github.org/srvk.