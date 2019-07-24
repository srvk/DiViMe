# Please note that the bootstrap.sh script runs as root and not the vagrant user

echo "---- Start bootstrapping DiViMe @ `date` ----"

# Some reporting
echo "-- System information --"
echo nproc is `nproc`
df -h
cat /proc/meminfo

# These downloads take a long time, start them in the background
#echo "c3100392685b5a62c8509c0588ce9376 */vagrant/Anaconda-2.3.0-Linux-x86_64.sh" | \
#    md5sum -c --quiet || wget -qP /vagrant --no-check-certificate \
#			      https://3230d63b5fc54e62148e-c95ac804525aac4b6dba79b00b39d1d3.ssl.cf1.rackcdn.com/Anaconda-2.3.0-Linux-x86_64.sh &
echo "dd87c316e211891df8889c52d9167a5d */vagrant/Anaconda2-2019.03-Linux-x86_64.sh" | \
    md5sum -c --quiet || wget -qP /vagrant --no-check-certificate \
    https://repo.anaconda.com/archive/Anaconda2-2019.03-Linux-x86_64.sh &
echo "ef082e99726b14a2b433c59d002ffb3b */vagrant/MCR_R2017b_glnxa64_installer.zip" | \
    md5sum -c --quiet || wget -qP /vagrant --no-check-certificate \
    http://ssd.mathworks.com/supportfiles/downloads/R2017b/deployment_files/R2017b/installers/glnxa64/MCR_R2017b_glnxa64_installer.zip &

echo "-- Updating system --"
apt-get update -y
apt-get upgrade -y

apt-get install -y git make automake libtool autoconf patch subversion fuse \
    libatlas-base-dev libatlas-dev liblapack-dev sox libav-tools g++ \
    zlib1g-dev libsox-fmt-all sshfs gcc-multilib libncurses5-dev unzip bc \
    openjdk-6-jre icedtea-netx-common icedtea-netx libxt-dev libx11-xcb1 \
    libc6-dev-i386 festival espeak python-setuptools gawk \
    libboost-all-dev

apt-get autoremove -y && apt-get clean -y && apt-get autoclean -y

if grep --quiet vagrant /etc/passwd
then
    user="vagrant"
else
    user="ubuntu"
fi
cd /home/${user}

# Kaldi and others want bash - otherwise the build process fails
[ $(readlink /bin/sh) == "dash" ] && ln -s -f bash /bin/sh

echo "-- System statistics report --"
echo $user
uname -a
free
#dpkg -l

echo "---- Done system updates @ `date` ----"

# Install OpenSMILE
su ${user} -c "mkdir -p /home/${user}/repos/"
echo "Downloading and installing OpenSMILE"
su ${user} -c "wget -qO- --no-check-certificate https://www.audeering.com/download/opensmile-2-3-0-tar-gz/?wpdmdl=4782 | tar -xzf - -C repos"
cp repos/opensmile-2.3.0/bin/linux_x64_standalone_static/SMILExtract /usr/local/bin && chmod +x /usr/local/bin/SMILExtract

# check if opensmile if installed
if ! [ -x "$(command -v SMILExtract)" ]; then
    echo "*******************************"
    echo "  OPENSMILE installation failed"
    echo "*******************************"
    OPENSMILE_INSTALLED=false;
fi

# Install Anaconda and Theano
#echo "Downloading Anaconda-2.3.0..."
#wget -q --no-check-certificate -P /tmp https://3230d63b5fc54e62148e-c95ac804525aac4b6dba79b00b39d1d3.ssl.cf1.rackcdn.com/Anaconda-2.3.0-Linux-x86_64.sh
echo "Waiting for Anaconda download to finish"
# Anaconda download should be the first background process
#echo "c3100392685b5a62c8509c0588ce9376 */vagrant/Anaconda-2.3.0-Linux-x86_64.sh" | \
#    md5sum -c --quiet || wait `jobs -p|head -n 1`
#echo "Installing Anaconda-2.3.0..."
#sudo -S -u ${user} -i /bin/bash -l -c "bash /vagrant/Anaconda-2.3.0-Linux-x86_64.sh -b"
echo "dd87c316e211891df8889c52d9167a5d */vagrant/Anaconda2-2019.03-Linux-x86_64.sh" | \
    md5sum -c --quiet || wait `jobs -p|head -n 1`
echo "Installing Anaconda..."
sudo -S -u ${user} -i /bin/bash -l -c "bash /vagrant/Anaconda2-2019.03-Linux-x86_64.sh -b -p /home/${user}/anaconda"

# check if anaconda is installed correctly
if ! [ -x "$(command -v /home/${user}/anaconda/bin/conda)" ]; then
    echo "*******************************"
    echo "  conda installation failed"
    echo "*******************************"
    exit 1
fi

if ! grep -q -i anaconda .bashrc; then
    echo -e "\n# For DiViMe and Anaconda:" >> /home/${user}/.bashrc
    echo "export PATH=/home/${user}/launcher:/home/${user}/utils:/home/${user}/anaconda/bin:\$PATH" >> /home/${user}/.bashrc
fi

#su ${user} -c "/home/${user}/anaconda/bin/conda install -q -y numpy scipy mkl dill tabulate joblib sphinx"
# clean up big installer
#rm -f /vagrant/Anaconda-2.3.0-Linux-x86_64.sh

# To use miniconda (~40MB) instead of anaconda (~350MB), uncomment below block
# echo "Downloading Miniconda-4.5.11..."
# wget -q https://repo.continuum.io/miniconda/Miniconda2-4.5.11-Linux-x86_64.sh
# echo "Install miniconda (as Anaconda)"
# sudo -S -u vagrant -i /bin/bash -l -c "bash /home/${user}/Miniconda2-4.5.11-Linux-x86_64.sh -b -p /home/${user}/anaconda"
# # check if anaconda is installed correctly
# if ! [ -x "$(command -v /home/${user}/anaconda/bin/conda)" ]; then
#     echo "*******************************"
#     echo "  conda installation failed"
#     echo "*******************************"
#     exit 1
# fi

# if ! grep -q -i anaconda .bashrc; then
#     echo "export PATH=/home/${user}/launcher:/home/${user}/utils:/home/${user}/anaconda/bin:\$PATH" >> /home/${user}/.bashrc
# fi
# su ${user} -c "/home/${user}/anaconda/bin/conda install numpy scipy mkl dill tabulate joblib cython=0.22.1 sphinx"

# # clean up big installer in home folder
# rm -f Miniconda2-4.5.11-Linux-x86_64.sh

# python3 env
echo "Creating python3 env..."
#cp /vagrant/conf/environment.yml /home/${user}/
su ${user} -c "/home/${user}/anaconda/bin/conda env create -q -f /vagrant/conf/environment.yml"
if [ $? -ne 0 ]; then PYTHON3_INSTALLED=false; fi

# install Matlab runtime environment
#echo "Download matlab installer"
#wget -q http://ssd.mathworks.com/supportfiles/downloads/R2017b/deployment_files/R2017b/installers/glnxa64/MCR_R2017b_glnxa64_installer.zip
echo "Waiting for Matlab download to finish"
# This should be our last background process
echo "ef082e99726b14a2b433c59d002ffb3b */vagrant/MCR_R2017b_glnxa64_installer.zip" | \
    md5sum -c --quiet || wait
echo "Installing Matlab..."
cd /tmp
unzip -q /vagrant/MCR_R2017b_glnxa64_installer.zip
./install -mode silent -agreeToLicense yes

# check if matlab is installed correctly
if [ $? -ne 0 ]; then 
    echo "*******************************"
    echo "  matlab installation failed"
    echo "*******************************"
    exit 1
fi

# add Matlab stuff to path
echo -e "\n# For Matlab:" >> /home/${user}/.bashrc
echo 'LD_LIBRARY_PATH="/usr/local/MATLAB/MATLAB_Runtime/v93/runtime/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v93/bin/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v93/sys/os/glnxa64:$LD_LIBRARY_PATH"' >> /home/${user}/.bashrc
#rm /vagrant/MCR_R2017b_glnxa64_installer.zip

# optionally Install HTK (without it, some other tools will not work)
# the idea is to make users independently download HTK installer since
# we cannot redistribute
echo "Installing HTK..."
cd /home/${user}
if [ -f /vagrant/HTK-3.4.1.tar.gz ]; then
    if [[ ! -d repos/htk ]]; then
        cd /home/${user}/repos/
         tar zxf /vagrant/HTK-3.4.1.tar.gz
        cd htk
         ./configure --without-x --disable-hslab
         sed -i "s/        /\t/g" HLMTools/Makefile # fix bad Makefile
         make all
         make install
    else
        echo "Visibly HTK has been already installed..."
    fi
else
    HTK_INSTALLED=false;
    echo "Can't find HTK-3.4.1.tar.gz. Assuming HTK not needed."
fi

echo "-- Conda report --"
su ${user} -c "/home/${user}/anaconda/bin/conda list"

# POPULATE THE REPOSITORY SECTION
echo "---- Changing into /home/${user}/repos @ `date` ----"
cd /home/${user}/repos/

# Get OpenSAT=noisemes and dependencies
su ${user} -c "git clone -q http://github.com/srvk/OpenSAT --branch yunified" # --branch v1.0 # need Dev

su ${user} -c "/home/${user}/anaconda/bin/pip --disable-pip-version-check install -q ipdb"

su ${user} -c "cp /vagrant/conf/.theanorc /home/${user}/"
#su ${user} -c "/home/${user}/anaconda/bin/conda install -q -y --no-update-deps theano=0.8.2"
su ${user} -c "/home/${user}/anaconda/bin/conda install -q -y theano cudatoolkit pytorch-cpu -c pytorch"

# Install Yunitator and dependencies
su ${user} -c "git clone -q https://github.com/srvk/Yunitator"
#su ${user} -c "/home/${user}/anaconda/bin/conda install -q -y --no-update-deps cudatoolkit"
#su ${user} -c "/home/${user}/anaconda/bin/conda install -q -y --no-update-deps pytorch-cpu -c pytorch"

# Install VCM 
su ${user} -c "git clone -q https://github.com/srvk/vcm"

# Install to-combo sad and dependencies (matlab runtime environnement)
su ${user} -c "git clone -q https://github.com/srvk/To-Combo-SAD"
(cd To-Combo-SAD && su ${user} -c "git checkout 2ce2998")

# Install DiarTK
su ${user} -c "git clone -q http://github.com/srvk/ib_diarization_toolkit"
(cd ib_diarization_toolkit && su ${user} -c "git checkout b3e4deb")

# Install WCE and dependencies
git clone -q https://github.com/aclew/WCE_VM
su ${user} -c "/home/${user}/anaconda/bin/pip --disable-pip-version-check install -q keras tensorflow==1.13.1"
#su ${user} -c "/home/${user}/anaconda/bin/pip --disable-pip-version-check install -q -U tensorflow"

# Phonemizer installation
su ${user} -c "git clone -q https://github.com/bootphon/phonemizer"
(
    cd phonemizer
    su ${user} -c "git checkout 332b8dd"
    python setup.py build
    python setup.py install
)

# Install pyannote (python 3)
## Need to add anaconda to the PATH to be able to activate divime.
export PATH=/home/${user}/anaconda/bin:$PATH
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
su ${user} -c "/home/${user}/anaconda/bin/pip install --disable-pip-version-check pympi-ling tgt intervaltree recommonmark sphinx-markdown-tables sphinx_rtd_theme"

# Document the version of the tools that we have installed
echo "---- git logs follow ----"
cd /home/${user}/repos/
for f in /vagrant *;
do
    if [[ $f =~ opensmile* ]]; then continue; fi
    echo -- git log ${f} --
    git --git-dir=${f}/.git log -1
done
echo "---- git logs done ----"

# Link /vagrant/launcher and /vagrant/utils to home folder where scripts expect them
su ${user} -c "ln -s /vagrant/launcher /home/${user}/"
su ${user} -c "ln -s /vagrant/utils /home/${user}/"

# Silence error message from missing file
su ${user} -c "touch /home/${user}/.Xauthority"

# Provisioning runs as root; we want files to belong to '${user}' (may no longer be needed)
chown -R ${user}:${user} /home/${user}

# Build the docs
echo "---- Building the docs... ----"
cd /vagrant/docs
make SPHINXBUILD=/home/${user}/anaconda/bin/sphinx-build html

# Installation status 
echo "---- Build done ----"
if ! $PYTHON3_INSTALLED; then
    echo "*********************************************"
    echo "Warning: python3 environment is not installed"
    echo "*********************************************"
fi
if ! $OPENSMILE_INSTALLED; then
    echo "***********************************"
    echo "Warning: OpenSMILE is not installed"
    echo "***********************************"
fi
#if ! $HTK_INSTALLED; then 
#    echo "*****************************"
#    echo "Warning: HTK is not installed"
#    echo "*****************************"
#fi

# These files can be 'cached' for faster turn-around
[ -f /vagrant/Anaconda2-2019.03-Linux-x86_64.sh ] && echo INFO: You can remove Anaconda2-2019.03-Linux-x86_64.sh, if you don\'t plan on re-provisioning DiViMe any time soon.
[ -f /vagrant/MCR_R2017b_glnxa64_installer.zip ] && echo INFO: You can remove MCR_R2017b_glnxa64_installer.zip, if you don\'t plan on re-provisioning DiViMe any time soon.

echo "---- Done bootstrapping DiViMe @ `date` ----"

# To Test:
# - vagrant ssh -c "launcher/test.sh"
# - vagrant ssh -c "yunitate.sh data/" (with a large wav file in data)
# - vagrant ssh -c "utils/high_volubility.py data/7085.wav --diar yunitator_universal --mode CHI --nb_chunks 50"
# ...
