# coding: utf-8
# -*- mode: ruby -*-
# vi: set ft=ruby

Vagrant.configure("2") do |config|

  # Default provider is VirtualBox!
  # If you want AWS, you need to populate and run e.g.
  #   . aws.sh; vagrant up --provider aws
  # Make sure you don't check in aws.sh (maybe make a copy with your "secret" data)
  # Before that, do
  #   vagrant plugin install vagrant-aws; vagrant plugin install vagrant-sshfs

#  if you have this plugin (https://github.com/dotless-de/vagrant-vbguest) installed
#  the following line disables it (for faster startup)
#  config.vbguest.auto_update = false
  config.ssh.forward_x11 = true

  config.vm.provider "virtualbox" do |vbox, override|
    config.vm.synced_folder ".", "/vagrant", owner: "vagrant", group: "vagrant", :mount_options => ["dmode=777", "fmode=777"]
    
    override.vm.box = "ubuntu/trusty64"
    # enable (uncomment) this for debugging output
    #vbox.gui = true
    
    # The shell to use when executing SSH commands from Vagrant. By default this is bash -l. 
    # Note that this has no effect on the shell you get when you log into the VM with vagrant ssh. 
    # This gives 'interactive' login which properly sources .bashrc to pick up e.g. Python environment                                      
    config.ssh.shell = "bash -i"

    # host-only network on which web browser serves files
    config.vm.network "private_network", ip: "192.168.56.101"

    vbox.cpus = 2
    vbox.memory = 3072
  end

  config.vm.provider "docker" do |d, override|
    #     d.image = 'ubuntu:14.04'
    d.image = 'tknerr/baseimage-ubuntu:14.04'
    d.remains_running = true
    d.has_ssh = true
    # (too late?)
    override.vm.synced_folder ".", "/vagrant", owner: "vagrant", group: "vagrant", :mount_options => ["dmode=777", "fmode=777"]
  end

  config.vm.provider "aws" do |aws, override|

    aws.tags["Name"] = "Diarization VM"
    aws.ami = "ami-663a6e0c" # Ubuntu ("Trusty") Server 14.04 LTS AMI - US-East region
    aws.instance_type = "m3.xlarge"

    override.vm.synced_folder ".", "/vagrant", type: "sshfs", ssh_username: ENV['USER'], ssh_port: "22", prompt_for_password: "true"

    override.vm.box = "http://speechkitchen.org/dummy.box"

    # it is assumed these environment variables were set by ". aws.sh"
    aws.access_key_id = ENV['AWS_KEY']
    aws.secret_access_key = ENV['AWS_SECRETKEY']
    aws.keypair_name = ENV['AWS_KEYPAIR']
    override.ssh.username = "ubuntu"
    override.ssh.private_key_path = ENV['AWS_PEM']

    aws.terminate_on_shutdown = "true"
    aws.region = ENV['AWS_REGION']

    # https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#SecurityGroups
    # Edit the security group on AWS Console; Inbound tab, add the HTTP rule
    aws.security_groups = "launch-wizard-1"

    #aws.subnet_id = "vpc-666c9a02"
    aws.region_config "us-east-1" do |region|
      #region.spot_instance = true
      region.spot_max_price = "0.1"
    end

    # this works around the error from AWS AMI vm on 'vagrant up':
    #   No host IP was given to the Vagrant core NFS helper. This is
    #   an internal error that should be reported as a bug.
    #override.nfs.functional = false
  end

  config.vm.provider "azure" do |azure, override|
    # each of the below values will default to use the env vars named as below if not specified explicitly
    azure.tenant_id = ENV['AZURE_TENANT_ID']
    azure.client_id = ENV['AZURE_CLIENT_ID']
    azure.client_secret = ENV['AZURE_CLIENT_SECRET']
    azure.subscription_id = ENV['AZURE_SUBSCRIPTION_ID']

    # For now, this brings up Ubuntu 16.04 LTS
    override.ssh.private_key_path = '~/.ssh/id_rsa'
    override.vm.box = "azure"
    #azure.vm_name = "Eesen Transcriber"
    #azure.resource_group_name = "jsalt"
    azure.location = "westus2"
    #override.vm.box = "https://github.com/azure/vagrant-azure/raw/v2.0/dummy.box"
  end

    config.vm.provision "shell", inline: <<-SHELL
    sudo apt-get update -y
    sudo apt-get upgrade -y

    if grep --quiet vagrant /etc/passwd
    then
      user="vagrant"
    else
      user="ubuntu"
    fi

    sudo apt-get install -y git make automake libtool autoconf patch subversion fuse \
       libatlas-base-dev libatlas-dev liblapack-dev sox libav-tools g++ \
       zlib1g-dev libsox-fmt-all sshfs gcc-multilib libncurses5-dev unzip
    sudo apt-get install -y openjdk-6-jre || sudo apt-get install -y icedtea-netx-common icedtea-netx
#    sudo apt-get install -y libtool-bin apache2

 
    # Kaldi and others want bash - otherwise the build process fails
    [ $(readlink /bin/sh) == "dash" ] && sudo ln -s -f bash /bin/sh

    # Install Anaconda and Theano
    echo "Downloading Anaconda-2.3.0..."
    cd /home/${user}
    wget -q https://3230d63b5fc54e62148e-c95ac804525aac4b6dba79b00b39d1d3.ssl.cf1.rackcdn.com/Anaconda-2.3.0-Linux-x86_64.sh
    #bash Anaconda-2.3.0-Linux-x86_64.sh -b # batch install into /home/vagrant/anaconda
    echo "Installing Anaconda-2.3.0..."
    sudo -S -u vagrant -i /bin/bash -l -c "bash /home/${user}/Anaconda-2.3.0-Linux-x86_64.sh -b"
    if ! grep -q -i anaconda .bashrc; then
      echo "export PATH=/home/${user}/anaconda/bin:\$PATH" >> /home/${user}/.bashrc 
    fi
    # assume 'conda' is installed now (get path)
    su ${user} -c "/home/${user}/anaconda/bin/conda install numpy scipy mkl dill tabulate joblib"

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

    # optionally Install HTK (without it, some other tools will not work)
    # the idea is to make users independently download HTK installer since
    # we cannot redistribute
    if [ -f /vagrant/HTK.tar.gz ]
    then
      cd /home/${user}/repos/
      su ${user} -c "tar zxf /vagrant/HTK.tar.gz"
      cd htk
      ./configure --without-x --disable-hslab
      sed -i "s/        /\t/g" HLMTools/Makefile # fix bad Makefile
      make all
      make install
    fi

 

	# POPOULATE THE REPOSITORY SECTION
    cd /home/${user}/repos/

     # Get OpenSAT=noisemes and dependencies
    git clone http://github.com/srvk/OpenSAT # --branch v1.0 # need Dev
    su ${user} -c "/home/${user}/anaconda/bin/pip install -v ipdb"

    cp /vagrant/conf/.theanorc /home/${user}/
    export PATH=/home/${user}/anaconda/bin:$PATH
    su ${user} -c "/home/${user}/anaconda/bin/conda install -y theano=0.8.2"


   # Install ldc-sad
    # run this version 'by hand' in the VM in repos/ using your github username and password
    #git clone http://github.com/aclew/ldc_sad_hmm


   # Install Yunitator and dependencies
    git clone https://github.com/srvk/Yunitator # --branch v1.0 # need Dev
    su ${user} -c "/home/${user}/anaconda/bin/conda install cudatoolkit"
    su ${user} -c "/home/${user}/anaconda/bin/conda install pytorch-cpu -c pytorch"


   #Install to-combo sad and dependencies (matlab runtime environnement)
   git clone https://github.com/srvk/To-Combo-SAD --branch v1.0
   sudo apt-get install -y libxt-dev libx11-xcb1

   # Install DiarTK
    git clone http://github.com/srvk/ib_diarization_toolkit --branch v1.0

 
   # Install eval
    git clone http://github.com/srvk/dscore #--branch v1.0

   # Phonemizer installation
    sudo apt-get install -y festival espeak
    git clone https://github.com/bootphon/phonemizer
    cd phonemizer
    python setup.py build
    sudo apt-get install -y python-setuptools
    sudo python setup.py install

    #install launcher and utils
    cd /home/${user}/
    git clone https://github.com/aclew/launcher.git
    chmod +x launcher/*
    git clone https://github.com/aclew/utils.git
    chmod +x utils/*


    # install pympi (for eaf -> rttm conversion) and tgt (for textgrid -> rttm conversion)
    # and intervaltree (needed for rttm2scp.py)
    # and recommonmark (needed to make html in docs/)
    su ${user} -c "/home/${user}/anaconda/bin/pip install pympi-ling tgt intervaltree recommonmark"

    # OpenSAT (noisemes) and possibly other tools depend on tools ~/G/.
    # So let's not do away with it.
#    cd /home/${user}
#    mkdir -p G
#    cd G
#    ln -s /home/vagrant/repos/pdnn .
#    ln -s /home/vagrant/repos/coconut .

    # Some cleanup
    sudo apt-get autoremove -y

    # Silence error message from missing file
    touch /home/${user}/.Xauthority

    # Provisioning runs as root; we want files to belong to '${user}'
    chown -R ${user}:${user} /home/${user}

  SHELL
end
