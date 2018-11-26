#!/usr/bin/env/bash
# install HTK after the fact

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


