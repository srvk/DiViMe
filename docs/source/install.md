# Installing DiViMe

## Requirements

DiViMe can be installed in any operating system and computer with at least 1 CPU (and occupying 2GB when active). You may need to make some adaptations for known issues. Specifically, *before following the instructions under "First Installation"*, you must follow the instructions in the relevant subsection of the Troubleshooting section, at the end of this page, in the following cases:

1. Install [Vagrant](https://www.vagrantup.com/): Click on the download link and follow the prompted instructions

2. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads): When we last checked, the links for download for all operating systems were under the header "VirtualBox 5.2.18 platform packages", so look for a title like that one.

3. Clone the present repository: To do this, you must use a terminal. If you don't know what this means, we recommend that you first follow the [Software Carpentry Shell Tutorial](https://swcarpentry.github.io/shell-novice/) (up to 00:45, namely "Introducing the shell", and "Navigating files and directories"). Next, navigate to the directory in which you want the VM to be hosted and type in: `$ git clone https://github.com/srvk/DiViMe`

4. Change into this folder: `$ cd DiViMe`

5. Install HTK. HTK is used by some of these tools (until we find and implement an open-source replacement). We are not allowed to distribute HTK, so unfortunately you have to get it yourself. 

	- Go to the [HTK download page](http://htk.eng.cam.ac.uk/download.shtml)
	- Register by following the instructions on the left (under "Getting HTK": Register)
	- Check that you have received your password via email; you will need it for the next step. 
	- Find the link that reads "HTK source code" under your system (if you have a mac, it will be under "Linux/unix downloads"). Notice that you will need your username and password (from the previous step). You must download the version 3.4.1. 
	- Move the HTK-3.4.1.tar.gz file into the root folder of this repository (alongside Vagrantfile).

6. Type `$ vagrant up`

The first time you do this, it will take at least 20 minutes to install all the packages that are needed to build the virtual machine.
Once the virtual machine will be installed, it will stay stuck at "installation finished" for few minutes. However, the tools are not yet installed at this step.
You will need to wait for the tools to be installed, and to take back the control of the terminal to run the tools.

The instructions above make the simplest assumptions as to your environment. If you have Amazon Web Services, an ubuntu system, or you do not have admin rights in your computer, you might need to read the [instructions to the eesen-transcriber](https://github.com/srvk/eesen-transcriber/blob/master/INSTALL.md) for fancier options.  Or you can just open an issue [here](https://github.com/srvk/DiViMe/issues), describing your situation.

We are working on [Installing With Docker](https://github.com/srvk/DiViMe/wiki/InstallingWithDocker), but this option is not yet functional.

## Checking your installation

The very first time you use DiViMe, it is a good idea to run a quick start test, which will be performed using data from the [VanDam Public Daylong](https://homebank.talkbank.org/access/Public/VanDam-Daylong.html) [HomeBank](homebank.talkbank.org) corpus (VanDam et al., 2015):

1. Open a terminal
2. Navigate inside the DiViMe folder
3. Do  `$ vagrant up`
4. Do `$ vagrant ssh -c "launcher/test.sh"`

This should produce the output:

```

Testing Speech Activity Detection Using Noisemes...
Noisemes passed the test.

Testing OpenSmile SAD...
OpenSmile SAD passed the test.

Testing Threshold Optimized Combo SAD...
Threshold Optimized Combo SAD passed the test.

Testing DiarTK...
DiarTK passed the test. 

Testing Yunitator...
Yunitator passed the test. 

Testing DScore...
Yunitator passed the test. 


Congratulations, everything is OK! 

```


Congratulations, everything is OK! 

- For noisemesSad, and diartk, you may get an error "failed the test because a dependency was missing. Please re-read the README for DiViMe installation, Step number 4 (HTK installation)." This means that your HTK installation was not successful. Please re-download the


## Updating DiViMe

If there is a new version of DiViMe, you will need to perform the following 3 steps from within the DiViME folder on your terminal:


```
$ vagrant destroy
$ git pull
$ vagrant up
```

## Uninstallation 

If you want to get rid of the files completely, you should perform the following 3 steps from within the DiViME folder on your terminal:

```
$ vagrant destroy
$ cd ..
$ rm -r -f divime
```

## Troubleshooting

### If your computer only has one core

Before doing `vagrant up`, open the file called Vagrantfile in a text editor. Change the following line:

> vbox.cpus = 2

into:

> vbox.cpus = 1

Then proceed with the Installation.

### If your computer has 20 GB or less of storage space 

If your computer has less than 20 GB of storage space, then *you cannot build a fully working DiViMe* (without crippling your computer). In this case, clean up your files to free up space.

### If your computer has 6 GB or less of RAM 

If your computer has less than 4 GB of RAM, then *you cannot build a fully working DiViMe* (without crippling your computer). 

For computers with 4-6 GB of RAM, you need to change the space allocated to the virtual machine. Before doing `vagrant up`, open the file called Vagrantfile in a text editor. Change the following line:

> vbox.memory = 3072

into:

> vbox.memory = 2048

Then proceed with the Installation.

### If your computer is running ubuntu (16.04)

There is a known incompatibility between VirtualBox and the 4.13 Linux kernel on ubuntu 16.04. What you may do is to install a previous version of the kernel, for example the 4.10, following [these instructions](https://doc.ubuntu-fr.org/kernel#installationSimple), or install the latest version of virtualbox, which should fix the problem.

### If something  else fails

Please open an issue [here](https://github.com/srvk/DiViMe/issues). Please paste the complete output there, so we can better provide you with a solution.


## References

VanDam, M., De Palma, P., Strong, W. E. (2015, May). Fundamental frequency of speech directed to children who have hearing loss. Poster presented at the 169th Meeting of the Acoustical Society of America, Pittsburgh, PA. 
