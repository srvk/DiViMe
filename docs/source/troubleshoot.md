# Troubleshooting

## Installation issues

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

### Virtual Machine creation

If your computer freezes after `vagrant up`, it may be due to several things. 
If your OS is ubuntu 16.04, there's a known incompatibility between VirtualBox and the 4.13 Linux kernel on ubuntu 16.04. What you may do is to install a previous version of the kernel, for example the 4.10, following [these instructions](https://doc.ubuntu-fr.org/kernel#installationSimple), or install the latest version of virtualbox which should fix the problem.
If you are not on ubuntu 16.04, or if the previous fix didn't work, it may also be due to the fact that Vagrant is trying to create a Virtual Machine that asks for too much resources. Please ensure that you have enough space on your computer (you should have at least 15Gb of free space) and check that the memory asked for is okay. If not, you can lower the memory of the VM by changing line 25 of the VagrantFile,
```
vbox.memory = 3072
```
to a lower number, such as
```
vbox.memory = 2048
```

## Resuming the Virtual Machine

If you already used the VM once, shut down your computer, turned it back on and can't seem to be able to do `vagrant up` again, you can simply do
```
vagrant destroy
```
and recreate the VM using
```
vagrant up
```
If you don't want to destroy it, you can try opening the VirtualBox GUI, go to `File -> Settings or Preferences -> Network `, click on the `Host-only Networks` tab, then click the network card icon with the green plus sign in the right, if there are no networks yet listed. The resulting new default network should appear with the name ‘vboxnet0’.
You can now try again with `vagrant up`


## Problems with some of the Tools

### OpenSmile, DiarTK

If  OpenSmile, DiarTK don't seem to work after `vagrant up`, first, please check that you indeed have the htk archive in your folder. If you don't, please put it there and launch:
```
vagrant up --provision
```
This step will install HTK inside the VM, which is used by several tools.

If you use the noisemesSad or the noisemes_full tool, one problem you may encounter is that it doesn't treat all of your files and gives you an error that looks like this:
```
Traceback (most recent call last):
  File "SSSF/code/predict/1-confidence-vm5.py", line 59, in <module>
    feature = pca(readHtk(os.path.join(INPUT_DIR, filename))).astype('float32')
  File "/home/vagrant/G/coconut/fileutils/htk.py", line 16, in readHtk
    data = struct.unpack(">%df" % (nSamples * sampSize / 4), f.read(nSamples * sampSize))
MemoryError
```
If this happens to you, it's because you are trying to treat more data than the system/your computer can handle.
What you can do is simply put the remaining files that weren't treated in a separate folder and treat this folder separately (and do this until all of your files are treated if it happens again on very big datasets).
After that, you can put back all of your data in the same folder.
