# Installing DiViMe

## Requirements

DiViMe can be installed in any operating system and computer with at least 2 CPUs, 8GB of RAM, and 25GB of available disc space. You may need more of everything to actually use the tools, specifically when running on large files. *Before following the instructions under "First Installation"*, you must follow the instructions in the relevant subsection of the Troubleshooting section, at the end of this page, in the following cases:

- your computer has only one core (or you don't know)
- your computer has 25 GB or less of disc space
- your computer has 6 GB or less of RAM
- your computer is running Ubuntu (e.g., 16.04)


## First Installation

1. Install [Vagrant](https://www.vagrantup.com/): Click on the download link for your operating system and follow the prompted instructions

2. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads): When we last checked, the links for download for all operating systems were under the header "VirtualBox 5.2.18 platform packages", so look for a title like that one (picking the latest version, most likely).

3. Clone the present repository: To do this, you must use a terminal. If you don't know what this means, we recommend that you first follow the [Software Carpentry Shell Tutorial](https://swcarpentry.github.io/shell-novice/) (up to 00:45, namely "Introducing the shell", and "Navigating files and directories"). Next, navigate to the directory in which you want the VM to be hosted and type in: `$ git clone https://github.com/srvk/DiViMe` - or use another way or tool to "clone" a [Git](https://git-scm.com) repository

4. Change into this folder: `$ cd DiViMe`

5. Install several Vagrant plugins: `$ vagrant plugin install vagrant-aws vagrant-sshfs vagrant-vbguest`

Depending on how you want to use DiViMe, and which provider you will be using, you may or may not need to install the above plugins (or you may need to install additional plugins), but this quickly turns into an advanced topic, because not all plugins will work equally well on all host platforms ...

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

## Using it

You can now run commands and experiment on multiple data files, using as many `$ vagrant ssh -c "[...]"` calls as you like. It *should* also be safe to have multiple ssh connections to the VM and run many experiments in parallel, if the tool that you are using supports it. There *may* be some that are not "thread-safe".

## When you are done with DiViMe, Teardown

After working with DiViMe, you can shut down the virtual machine, which will free up CPU and RAM resources on your computer (but not disc space). To do this, type `$ vagrant halt` or `$ vagrant suspend`. To continue working with the VM at a later point, simply issue another `$ vagrant up` command.

When you do `$ vagrant up` again (without previously shutting down the VM), its output will probably end in:

```
    default: /vagrant => /Users/metze/Work/Kitchen/DiViMe
==> default: Machine already provisioned. Run `vagrant provision` or use the `--provision`
==> default: flag to force provisioning. Provisioners marked to run always will still run.
```

This is safe to ignore, and you can continue with `$vagrant ssh -c "[...]"` as needed. Note that the VM is not set up to actually support a proper separate provisioning step, so `$ vagrant provision` probably will not work reliably.

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

DiViMe is very powerful (and complex), and despite our best efforts, there are many ways to fail. The first order of business is therefore to pin-point the problem, which may or may not be related to DiViMe specifically. First, look at DiViMe's issue tracking system [here](https://github.com/srvk/DiViMe/issues) - maybe you can find the solution already. If not, read on below.

In many cases, the problem will be generic, and related to Vagrant, Virtualbox, or some other underlying tool. In this case, there are often online resources that can often be found with a bit of googleing - and you should add the solution to the DiViMe knowledge base by opening an issue, and posting the solution.

If you cannot find a solution after reading https://divime.readthedocs.io/en/latest/troubleshoot.html, open an issue and supply as much information as needed for someone else to be able to (ideally) reproduce your error. Typically, this means

- Your operating system and computer specs (RAM, HDD, CPUs)
- Your version of Vagrant
- Your version of Virtualbox (or any other provider that you run)
- Your version of DiViMe
- The command(s) that you type and the output that you get, ideally a log file (complete - not just the last line)
- You can find some example log files in the logs/ folder, so you can compare your output against the output we see
- Anything else that may be relevant

We are monitoring the issues and will try to get back yo you.


## References

VanDam, M., De Palma, P., Strong, W. E. (2015, May). Fundamental frequency of speech directed to children who have hearing loss. Poster presented at the 169th Meeting of the Acoustical Society of America, Pittsburgh, PA.
