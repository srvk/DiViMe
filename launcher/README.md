# Launcher
This repository contains scripts that launch tools in the ACLEW Diarization VM. 

## Overall summary

### SAD tools
```
noisemesSad.sh
opensmileSad.sh
tocomboSad.sh
```
### Talker Diarization tools
```
diartk.sh

```

### Role assignment tools

```
yunitate.sh

```

### Scoring tools
```
evalDiar.sh
evalSAD.sh
```

### VM Self-test
```
test.sh
```

### python3
```
# activate divime environment to use python 3.6.5
# put below in run script 
source activate divime

# list of libararies installed can be found with
# conda list 
# to install new packages, edit conf/environment.yml file

# to switch back to python 2, run
source deactivate

# And to use python3, make sure you use correct syntax
# in python files and/or checkout python3 branch from
# each tool
# see python3/ for examples
```
