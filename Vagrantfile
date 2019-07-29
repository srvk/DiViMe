# coding: utf-8
# -*- mode: ruby -*-
# vi: set ft=ruby

Vagrant.configure("2") do |config|

  # Default provider is VirtualBox!
  # If you want AWS, you need to populate and run e.g.
  #   . aws.sh; vagrant up --provider aws
  # Make sure you don't check in aws.sh (maybe make a copy with your "secret" data)
  # Before that, do
  #   vagrant plugin install vagrant-aws vagrant-sshfs

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
    vbox.memory = 2048
  end

  config.vm.provider "docker" do |d, override|
    #     d.image = 'ubuntu:14.04'
    d.image = 'tknerr/baseimage-ubuntu:14.04'
    d.remains_running = true
    d.has_ssh = true
    # This needs to be set on a Mac - not sure if it causes problems on other architectures?
    d.force_host_vm = true
    # (too late?)
    override.vm.synced_folder ".", "/vagrant", owner: "vagrant", group: "vagrant"
    #, :mount_options => ["dmode=777", "fmode=777"]
  end

  config.vm.provider "aws" do |aws, override|
    aws.tags["Name"] = "Diarization VM"
    aws.ami = "ami-663a6e0c" # Ubuntu ("Trusty") Server 14.04 LTS AMI - US-East region
    aws.instance_type = "m3.xlarge"

    override.vm.synced_folder ".", "/vagrant", type: "sshfs", ssh_username: ENV['USER'], ssh_port: "22", prompt_for_password: "true"

    override.vm.box = "http://speech-kitchen.org/dummy.box"

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

  config.vm.provision "bootstrap-system", type: "shell", run: "once" do |s|
    s.path = "conf/bootstrap-system.sh"
  end

  config.vm.provision "bootstrap-user", type: "shell", run: "once", privileged: false do |s|
    s.path = "conf/bootstrap-user.sh"
  end

  config.vm.provision "update", type: "shell", run: "never" do |s|
    # This needs to be completed
    s.path = "conf/update.sh"
  end
    
end
