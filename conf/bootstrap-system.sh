# Please note that the bootstrap.sh script runs as root and not the vagrant user

echo "---- Start bootstrapping DiViMe @ `date` ----"

# Some reporting
echo "-- System information --"
echo "uname -a:" `uname -a`
echo "nproc:" `nproc`
echo "cat /proc/meminfo:"
cat /proc/meminfo
echo "df -h:"
df -h
echo "free:"
free
#dpkg -l

# These downloads take a long time, start them in the background
#echo "c3100392685b5a62c8509c0588ce9376 */vagrant/Anaconda-2.3.0-Linux-x86_64.sh" | \
#    md5sum -c --quiet || wget -qP /vagrant --no-check-certificate \
#			      https://3230d63b5fc54e62148e-c95ac804525aac4b6dba79b00b39d1d3.ssl.cf1.rackcdn.com/Anaconda-2.3.0-Linux-x86_64.sh &
echo "000b186207ad0eec7a667f34d82868f5 */vagrant/opensmile-2-3-0.tar.gz" | \
    md5sum -c --quiet || wget -qO- --no-check-certificate https://www.audeering.com/download/opensmile-2-3-0-tar-gz/?wpdmdl=4782 > /vagrant/opensmile-2-3-0.tar.gz &
echo "dd87c316e211891df8889c52d9167a5d */vagrant/Anaconda2-2019.03-Linux-x86_64.sh" | \
    md5sum -c --quiet || wget -qP /vagrant --no-check-certificate \
    https://repo.anaconda.com/archive/Anaconda2-2019.03-Linux-x86_64.sh &
echo "ef082e99726b14a2b433c59d002ffb3b */vagrant/MCR_R2017b_glnxa64_installer.zip" | \
    md5sum -c --quiet || wget -qP /vagrant --no-check-certificate \
    http://ssd.mathworks.com/supportfiles/downloads/R2017b/deployment_files/R2017b/installers/glnxa64/MCR_R2017b_glnxa64_installer.zip &

if true; then
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
fi

if false; then
if grep --quiet vagrant /etc/passwd
then
    user="vagrant"
else
    user="ubuntu"
fi
cd /home/${user}
fi

# Kaldi and others want bash - otherwise the build process fails
[ $(readlink /bin/sh) == "dash" ] && ln -s -f bash /bin/sh

echo "---- Done system updates @ `date` ----"


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

# install Matlab runtime environment
#echo "Download matlab installer"
#wget -q http://ssd.mathworks.com/supportfiles/downloads/R2017b/deployment_files/R2017b/installers/glnxa64/MCR_R2017b_glnxa64_installer.zip
echo "Waiting for Matlab download to finish"
# This should be our last background process
echo "ef082e99726b14a2b433c59d002ffb3b */vagrant/MCR_R2017b_glnxa64_installer.zip" | \
    md5sum -c --quiet || wait
(
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
)

echo "---- Done bootstrapping DiViMe @ `date` ----"


# To Test:
# - vagrant ssh -c "launcher/test.sh"
# - vagrant ssh -c "yunitate.sh data/" (with a large wav file in data)
# - vagrant ssh -c "utils/high_volubility.py data/7085.wav --diar yunitator_universal --mode CHI --nb_chunks 50"
# ...
