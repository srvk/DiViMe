# OpenSAT
Diarization using noisemes

To run, first install the VM following the pattern of the one at http://github.com/srvk/eesen-transcriber

After `vagrant up` completes, quickstart test: `vagrant ssh -c "OpenSAT/runOpenSAT.sh /vagrant/test.wav"`
which should produce the output:
```
Extracting features for test.wav ...
(MSG) [2] in SMILExtract : openSMILE starting!
(MSG) [2] in SMILExtract : config file is: /vagrant/MED_2s_100ms_htk.conf
(MSG) [2] in cComponentManager : successfully registered 95 component types.
(MSG) [2] in cComponentManager : successfully finished createInstances
                                 (19 component instances were finalised, 1 data memories were finalised)
(MSG) [2] in cComponentManager : starting single thread processing loop
(MSG) [2] in cComponentManager : Processing finished! System ran for 168 ticks.
DONE!
Filename /home/vagrant/OpenSAT/SSSF/data/feature/evl.med.htk/test.htk
Predicting for /home/vagrant/OpenSAT/SSSF/data/feature/evl.med.htk/test ...
Connection to 127.0.0.1 closed.
```
For more fine grained control, `vagrant ssh` into the VM and from a command line,
and for convenience, CD to the OpenSAT home directory with `cd OpenSAT`
The main script is runOpenSAT.sh and takes one argument: an audio file in .wav format.
Upon successful completion, output will be in the folder (relative to ~/OpenSAT)
`SSSF/data/hyp/<input audiofile basename>/confidence.pkl.gz`

For convenience, the data file is actually linked to storage on the host computer,
creating a folder `data` symlinked to the `data` folder mentioned above, and
visible to the VM as `/vagrant/data`

# DiarTK

To run quick selftest, first `cd ~/ib_diarization_toolkit` then type `bash scripts/run.diarizeme.sh data/mfcc/AMI_20050204-1206.fea data/scp/AMI_20050204-1206.scp result.dir/ AMI_20050204-1206` to run the selftest. The output should look like:
```
-----------------------------------Initialize HMM
```
Find output in the `result.dir` folder

# LDC SAD

See README in ~/ldc_sad_hmm/

# LDC Diarization Scoring

See README in ~/dscore/

