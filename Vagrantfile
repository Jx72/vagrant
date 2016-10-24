# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

$base_box = "centos/7"

$script = <<SCRIPT

echo "Add the EPEL repository"
yum install -y epel-release >> /tmp/centos-init.log 2>&1
echo "Update the CentOS 7 system..."
yum update -y >> /tmp/centos-init.log 2>&1

SCRIPT

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = $base_box

  config.ssh.insert_key = false

  config.vm.provision "shell", inline: $script

end
