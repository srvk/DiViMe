#Download base image ubuntu 16.04
FROM ubuntu:16.04

# Volume configuration: available during `docker build` time, read only
# (use docker build -v ? )
#VOLUME ["/vagrant"]

# hassle #1: default user name in Docker is 'root'
# -m forces to make home directory
RUN useradd -m vagrant

# hassle #2: default Dockerfile shell is sh
SHELL ["/bin/bash", "-c"]

# Update Software repository # Install packages from ubuntu repository
RUN  apt-get update && apt-get install -y git make automake libtool autoconf patch subversion fuse \
       libatlas-base-dev libatlas-dev liblapack-dev sox libav-tools g++ \
       zlib1g-dev libsox-fmt-all apache2 sshfs gcc-multilib libncurses5-dev unzip wget bzip2 libboost-all-dev

RUN     apt-get install -y icedtea-netx-common icedtea-netx
RUN     rm -rf /var/lib/apt/lists/*

    # Kaldi and others want bash - otherwise the build process fails
RUN [ $(readlink /bin/sh) == "dash" ] &&  ln -s -f bash /bin/sh

    # Install Anaconda and Theano
RUN    echo "Downloading Anaconda-2.3.0..."
USER vagrant
WORKDIR /home/vagrant
RUN    wget -q https://3230d63b5fc54e62148e-c95ac804525aac4b6dba79b00b39d1d3.ssl.cf1.rackcdn.com/Anaconda-2.3.0-Linux-x86_64.sh
RUN    bash /home/vagrant/Anaconda-2.3.0-Linux-x86_64.sh -b
RUN    rm Anaconda-2.3.0-Linux-x86_64.sh
RUN if ! grep -q -i anaconda .bashrc; then \
      echo "export PATH=/home/vagrant/anaconda/bin:\$PATH" >> /home/vagrant/.bashrc; \
    fi

    # install Matlab runtime environment
USER root
RUN cd /tmp && wget -q http://ssd.mathworks.com/supportfiles/downloads/R2017b/deployment_files/R2017b/installers/glnxa64/MCR_R2017b_glnxa64_installer.zip && unzip -q MCR_R2017b_glnxa64_installer.zip && ./install -mode silent -agreeToLicense yes
    # add Matlab stuff to path
RUN    echo 'LD_LIBRARY_PATH="/usr/local/MATLAB/MATLAB_Runtime/v93/runtime/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v93/bin/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v93/sys/os/glnxa64:$LD_LIBRARY_PATH"' >> /home/vagrant/.bashrc
RUN    rm /tmp/MCR_R2017b_glnxa64_installer.zip

    # Install OpenSMILE
RUN echo "Installing OpenSMILE"
USER vagrant
WORKDIR /home/vagrant
RUN  wget -q http://audeering.com/download/1131/ -O OpenSMILE-2.1.tar.gz && tar zxvf OpenSMILE-2.1.tar.gz --no-same-owner && rm OpenSMILE-2.1.tar.gz

    # optionally Install HTK (without it, some other tools will not work)
    # the idea is to make users independently download HTK installer since
    # we cannot redistribute
WORKDIR /home/vagrant
USER root
RUN      wget http://speech-kitchen.org/vms/Data/HTK.tar.gz && tar zxf HTK.tar.gz --no-same-owner
WORKDIR /home/vagrant/htk
RUN      ./configure --without-x --disable-hslab
# Fix bad Makefile
RUN	 sed -i "s/        /\t/g" HLMTools/Makefile && make all
RUN      make install

    # Get OpenSAT and all the tools
    # Install DiarTK, LDC SAD, LDC scoring, Rajat's LENA stuff

    #git clone http://github.com/srvk/ldc_sad_hmm

USER vagrant
WORKDIR /home/vagrant
RUN git clone http://github.com/srvk/OpenSAT && cp -f OpenSAT/theanorc /home/vagrant/.theanorc && \
    git clone http://github.com/srvk/ib_diarization_toolkit && \
    git clone https://github.com/rajatkuls/lena-clean && \
    git clone https://github.com/srvk/Yunitator && \
    git clone https://github.com/srvk/To-Combo-SAD && \
    git clone https://github.com/srvk/tools.git && \
    git clone https://github.com/aclew/varia.git

    # Get tools: PDNN, coconut, ldc_sad_hmm
USER vagrant
WORKDIR /home/vagrant
RUN    mkdir G && \
    cd G && \
    git clone http://github.com/yajiemiao/pdnn && \
    git clone http://github.com/srvk/coconut

    # get theanorc!
    # need to figure out how to access this at 'docker build' time. Do it at 'docker run' time instead???
#RUN    cp /vagrant/.theanorc /home/vagrant/

    # install theano
    # install pympi (for eaf -> rttm conversion) and tgt (for textgrid -> rttm conversion)
    # and intervaltree (needed for rttm2scp.py)
    # assume 'conda' is installed now (get path)
    # now dependencies for Yunitator

RUN    export PATH=/home/vagrant/anaconda/bin:$PATH && \
    /home/vagrant/anaconda/bin/conda install -y theano=0.8.2 && \
    /home/vagrant/anaconda/bin/pip install pympi-ling tgt intervaltree && \
    /home/vagrant/anaconda/bin/conda install numpy scipy mkl dill tabulate joblib && \
    /home/vagrant/anaconda/bin/conda install cudatoolkit && \
    /home/vagrant/anaconda/bin/conda install pytorch-cpu -c pytorch

USER root
    # Some cleanup
    # If default user is given by USER, passwordless sudo not work???
RUN  touch /home/vagrant/.Xauthority &&  chown -R vagrant:vagrant /home/vagrant && apt-get autoremove -y

# Open up HTTP / HTTPS ports
#EXPOSE 80 443

CMD ["/bin/bash"]
