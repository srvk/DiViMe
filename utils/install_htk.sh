#!/bin/bash
# install HTK after the fact

if grep --quiet vagrant /etc/passwd
then
    user="vagrant"
else
    user="ubuntu"
fi

# optionally Install HTK (without it, some other tools will not work)
# the idea is to make users independently download HTK installer since
# we cannot redistribute
cd /home/${user}
if [ -f /vagrant/HTK.tar.gz ]; then
    if [[ ! -d htk ]]; then
    cd /home/${user}/repos/
    sudo tar zxf /vagrant/HTK.tar.gz
    cd htk
    sudo ./configure --without-x --disable-hslab
    sudo sed -i "s/        /\t/g" HLMTools/Makefile # fix bad Makefile
    sudo make all
    sudo make install
    fi
fi


