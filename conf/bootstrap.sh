echo "Start bootstraping DiViMe"
apt-get update -y
apt-get upgrade -y

if grep --quiet vagrant /etc/passwd
then
    user="vagrant"
else
    user="ubuntu"
fi

sudo apt-get install -y git make automake libtool autoconf patch subversion fuse \
    libatlas-base-dev libatlas-dev liblapack-dev sox libav-tools g++ \
    zlib1g-dev libsox-fmt-all sshfs gcc-multilib libncurses5-dev unzip bc \
    openjdk-6-jre icedtea-netx-common icedtea-netx libxt-dev libx11-xcb1 \
    libc6-dev-i386 festival espeak python-setuptools gawk \
    libboost-all-dev


# Kaldi and others want bash - otherwise the build process fails
[ $(readlink /bin/sh) == "dash" ] && ln -s -f bash /bin/sh

# Install Anaconda and Theano
echo "Downloading Anaconda-2.3.0..."
cd /home/${user}
wget -q https://3230d63b5fc54e62148e-c95ac804525aac4b6dba79b00b39d1d3.ssl.cf1.rackcdn.com/Anaconda-2.3.0-Linux-x86_64.sh
#bash Anaconda-2.3.0-Linux-x86_64.sh -b # batch install into /home/vagrant/anaconda
echo "Installing Anaconda-2.3.0..."
sudo -S -u vagrant -i /bin/bash -l -c "bash /home/${user}/Anaconda-2.3.0-Linux-x86_64.sh -b"
if ! grep -q -i anaconda .bashrc; then
    echo "export PATH=/home/${user}/launcher:/home/${user}/utils:/home/${user}/anaconda/bin:\$PATH" >> /home/${user}/.bashrc 
fi
# assume 'conda' is installed now (get path)
su ${user} -c "/home/${user}/anaconda/bin/conda install numpy scipy mkl dill tabulate joblib"
# clean up big installer in home folder
rm -f Anaconda-2.3.0-Linux-x86_64.sh

# python3 env
# Install Miniconda and python libraries 
# miniconda=Miniconda3-4.5.11-Linux-x86_64.sh
echo "Create python3 env"
cd /home/$user
cp /vagrant/conf/environment.yml /home/${user}/
su ${user} -c "/home/${user}/anaconda/bin/conda env create -f environment.yml"


# install Matlab runtime environment
cd /tmp
wget -q http://ssd.mathworks.com/supportfiles/downloads/R2017b/deployment_files/R2017b/installers/glnxa64/MCR_R2017b_glnxa64_installer.zip
unzip -q MCR_R2017b_glnxa64_installer.zip
./install -mode silent -agreeToLicense yes
# add Matlab stuff to path
echo 'LD_LIBRARY_PATH="/usr/local/MATLAB/MATLAB_Runtime/v93/runtime/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v93/bin/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v93/sys/os/glnxa64:$LD_LIBRARY_PATH"' >> /home/${user}/.bashrc
rm /tmp/MCR_R2017b_glnxa64_installer.zip

# Install OpenSMILE
echo "Installing OpenSMILE"
su ${user} -c "mkdir -p /home/${user}/repos/"
cd /home/${user}/repos/
wget -q http://audeering.com/download/1131/ -O OpenSMILE-2.1.tar.gz
tar zxvf OpenSMILE-2.1.tar.gz
# install SMILExtract system-wide
cp openSMILE-2.1.0/bin/linux_x64_standalone_static/SMILExtract /usr/local/bin
chmod +x /usr/local/bin/SMILExtract
rm OpenSMILE-2.1.tar.gz

# Install openSMILE2.3.0
su ${user} -c "mkdir -p /home/${user}/repos/"
cd /home/${user}/repos/
wget -q https://www.audeering.com/download/1318 -O OpenSMILE-2.3.tar.gz 
tar zxvf OpenSMILE-2.3.tar.gz
chmod +x opensmile-2.3.0/bin/linux_x64_standalone_static/SMILExtract
rm OpenSMILE-2.3.tar.gz

# optionally Install HTK (without it, some other tools will not work)
# the idea is to make users independently download HTK installer since
# we cannot redistribute
cd /home/${user}
if [ -f /vagrant/HTK.tar.gz ]; then
    if [[ ! -d htk ]]; then
    cd /home/${user}/repos/
    su ${user} -c "tar zxf /vagrant/HTK.tar.gz"
    cd htk
    ./configure --without-x --disable-hslab
    sed -i "s/        /\t/g" HLMTools/Makefile # fix bad Makefile
    make all
    make install
    fi
fi



# POPOULATE THE REPOSITORY SECTION
cd /home/${user}/repos/

    # Get OpenSAT=noisemes and dependencies
# git clone http://github.com/srvk/OpenSAT --branch yunified # --branch v1.0 # need Dev

su ${user} -c "/home/${user}/anaconda/bin/pip install -v ipdb"

cp /vagrant/conf/.theanorc /home/${user}/
export PATH=/home/${user}/anaconda/bin:$PATH
su ${user} -c "/home/${user}/anaconda/bin/conda install -y theano=0.8.2"


# Install ldc-sad
# run this version 'by hand' in the VM in repos/ using your github username and password
#git clone http://github.com/aclew/ldc_sad_hmm


# Install Yunitator and dependencies
git clone https://github.com/srvk/Yunitator 
su ${user} -c "/home/${user}/anaconda/bin/conda install cudatoolkit"
su ${user} -c "/home/${user}/anaconda/bin/conda install pytorch-cpu -c pytorch"

# Install VCM 
git clone https://github.com/MilesICL/vcm  

#Install to-combo sad and dependencies (matlab runtime environnement)
git clone https://github.com/srvk/To-Combo-SAD

# Install DiarTK
git clone http://github.com/srvk/ib_diarization_toolkit


# Install eval
git clone http://github.com/srvk/dscore 

# Phonemizer installation
git clone https://github.com/bootphon/phonemizer
cd phonemizer
python setup.py build
python setup.py install

#install launcher and utils
#    cd /home/${user}/
#    git clone https://github.com/aclew/launcher.git
#    chmod +x launcher/*
#    git clone https://github.com/aclew/utils.git
#    chmod +x utils/*


# install pympi (for eaf -> rttm conversion) and tgt (for textgrid -> rttm conversion)
# and intervaltree (needed for rttm2scp.py)
# and recommonmark (needed to make html in docs/)
su ${user} -c "/home/${user}/anaconda/bin/pip install pympi-ling tgt intervaltree recommonmark"

# Link /vagrant/launcher and /vagrant/utils to home folder where scripts expect them
ln -s /vagrant/launcher /home/${user}/
ln -s /vagrant/utils /home/${user}/

# Some cleanup
apt-get autoremove -y

# Silence error message from missing file
touch /home/${user}/.Xauthority

# Provisioning runs as root; we want files to belong to '${user}'
chown -R ${user}:${user} /home/${user}
