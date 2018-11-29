# More information about DiViMe

DiViMe is a virtual machine, whose characteristics and contents are almost completely determined by provisioning scripts found in the DiViMe folder created when you did `git clone https://github.com/srvk/DiViMe/.` This section provides information to help you understand the DiViMe structure in conceptual terms (the "pipeline"). We also explain the process of "bootstrapping" or creation of this virtual machine. Finally, we  describe the folder structure. If you just want to use the tools in DiViMe, you can probably skip this whole section, or read just the `Pipeline structure` section.

## Pipeline Structure

DiViMe is a platform for tools to analyze naturalistic, unannotated audiorecordings. We consider this process to involve three kinds of processes: 

- speech activity detection and voice activity detection = “detecting vocalizations”, 
- diarization = “deciding to whom the vocalizations belong”, and 
- “additional annotations”


Some tools actually combine two of these stages (e.g. a tool may do both speech activity detection and role attribution in one fell swoop).

## Building a virtual machine

The structures and contents of the VM are actually built from reproducible directives which are executed when you do `vagrant up`. In technical terms, this is called VM is _provisioning_. In a nutshell, a file called "Vagrantfile" builds the machine (e.g., creates a virtual machine, allocates memory, installs an operating systems). Another file (conf/bootstrap.sh) installs tools within this virtual machine. For detailed documentation, see https://www.vagrantup.com/docs/vagrantfile/.



## Folder Structure

By virtue of how DiViMe is provisioned, there is some information that is accessible both from the host machine (i.e., your computer) and the virtual machine (i.e., the minicomputer built inside your computer). These are called `shared folders`. 

*The following folders are shared between the host and the virtual machine, and thus accessible from both:*

- *utils/* contains ancillary files, typically used across more than one tool
- *launcher/* contains files that target users will use to launch different tools
- *conf/* is for configuration files for two potential reasons: they are shared across more than one tool, or to make them more easily editable from outside the VM
- *data/* folder where users put the data to be analyzed, and recover the automatically annotated files

From within the virtual machine, these are inside /vagrant: /vagrant/utils, /vagrant/launcher, etc. Some of these are also accessible from the home of the default user, through links, ie, ~/utils and ~/launcher. (the default user is vagrant for virtualbox)

*The following folders can only be found within the virtual machine*:

- *repos/* contains any repository that is cloned into the machine, typically tools for the user, but also tools used by other tools to do e.g. feature extraction. 

From within the virtual machine, ~/repos is inside the vagrant user’s home folder, so you can access it as ~/repos/ or /home/vagrant/repos. 

