# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  # Every Vagrant virtual environment requires a box to build off of.
  #config.vm.box = "CentOS 6.3 x86_64 + Chef 10.14.2 + VirtualBox 4.1.22 (with guest additions)"
  config.vm.box = "CentOS 6.4 x86_64 Minimal (VirtualBox Guest Additions 4.2.16, Chef 11.6.0, Puppet 3.2.3)"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  #config.vm.box_url = "https://s3.amazonaws.com/itmat-public/centos-6.3-chef-10.14.2.box"
  config.vm.box_url = "http://developer.nrel.gov/downloads/vagrant-boxes/CentOS-6.4-x86_64-v20130731.box"

  # Boot with a GUI so you can see the screen. (Default is headless)
  #config.vm.boot_mode = :gui

  # enable audio drivers on VM settings
  #config.vm.provider :virtualbox do |vb|
  #  vb.customize ["modifyvm", :id, '--audio', 'oss', '--audiocontroller', 'hda'] # choices: hda sb16 ac97
  #end



  # Assign this VM to a host-only network IP, allowing you to access it
  # via the IP. Host-only networks can talk to the host machine as well as
  # any other machines on the same network, but cannot be accessed (through this
  # network interface) by any external networks.
  # config.vm.network :hostonly, "192.168.33.10"

  # Assign this VM to a bridged network, allowing you to connect directly to a
  # network using the host's network device. This makes the VM appear as another
  # physical device on your network.
  # config.vm.network :bridged

  # Forward a port from the guest to the host, which allows for outside
  # computers to access the VM, whereas host only networking does not.
  # config.vm.forward_port 80, 8080
  # SIP 5060 - 5090
  config.vm.forward_port 80, 9080
  config.vm.forward_port 443, 9443
  config.ssh.port = 2222

  # Share an additional folder to the guest VM. The first argument is
  # an identifier, the second is the path on the guest to mount the
  # folder, and the third is the path on the host to the actual folder.
  # config.vm.share_folder "v-data", "/vagrant_data", "../data"
  #config.vm.share_folder "artifacts", "/vagrant_artifacts", "artifacts"

  # Enable provisioning with Puppet stand alone.  Puppet manifests
  # are contained in a directory path relative to this Vagrantfile.
  # You will need to create the manifests directory and a manifest in
  # the file CentOS 6.3 x86_64 + Chef 10.14.2 + VirtualBox 4.1.22 (with guest additions).pp in the manifests_path directory.
  #
  # An example Puppet manifest to provision the message of the day:
  #
  # # group { "puppet":
  # #   ensure => "present",
  # # }
  # #
  # # File { owner => 0, group => 0, mode => 0644 }
  # #
  # # file { '/etc/motd':
  # #   content => "Welcome to your Vagrant-built virtual machine!
  # #               Managed by Puppet.\n"
  # # }
  #

  Vagrant.configure("2") do |config|
    config.vm.provider :virtualbox do |vb|
      # Don't boot with headless mode
      vb.gui = true
    
      vb.customize ["modifyvm", :id, '--audio', 'oss', '--audiocontroller', 'hda'] # choices: hda sb16 ac97
   end
  end


  config.vm.provision :shell do |shell|
    shell.inline = "mkdir -p /etc/puppet/modules;
                    puppet module install puppetlabs-firewall;
                    puppet module install puppetlabs/stdlib"
  end


  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "manifests"
    puppet.manifest_file  = "default.pp"
  end

end

