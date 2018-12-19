# Troubleshooting


## Noisemes

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




