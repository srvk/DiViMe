# Installation instructions

## First installation

Try the following first:

1. Install [Vagrant](https://www.vagrantup.com/): Click on the download link and follow the prompted instructions

1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads): When we last checked, the links for download for all operating systems were under the header "VirtualBox 5.2.18 platform packages", so look for a title like that one.

2. Clone the present repository:

    - Open a terminal window
    - In it, navigate to the directory in which you want the VM to be hosted
    - type in:

`$ git clone https://github.com/aclew/DiViMe`

3. Change into it by 

`$ cd divime`

4. Install HTK

HTK is used by some of these tools (until we find and implement an open-source replacement). We are not allowed to distribute HTK, so unfortunately you have to get it yourself. 

- Go to the HTK download page http://htk.eng.cam.ac.uk/download.shtml
- Register by following the instructions on the left (under "Getting HTK": Register)
- Check that you have received your password via email; you will need it for the next step. 
- Find the link that reads "HTK source code" under your system (if you have a mac, it will be under "Linux/unix downloads"). Notice that you will need your username and password (from the previous step). The download is probably called HTK-3.4.1.tar.gz, although the numbers may change if they update their code. 
- Move the HTK-*.tar.gz file into the root folder of this repository (alongside Vagrantfile), and rename it HTK.tar.gz

5. Type 

`$ vagrant up`

The first time you do this, it will take at least 20 minutes to install all the packages that are needed to build the virtual machine.
Once the virtual machine will be installed, it will stay stuck at "installation finished" for few minutes. However, the tools are not yet installed at this step.
You will need to wait for the tools to be installed, and to take back the control of the terminal to run the tools.

The instructions above make the simplest assumptions as to your environment. If you have Amazon Web Services, an ubuntu system, or you do not have admin rights in your computer, you might need to read the [instructions to the eesen-transcriber](https://github.com/srvk/eesen-transcriber/blob/master/INSTALL.md) for fancier options.  Or you can just open an issue [here](https://github.com/aclew/DiViMe/issues), describing your situation.

Advanced topic: [Installing With Docker](https://github.com/srvk/DiViMe/wiki/InstallingWithDocker)

## Checking your installation

The very first time you use DiViMe, it is a good idea to run a quickstart test, which will be performed using the public files from the ACLEW Starter set (Bergelson et al., 2017):

1. Open a terminal
2. Navigate inside the DiViMe folder
3. Do 
`$ vagrant up`
4. Do
`$ vagrant ssh -c "tools/test.sh"`

This should produce the output:

```
Testing LDC SAD...
LDC SAD passed the test. 

Testing Speech Activity Detection Using Noisemes...
Noisemes passed the test.

Testing OpenSmile SAD...
OpenSmile SAD passed the test.

Testing Threshold Optimized Combo SAD...
Threshold Optimized Combo SAD passed the test.

Testing DiarTK...
DiarTK passed the test. 

Congratulations, everything is OK! 

This is the simple test with a few short files. If you would like to run a test for use with daylong recordings, please run $ vagrant ssh -c "tools/test-daylong.sh". Note that this will download a very large recording.
```


## Checking your installation for daylong files

Many of our users have very long files that they want to analyze. To check that our tools are working in your environment, we will test them using the one of the public files from the vanDam corpus (vanDam & Tully, 2016):

1. Open a terminal
2. Navigate inside the DiViMe folder
3. Do 
`$ vagrant up`
4. Do
`$ vagrant ssh -c "tools/test-daylong.sh"`

This test will take quite some time. It will proceed to download that daylong file, and then process it with all of our tools. Afterwards, it should produce the output:

```
Downloading the daylong file...
Download complete.

Processing annotations...
Annotations processed.

Testing LDC SAD...
LDC SAD passed the test. 

Testing Speech Activity Detection Using Noisemes...
Noisemes passed the test.

Testing OpenSmile SAD...
OpenSmile SAD passed the test.

Testing Threshold Optimized Combo SAD...
Threshold Optimized Combo SAD passed the test.

Testing DiarTK...
DiarTK passed the test. 

Congratulations, everything is OK! 

```

## Common installation errors and fixes

- For LDC SAD, you may get an error "LDC SAD failed because the code for LDC SAD is missing. This is normal, as we are still awaiting the official release!" There is no fix for this. Unfortunately, we need to wait for the official release before we can include LDC SAD. This error means that you cannot use LDC SAD, but you can use any other SAD/VAD. (For example, noisemes.)
- For LDC SAD, Noisemes, and DiarTK, you may get an error "failed the test because a dependency was missing. Please re-read the README for DiViMe installation, Step number 4 (HTK installation)." This means that your HTK installation was not successful. The easiest way to fix it is to install HTK (again).

If something  else fails, please open an issue [here](https://github.com/srvk/DiViMe/issues). Please paste the complete output there, so we can better provide you with a solution.

## Update instructions

If there is a new version of DiViMe, you'll need to perform the following 3 steps from within the DiViME folder on your terminal:


```
$ vagrant destroy
$ git pull
$ vagrant up
```

## Uninstallation instructions

If you want to get rid of the files completely, you should perform the following 3 steps from within the DiViME folder on your terminal:

```
$ vagrant destroy
$ cd ..
$ rm -r -f divime
```


