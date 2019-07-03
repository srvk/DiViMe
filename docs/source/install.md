# Installing DiViMe

## Requirements

DiViMe can be installed in any operating system and computer with at least 2 CPUs, 8GB of RAM, and 25GB of available disc space. You may need more of everything to actually use the tools, specifically when running on large files. *Before following the instructions under "First Installation"*, you must follow the instructions in the relevant subsection of the Troubleshooting section, at the end of this page, in the following cases:

- your computer has only one core (or you don't know)
- your computer has 25 GB or less of disc space
- your computer has 6 GB or less of RAM
- your computer is running Ubuntu (e.g., 16.04)


## First Installation

1. Install [Vagrant](https://www.vagrantup.com/): Click on the download link for your operating system and follow the prompted instructions

2. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads): When we last checked, the links for download for all operating systems were under the header "VirtualBox 5.2.18 platform packages", so look for a title like that one.

3. Clone the present repository: To do this, you must use a terminal. If you don't know what this means, we recommend that you first follow the [Software Carpentry Shell Tutorial](https://swcarpentry.github.io/shell-novice/) (up to 00:45, namely "Introducing the shell", and "Navigating files and directories"). Next, navigate to the directory in which you want the VM to be hosted and type in: `$ git clone https://github.com/srvk/DiViMe` - or use another way or tool to "clone" a [Git](https://git-scm.com) repository

4. Change into this folder: `$ cd DiViMe`

5. *OBSOLETE as of 2019 (no need to do this any more):* Install HTK. HTK is used by some of these tools (until we find and implement an open-source replacement). We are not allowed to distribute HTK, so unfortunately you have to get it yourself. 

	- Go to the [HTK download page](http://htk.eng.cam.ac.uk/download.shtml)
	- Register by following the instructions on the left (under "Getting HTK": Register)
	- Check that you have received your password via email; you will need it for the next step. 
	- Find the link that reads "HTK source code" under Linux/Unix downloads (since the latter will be installed within the VM which runs under Unix). Notice that you will need your username and password (from the previous step). You must download the version 3.4.1. 
	- Move the HTK-3.4.1.tar.gz file into the root folder of this repository (alongside Vagrantfile).

6. Type `$ vagrant up`

The first time you do this, it will take at least 15 minutes to install all the packages that are needed to build the virtual machine. You are done when you see something like this:

```
FloriansMBP2019:DiViMe metze$ tail -n 8 example-logs/vagrant-up.log 
    default: build succeeded, 4 warnings.
    default: The HTML pages are in build/html.
    default: INFO: You can remove Anaconda2-2019.03-Linux-x86_64.sh, if you don't plan on re-provisioning DiViMe any time soon.
    default: INFO: You can remove MCR_R2017b_glnxa64_installer.zip, if you don't plan on re-provisioning DiViMe any time soon.
    default: ---- Done bootstrapping DiViMe @ Wed Jul  3 03:30:01 UTC 2019 ----
    default: root@vagrant-ubuntu-trusty-64:/home/vagrant# 
    default: exit
```

The instructions above make the simplest assumptions as to your environment. If you have Amazon Web Services, an Ubuntu system, or you do not have admin rights in your computer, you might need to read the [instructions to the eesen-transcriber](https://github.com/srvk/eesen-transcriber/blob/master/INSTALL.md) for fancier options.  Or you can just open an issue [here](https://github.com/srvk/DiViMe/issues), describing your situation.

We are working on [Installing With Docker](https://github.com/srvk/DiViMe/wiki/InstallingWithDocker), but this option is not yet fully functional. 

Please note that there is a large amount of documentation on Vagrant and Virtualbox online, explaining on how to fix assorted errors. It is often a good idea to simply "google" errors that these tools throw; you may find a solution to your specific problem quickly, because the problem may not lie with DiViMe, but the VM, before DiViMe gets involved.

## Checking your installation

The very first time you use DiViMe, it is a good idea to run a quick start test, which will be performed using data from the [VanDam Public Daylong](https://homebank.talkbank.org/access/Public/VanDam-Daylong.html) [HomeBank](homebank.talkbank.org) corpus (VanDam et al., 2015):

1. Open a terminal
2. Navigate inside the DiViMe folder
3. Do `$ vagrant up` (if you haven't done it already)
4. Do `$ vagrant ssh -c "launcher/test.sh"`

This should produce the following output:

```
FloriansMBP2019:DiViMe metze$ vagrant ssh -c "launcher/test.sh"
Starting tests
Checking for HTK...
   HTK missing. You can probably ignore this warning, HTK is no longer needed.
Testing noisemes...
Noisemes passed the test.
Testing OpenSmile SAD...
OpenSmile SAD passed the test.
[...]
Congratulations, everything is OK! 
[...]
```

## Updating DiViMe

If you want to install a new release of DiViMe, you will need to perform the following 3 steps from within the DiViME folder on your terminal:

```
$ vagrant destroy
$ git pull
$ vagrant up
```

## Uninstallation 

If you want to get rid of the files completely, you should perform the following 3 steps from within the DiViME folder on your terminal (assuming you are on Unix):

```
$ vagrant destroy
$ cd ..
$ rm -rf DiViMe
```

## Troubleshooting

### If your computer only has one core

Before doing `vagrant up`, open the file called `DiViMe/Vagrantfile` in a text editor. Change the following line:
```
> vbox.cpus = 2
```
into:
```
> vbox.cpus = 1
```
Then proceed with the installation. Also, if you have more than one CPU, and you do not want DiViMe to take over your entire computer, you can set it to any value >= 2, and you should be fine. DiViMe uses multiple processors, but we have not yet fully optimized for many cores.

### If your computer has 25 GB or less of storage space 

If your computer has less than 25 GB of storage space, then *you cannot build a fully working DiViMe*. In this case, clean up your files to free up space.

### If your computer has 6 GB or less of RAM 

If your computer has less than about 8 GB of RAM, then you may or may not be able to build and use DiViMe. You probably need to change the space allocated to the virtual machine. Before doing `vagrant up`, open the file called `DiViMe/Vagrantfile` in a text editor. Change the following line:
```
> vbox.memory = 4096
```
into:
```
> vbox.memory = 2048
```
Then proceed with the Installation. Also, if you have more RAM, and you experience issues during installation (or use), you may benefit from increasing this value, which should normally not exceed half of your total installed RAM (as a rule of thumb).

### If your computer is running Ubuntu (16.04)

There is a known incompatibility between VirtualBox and the 4.13 Linux kernel on Ubuntu 16.04. What you may do is to install a previous version of the kernel, for example the 4.10, following [these instructions](https://doc.ubuntu-fr.org/kernel#installationSimple), or install the latest version of VirtualBox, which should fix the problem.

Again, there is often a lot of information available online, because Vagrant and VirtualBox are widely used tools.

### If something  else fails

Please open an issue [here](https://github.com/srvk/DiViMe/issues). Please paste the complete output of the failing run there, so we can better provide you with a solution. Also, please provide detailed information on your host system (which OS, RAM, CPU, HDD), which changes you made to the Vagrantfile, and also provide access to the data the system chokes on (if any).
