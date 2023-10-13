# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.hostname = "ubuntu"

  config.vm.provider :docker do |docker, override|
    override.vm.box = nil
    docker.image = "rofrano/vagrant-provider:ubuntu"
    docker.remains_running = true
    docker.has_ssh = true
    docker.privileged = true
    docker.volumes = ["/sys/fs/cgroup:/sys/fs/cgroup:rw"]
    docker.create_args = ["--cgroupns=host"]
    # Uncomment to force arm64 for testing images
    #docker.create_args = ['--platform=linux/arm64']
  end
    
  # # Master Node Configuration
  config.vm.define "master" do |master|
    config.vm.hostname = "master"
    config.vm.network "private_network", type: "dhcp"
      # docker.remains_running = true
  end

  # # Slave Node Configuration
  config.vm.define "slave" do |slave|
    config.vm.hostname = "slave"
     #config.vm.network "private_network", type: "dhcp"
      # docker.remains_running = true
  end
end
