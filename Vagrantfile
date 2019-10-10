# -*- mode: ruby -*-
# vi: set ft=ruby :

pub_key = `cat ~/.ssh/id_rsa.pub`

Vagrant.configure("2") do |config|

  config.vm.box = "geerlingguy/centos7"

  config.vm.define :default do |node|
    node.vm.network "private_network", ip: "192.168.33.10"
    node.vm.provision "shell", inline: <<-SHELL
    echo "#{pub_key}" >> /home/vagrant/.ssh/authorized_keys
    sudo service network restart
    SHELL
  end

  config.vm.define :node01 do |node|
    node.vm.network "private_network", ip: "192.168.33.20"
    node.vm.provision "shell", inline: <<-SHELL
    echo "#{pub_key}" >> /home/vagrant/.ssh/authorized_keys
    sudo service network restart
    SHELL
  end
end

