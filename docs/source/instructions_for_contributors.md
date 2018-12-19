# Instructions For Contributors

Temporary instructions:
We have reorganized DiViMe to try to facilitate tool incorporation and VM use, but these changes have not yet made it to the main branch. Therefore, all of the following instructions are NOT in the master branch, but in the major_reorganization branch. This should make no difference to you, except that you need to check out the right branch to view the VM fitting with these instructions. We provide the code for doing this below.
## Overview
This detailed guide provides you with step-by-step, specific instructions for adapting a tool into the DiViMe environment. The following is a Summary of the steps:
1) Install the VM for yourself
2) Adapt & test your tools in the VM environment, and build the necessary links to other modules.
3) Put your tools and all your custom scripts somewhere where they can be downloaded (e.g., GitHub repo(s))
4) Create a bash script to download and install your tools on the VM (the same steps will be added to a Vagrantfile that controls the entire VM installation)
5) ...
## Before You Start

Before you start, you'll need to get the VM up and running to establish the environment in which your tool will run.

1. Install DiViMe as per the [installation instructions](https://divime.readthedocs.io/en/latest/install.html), including the `vagrant up` that wakes the machine up.

Temporary instructions:
IMPORTANT: After you’ve cloned DiViMe, you should check out the major_reorganization branch, as follows:
```
$ git checkout remotes/origin/major_reorganization
``` 
If ever you want to go back to the master branch, you’d do:
```
$ git checkout master
``` 
If you’ve already built one version of the VM, you’ll need to do:
```
vagrant destroy
vagrant up
```


2. Run the test.sh routine routine. It downloads audio recordings and annotations that you will need to make sure your tool is compatible with the rest of the workflow. Additionally, it will help you spot any issues there may be in your local environment.

## Understanding the general structure of DiViMe

DiViMe is a virtual machine, whose characteristics and contents are almost completely determined by provisioning scripts found at the top level when you clone DiViMe. That means that if you want to contribute to DiViMe, you need to understand its structure, and bootstrapping of the virtual machine. 

In the next section, we will walk you through some stages of modifying the contents of the VM, which you will do initially “by hand”. However, remember the contents of the VM are actually built from reproducible directives ran when you do `vagrant up`. (In technical terms, when the VM is _provisioned_.) Therefore, any changes you make by hand when you are logged into the VM will be lost when you run `vagrant destroy`. Please bear that in mind when trying out the steps in the next section. 

Additionally, by the end of these instructions you will be ready to propose a revised version of the VM - i.e., a new recipe to _provision_ the VM. Therefore, any changes made by hand that you wish to make permanent in the VM should eventually be added to a file called `util/bootstraph.sh`. So you may want to have a copy of bootstraph.sh open to make notes in there of the steps you take, which should be reproduced when provisioning the VM. 

## Adapting Your Tool to the VM Environment

1. For this section, you'll be working almost entirely within the virtual machine. So start by doing `vagrant ssh` to log in. This logs you in as the `vagrant` user, which also has sudo privileges to do things like install software, change permissions, etc. in the virtual machine.

2. Decide where your tool is made available so that it can be copied into the VM. Ideally, it will be somewhere public, such as GitHub, so that anyone rebuilding the machine will get access to it. Alternatively, your tool might be stored on a server in a location you control, and then pulled into the virtual machine. Please note that the latter solution only preserves the anonymity of your code temporarily; if you get to the end of this document, when you are proposing a new version of the VM including your tool, then the URL needs to be known to the world, and accessible to everyone. Please note that neither alternative forces you to make your code open source. You can also share a binary executable (ask us for instructions if you need help).

3. Import your tool into the VM. Once you have decided where to put your tool,  install your code by hand in the location where it will be within the machine: `/home/vagrant/repos`. For example if your code is in a public GitHub repository `https://github.com/srvk/OpenSAT`, you would type into the terminal:
```
cd /home/vagrant/repos
git clone http://github.com/srvk/OpenSAT
```

If your tool is accessible via URL `https://toolnameurl.com/tool.zip`, you would type into the terminal:

```
cd /home/vagrant/repos
wget -q -N https://toolnameurl.com/toolname.zip
unzip -q -o toolname.zip
```
In bootstrap.sh, add the same code to make this step permanently reproducible.



4. If your code requires certain linux packages that are not installed, first install them ‘by hand’ in the VM with a command like `sudo apt-get install <packagename>`. Any packages installed this way should be added similarly to one of the `apt-get` lines in bootstraph.sh like:
```
sudo apt-get install -y libxt-dev libx11-xcb1
```

5. The next step is to install additional dependencies, if any are needed. The VM already includes code to install OpenSmile 2.1, matlab v93, python 3, and anaconda 2.3.0. As in the two previous steps, you can do this by hand within the terminal, but you need to add the step to bootstraph.sh to make it permanent. For instance, if you need the python package `pympi-ling`, you would type `pip install pympi-ling` by hand into the terminal. Additionally, to make this change permanent (and have the dependencies installed when you reprovision the VM or when someone else rebuilds the VM), you need to add it to the Vagrantfile section where python packages are installed, with code like this: 

```
su ${user} -c "/home/${user}/anaconda/bin/pip install pympi-ling”
```

## Write a Wrapper

In this section, we provide detailed instructions for writing a wrapper that allows users to run your tool in a standardized way. The wrapper should be written in bash. Please look at the other launcher wrappers to have an idea of how to structure it, and read on for important considerations.

### Naming Conventions

- You choose your own tool's name. Use anything you want except the other names already in use. We refer to your tool name later as ‘TOOLNAME’
- It may be useful to you to decide at what “stage” of diarization your tool operates. A few things will be clearer if you have a good notion of when this is, such as the number of arguments and whether there is already an evaluation/scoring tool that can be re-used with your tool. We explain these things in more detail below.
- To facilitate end users’ understanding of what tool they are using, we have systematically added the stage name to the wrapper’s name, but you don’t have to follow this procedure if you think it will not be useful.
- We have identified three stages with a fixed name: Sad (for both speech activity detection and voice activity detection), Diar (for speaker diarization and role assignment), and Add (for adding annotation dependent on role assignment). 
- Other stages or stage combinations do not have fixed names. But please feel free to use these stage names. For instance, if your tool only requires audio files as input, then you can use Sad; if it operates on both audio and speech activity detection, then use Diar; and if it is specific to one talker role as input, use Add.

### Tool Autonomy

Tools should be self-aware of where they have been installed, and they should use this awareness to find their dependencies. Said differently, a tool should run "in place" independent of the absolute path it's installed in. Tool dependency paths should be relative to the tool home folder, which should serve as the working directory. Again, please look at the other launcher wrappers to reuse the code present at the top of the wrappers, which correctly reconstructs the absolute path of this folder.


### Input, Output, and Parameters

 Your wrapper should take at least one argument, namely the name of a folder containing data. This folder is appended to “/vagrant” so from your script and the VM’s perspective, data appears in /vagrant/data/. This is actually a shared folder, coming from the host computer working directory. Everything in data/ on the host will in /vagrant/data in the VM, and vice-versa. The default wrapper argument, then, is typically  "data/", but users could also supply “data/mystudy/” or “data/mystudy/baby1/” as the data folder argument. This supports the notion of having multiple datasets in different folders on the host. You can see how other wrappers use this, typically setting the variable `$audio_dir` to /vagrant/data. For the rest of this explanation, we’ll be referring to this folder as DATAFOLDER.  
- The wrapper should process all .wav files inside DATAFOLDER and, optionally, associated annotation files, which are in rttm format.  (For more information on the rttm output, read [NIST's 2009 eval plan](https://web.archive.org/web/20170119114252/http://www.itl.nist.gov/iad/mig/tests/rt/2009/docs/rt09-meeting-eval-plan-v2.pdf)) 
- Your wrapper should support processing long sound files. If you have no better way of achieving this, look to utils/chunk.sh as an example; it breaks up long files into smaller 5 minute chunks, then iteratively calls a tool (in this case, yours), and concatenates the results.
- Your tool must process many sound files. This may require some optimization, for example loading very large model files into memory for each sound file is less optimal than loading once, then iterating over many files. 
- The wrapper should write its *main output* into DATAFOLDER. Typically, this will be one annotation file for each .wav file. If your tool does VAD, SAD, or diarization, this annotation file should respect the rttm format. Additionally, the output file it should be named according to the pattern: toolname_file_original_name.rttm.  If your tool does something other than VAD, SAD, or diarization, use a format that seems reasonable to you. If your tool returns results on individual files (and not e.g., summary statistics over multiple files), we still ask you to name the file toolnameStage_file_original_name.ext -- where “ext” is any extension that is reasonable for the annotation format you have chosen.
- You probably also generate two types of ancillary files: Intermediary representation files, such as features extracted from the wav files; and log files, with detailed information of what was done and how. Both should be initially stored in the DATAFOLDER/temp/TOOLNAME folder. 
- Intermediary representation files should be deleted -- with one exception, introduced below. 
- It is a good idea to print out a short log accompanying each batch of files analyzed, stating the key parameters, version number, and preferred citation. You may want to write out a lot more information. However, our target user may not be technically advanced, and thus including long technical logs may do more to confuse than to help. Log files should also be deleted if they are large (>5MB) -- with one exception, introduced next. 
- Your wrapper should expect an optional argument “--keep-temp”, which is optionally passed in final position. If the last argument to the wrapper is not “--keep-temp”, then ancillary files should be deleted. Code snippet example:

```
KEEPTEMP=false
if [ $BASH_ARGV == "--keep-temp" ]; then
	KEEPTEMP=true
fi
…
if ! $KEEPTEMP; then
	rm -rf $MYTEMP
fi
```
 See any script in `launcher/` for examples. 

## Document Your Tool
Add a documentation file to the `DiViMe/docs/` folder on your host, in markdown format, containing at least the following three pieces of information:
A one-paragraph explanation of what your tool does
A reference or citation that people using your tool must employ
A short section explaining how to use it. This will typically include a description of input & output formats, which can be replaced with references to the Format section of the docs. You should also include an example command line of how to run the tool. Often, this will be `vagrant ssh ‘toolname.sh data/`.
Please include any other information that would be useful to users, such as what parameters are available, how to access them, a tiny example input and output, further technical information on how the tool was built, additional references for work using this tool or on which the tool was built, etc.

For an example, see the tocomboSad section in the [tools documentation](https://divime.readthedocs.io/en/latest/tool_doc.html).

## Create a Reproducible Test for Your Tool
DiViMe comes equipped with a test script that downloads a publicly available daylong audio file and transcript, which all tools within DiViMe can process (and many can be evaluated). In this section, we provide instructions for you to add your tool to the test.sh routine.

By default, all launchers are read-only to avoid accidental editing by newbie users. For the next step, you need to change file permissions so as to be able to edit test.sh. From the host machine, type into the terminal:

```
chmod +rw test.sh
```

Open the file test.sh, which is inside the launcher folder, and add a section testing your tool, modeling it on the other tests present there. Typically, you will need these lines:

Under “# Paths to Tools” add a line with the path to your tool, eg:
TOOLNAMEDIR=$REPOS/TOOLNAME

b) Before “# test finished”, add a section like the following:
 
Example for a Sad type tool:
```
echo "Testing TOOLNAME..."
cd $TOOLNAMEDIR
TESTDIR=$WORKDIR/TOOLNAME-test
rm -rf $TESTDIR; mkdir -p $TESTDIR
ln -fs $TEST_WAV $TESTDIR
$LAUNCHERS/toolnameStage.sh $DATADIR/TOOLNAME-test >$TESTDIR/TOOLNAME-test.log || { echo "   TOOLNAME failed - dependencies"; FAILURES=true;}

if [ -s $TESTDIR/toolnameStage_$BASETEST.rttm ]; then
    echo "TOOLNAME passed the test."
else
    FAILURES=true
    echo "   TOOLNAME failed - no RTTM output"
fi
```
In the above example:
`DATADIR` is predefined as the test 5 minute data folder `data/VanDam-Daylong/BN32`
`TOOLNAME` is whatever human readable name you have given your tool  
`toolnameStage` is the pattern for the system/launcher name for your tool, for example `opensmileSad`  
`BASETEST` is the basename of a test input file e.g. `BN32_010007_test` for the 5 minute input file `BN32_010007_test.wav`


Example for a Diar type tool:
** todo: complete**

Example for an Add type tool:
** todo: complete**


 Run test.sh. Only proceed to the next phase if your tool passes the test.

## Check reproducibility of your version of the VM by reprovisioning
 
Throughout the steps above, you have modified `Vagrantfile/bootstrap.sh` to automatically install your code, any required packages, and any required dependencies. If you have been keeping your Vagrantfile/bootstrap.sh in a good state, you should be able to  rebuild your version of the virtual machine from scratch. 

If necessary, log out from the virtual machine with control+D. Then, from the host machine, run the following code to destroy, re-build, and re-run the test:
```
vagrant destroy
vagrant up
vagrant ssh -c “test.sh”
```

*WARNING:* any changes you made by hand when you were logged into the VM will be lost when you run `vagrant destroy`: to make sure they show up automatically with `vagrant up`, all such dependencies need to be automated (added to Vagrantfile/bootstrap.sh).
If your tool passes the test in this condition, you are ready to integrate your tool to DiViMe for real.

## Integrate Your Tool Into the Public Version of DiViMe 

1. Fork the DiViMe repo
2. Feplace Vagrantfile/bootstrap.sh with your version of Vagrantfile/bootstrap.sh
3. Add in the docs/ your tool’s doc
4. Add your wrapper to launcher/
5. Replace test.sh with your version containing an additional test case specific to your tool
6. Create a pull request to DiViMe requesting your additions be incoporated
