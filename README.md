# OpenSAT
Diarization using noisemes

To run, first install the VM following the pattern of the one at http://github.com/srvk/eesen-transcriber

After `vagrant up` completes, `vagrant ssh` into the VM and from a command line,
and for convenience, CD to the OpenSAT home directory with `cd OpenSAT`

The main script is runOpenSAT.sh and takes one argument: an audio file in .wav format.
Upon successful completion, output will be in the folder (relative to ~/OpenSAT)
`SSSF/data/hyp/<input audiofile basename>/confidence.pkl.gz`

For convenience, the data file is actually linked to storage on the host computer,
creating a folder `data` symlinked to the `data` folder mentioned above, and
visible to the VM as `/vagrant/data`
