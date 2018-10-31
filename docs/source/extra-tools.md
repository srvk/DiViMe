# Extra tools

## Getting sample data

### ACLEW Starter Dataset

The ACLEW Starter dataset is freely available, and can be downloaded in order to test the tools.
To download it, using your terminal, as explained before, go in the DiViMe folder and do:
```$ vagrant ssh -c "tools/get_aclewStarter.sh data/aclewStarter/"```

This will create a folder called aclewStarter inside data, in which you will find the audio files from the public dataset and their corresponding .rttm annotations. At the present time, there are only two matched annotation-wav files, totalling 10 minutes of running recordings

You can then use the tools mentioned before, by replacing the "data/" folder in the command given in the previous paragraph by "aclewStarter/", E.G for noisemes:

```$ vagrant ssh -c "tools/noisemes_sad.sh /"```

#### Reference for the ACLEW Starter dataset: 

Bergelson, E., Warlaumont, A., Cristia, A., Casillas, M., Rosemberg, C., Soderstrom, M., Rowland, C., Durrant, S. & Bunce, J. (2017). Starter-ACLEW. Databrary. Retrieved August 15, 2018 from http://doi.org/10.17910/B7.390.

