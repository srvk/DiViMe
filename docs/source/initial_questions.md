# Before starting

## What is the ACLEW DiViMe?

It is a collection of speech processing tools allowing users to automatically add annotations onto a raw audio recording. At present, we have tools to do the following types of annotation:

1) Speech activity detection (_when is someone talking?_)

2) Talker diarization (_who is talking?_)

3) Role diarization (_what kind of person is talking?_)

4) Vocal type classification (_what kind of vocalization is this one?_)

We are hoping to add more tools in the future, including register detection, and syllable quantification.

## Who is the ACLEW DiViMe for?

ACLEW DiViMe is for researchers dealing with speech recorded in naturalistic environments (speech in the wild), typically in daylong recording settings. The population recorded may be sensitive, therefore researchers may not be able to share their audio recordings. Our primary test case involves language acquisition in children 0-3 years of age.

We are trying to make the use of these tools as easy as possible, but some command line programming/scripting is unavoidable. If you are worried when reading this, we can recommend the Software Carpentry programming courses for researchers, and particularly their [unix bash](http://swcarpentry.github.io/shell-novice) and [version control](http://swcarpentry.github.io/git-novice/) bootcamps.

## What exactly is inside the ACLEW DiViMe?

A virtual machine (VM) is actually a mini-computer that gets set up inside your computer. This creates a virtual environment within which we can be sure that our tools run, and run in the same way across all computers (Windows, Mac, Linux). 

Inside this mini-computer, we have tried to put several tools for each one of our three questions. Please note that some of the tools are developed by fellow researchers and programmers, and since we do not control them, we cannot be absolutely certain they will work. Therefore, we provide a general introduction to the contents in the usage section, and a specific list of tools in dedicated Detailed instructions sections.

## How should I cite ACLEW DiViMe?

The main citation is this paper, which explains the structure and idea, and provides some evaluation:

Adrien Le Franc, Eric Riebling, Julien Karadayi, Yun Wang, Camila Scaff, Florian Metze, and Alejandrina Cristia.
[The ACLEW DiViMe: An easy-to-use diarization tool](https://www.isca-speech.org/archive/Interspeech_2018/pdfs/2324.pdf). In Proc. INTERSPEECH, Hyderabad; India, September 2018.

The idea of using virtual machines to package speech tools comes from this work:

Florian Metze, Eric Fosler-Lussier, and Rebecca Bates. The speech recognition virtual kitchen. In Proc. INTERSPEECH, Lyon; France, August 2013. [https://github.org/srvk](https://github.org/srvk).

Depending on the particular tool that you are using, you should potentially cite additional papers that describe the underlying software or methods - please check.
