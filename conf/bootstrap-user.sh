#!/bin/bash

# Please note that the bootstrap.sh script runs as root and not the vagrant user
# bootstrap-user.sh runs as the actual user

echo "---- Start bootstrapping user (${USER}) part of DiViMe @ `date` ----"

echo "Installing Anaconda..."
cd ${HOME}
bash /vagrant/Anaconda2-2019.03-Linux-x86_64.sh -b -p ${HOME}/anaconda

# check if anaconda is installed correctly
if ! [ -x "$(command -v ${HOME}/anaconda/bin/conda)" ]; then
    echo "*******************************"
    echo "  conda installation failed"
    echo "*******************************"
    exit 1
fi

if ! grep -q -i anaconda .bashrc; then
    echo -e "\n# For DiViMe and Anaconda:" >> ${HOME}/.bashrc
    echo "export PATH=${HOME}/launcher:${HOME}/utils:${HOME}/anaconda/bin:\$PATH" >> ${HOME}/.bashrc
fi


# python3 env
echo "Creating python3 env..."
${HOME}/anaconda/bin/conda env create -q -f /vagrant/conf/environment.yml
if [ $? -ne 0 ]; then PYTHON3_INSTALLED=false; fi

echo "-- Conda report --"
${HOME}/anaconda/bin/conda list


# add Matlab stuff to path
echo -e "\n# For Matlab:" >> ${HOME}/.bashrc
echo 'LD_LIBRARY_PATH="/usr/local/MATLAB/MATLAB_Runtime/v93/runtime/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v93/bin/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v93/sys/os/glnxa64:$LD_LIBRARY_PATH"' >> ${HOME}/.bashrc


# optionally Install HTK (without it, some other tools will not work)
# the idea is to make users independently download HTK installer since
# we cannot redistribute
if [ -f /vagrant/HTK-3.4.1.tar.gz ]; then
    echo "Installing HTK..."
    cd ${HOME}
    if [[ ! -d repos/htk ]]; then
        cd ${HOME}/repos/
        tar zxf /vagrant/HTK-3.4.1.tar.gz
        cd htk
        ./configure --without-x --disable-hslab
        sed -i "s/        /\t/g" HLMTools/Makefile # fix bad Makefile
        make all
        sudo make install
    else
        echo "Visibly HTK has been already installed..."
    fi
else
    HTK_INSTALLED=false;
    echo "Can't find HTK-3.4.1.tar.gz. Assuming HTK not needed."
fi


# POPULATE THE REPOSITORY SECTION
echo "---- Changing into ${HOME}/repos @ `date` ----"
mkdir -p ${HOME}/repos && cd ${HOME}/repos


# Install OpenSMILE
(
    echo "Installing OpenSMILE"
    #wget -qO- --no-check-certificate https://www.audeering.com/download/opensmile-2-3-0-tar-gz/?wpdmdl=4782 | tar -xzf -
    tar -xzf /vagrant/opensmile-2-3-0.tar.gz
    sudo cp opensmile-2.3.0/bin/linux_x64_standalone_static/SMILExtract /usr/local/bin
    sudo chmod +x /usr/local/bin/SMILExtract

# check if opensmile if installed
if ! [ -x "$(command -v SMILExtract)" ]; then
    echo "*******************************"
    echo "  OPENSMILE installation failed"
    echo "*******************************"
    OPENSMILE_INSTALLED=false;
fi
)


# Get OpenSAT=noisemes and dependencies
git clone -q http://github.com/srvk/OpenSAT --branch yunified # --branch v1.0 # need Dev

${HOME}/anaconda/bin/pip --disable-pip-version-check install -q ipdb

cp /vagrant/conf/.theanorc ${HOME}/
#su ${user} -c "/home/${user}/anaconda/bin/conda install -q -y --no-update-deps theano=0.8.2"
${HOME}/anaconda/bin/conda install -q -y theano cudatoolkit pytorch-cpu -c pytorch

# Install Yunitator and dependencies
git clone -q https://github.com/srvk/Yunitator
#su ${user} -c "/home/${user}/anaconda/bin/conda install -q -y --no-update-deps cudatoolkit"
#su ${user} -c "/home/${user}/anaconda/bin/conda install -q -y --no-update-deps pytorch-cpu -c pytorch"

# Install VCM 
git clone -q https://github.com/srvk/vcm

# Install to-combo sad and dependencies (matlab runtime environnement)
git clone -q https://github.com/srvk/To-Combo-SAD
(cd To-Combo-SAD && git checkout 2ce2998)

# Install DiarTK
git clone -q http://github.com/srvk/ib_diarization_toolkit
(cd ib_diarization_toolkit && git checkout b3e4deb)

# Install WCE and dependencies
git clone -q https://github.com/aclew/WCE_VM
${HOME}/anaconda/bin/pip --disable-pip-version-check install -q keras tensorflow==1.13.1
#su ${user} -c "/home/${user}/anaconda/bin/pip --disable-pip-version-check install -q -U tensorflow"

# Phonemizer installation
git clone -q https://github.com/bootphon/phonemizer
(
    cd phonemizer
    git checkout 332b8dd
    python setup.py build
    sudo python setup.py install
)

# Install pyannote (python 3)
## Need to add anaconda to the PATH to be able to activate divime.
export PATH=${HOME}/anaconda/bin:$PATH
source activate divime
pip --disable-pip-version-check install -q pyannote.metrics pyannote.core
conda deactivate

#install launcher and utils
#    cd /home/${user}/
#    git clone https://github.com/aclew/launcher.git
#    chmod +x launcher/*
#    git clone https://github.com/aclew/utils.git
#    chmod +x utils/*

# install pympi (for eaf -> rttm conversion) and tgt (for textgrid -> rttm conversion)
# and intervaltree (needed for rttm2scp.py)
# and recommonmark (needed to make html in docs/)
${HOME}/anaconda/bin/pip install --disable-pip-version-check pympi-ling tgt intervaltree recommonmark sphinx-markdown-tables sphinx_rtd_theme

# Document the version of the tools that we have installed
echo "---- git logs follow ----"
cd ${HOME}/repos/
for f in /vagrant *;
do
    if [[ $f =~ opensmile* ]]; then continue; fi
    echo -- git log ${f} --
    git --git-dir=${f}/.git log -1
done
echo "---- git logs done ----"


# Link /vagrant/launcher and /vagrant/utils to home folder where scripts expect them
ln -s /vagrant/launcher /vagrant/utils ${HOME}

# Silence error message from missing file
touch ${HOME}/.Xauthority


# Build the docs
echo "---- Building the docs... ----"
cd /vagrant/docs
make SPHINXBUILD=${HOME}/anaconda/bin/sphinx-build html

echo "---- Sanity checks in user part of DiViMe @ `date` ----"

# These files can be 'cached' for faster turn-around
[ -f /vagrant/opensmile-2-3-0.tar.gz ] && echo INFO: You can remove opensmile-2-3-0.tar.gz, if you don\'t plan on re-provisioning DiViMe any time soon.
[ -f /vagrant/Anaconda2-2019.03-Linux-x86_64.sh ] && echo INFO: You can remove Anaconda2-2019.03-Linux-x86_64.sh, if you don\'t plan on re-provisioning DiViMe any time soon.
[ -f /vagrant/MCR_R2017b_glnxa64_installer.zip ] && echo INFO: You can remove MCR_R2017b_glnxa64_installer.zip, if you don\'t plan on re-provisioning DiViMe any time soon.

echo "---- Done bootstrapping user part of DiViMe @ `date` ----"
