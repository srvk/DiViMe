# Troubleshooting

## Installation issues
### Virtual Machine creation
If your computer freezes after `vagrant up`, it may be due to several things. 
If your OS is ubuntu 16.04, there's a known incompatibility between VirtualBox and the 4.13 Linux kernel on ubuntu 16.04. What you may do is to install a previous version of the kernel, for example the 4.10, following [these instructions](https://doc.ubuntu-fr.org/kernel#installation_simple), or install the latest version of virtualbox which should fix the problem.
If you are not on ubuntu 16.04, or if the previous fix didn't work, it may also be due to the fact that Vagrant is trying to create a Virtual Machine that asks for too much resources. Please ensure that you have enough space on your computer (you should have at least 15Gb of free space) and check that the memory asked for is okay. If not, you can lower the memory of the VM by changing line 25 of the VagrantFile,
```
vbox.memory = 3072
```
to a lower number, such as
```
vbox.memory = 2048
```
### Resuming the Virtual Machine
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
### LDC SAD, OpenSmile, DiarTK

If ldc_sad, OpenSmile, DiarTK don't seem to work after vagrant up, first, please check that you indeed have the htk archive in your folder. If you don't, please put it there and launch:
```
vagrant up --provision
```
This step will install HTK inside the VM, which is used by several tools including ldc_sad.

### Noisemes
If you use the noisemes_sad or the noisemes_full tool, one problem you may encounter is that it doesn't treat all of your files and gives you an error that looks like this:
```
Traceback (most recent call last):
  File "SSSF/code/predict/1-confidence-vm5.py", line 59, in <module>
    feature = pca(readHtk(os.path.join(INPUT_DIR, filename))).astype('float32')
  File "/home/vagrant/G/coconut/fileutils/htk.py", line 16, in readHtk
    data = struct.unpack(">%df" % (nSamples * sampSize / 4), f.read(nSamples * sampSize))
MemoryError
```
If this happens to you, it's because you are trying to treat more data than the system/your computer can handle.
What you can do is simply put the remaining files that weren't treated in a seperate folder and treat this folder seperately (and do this until all of your files are treated if it happens again on very big datasets).
After that, you can put back all of your data in the same folder.

### Input Format For Transcriptions
If your transcriptions are in TextGrid format but the conversion doesn't seem to work, it's probably because it isn't in the right TextGrid format. 
The input TextGrid the system allows is a TextGrid in which all the tiers have speech segments (so remove tiers with no speech segments) and all the annotated segments for each tiers is indeed speech (so remove segments that are noises or other non-speech type). 


