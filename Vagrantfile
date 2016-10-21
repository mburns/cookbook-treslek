# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = '2'.freeze

Vagrant.require_version '>= 1.5.0'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.hostname = 'treslek-berkshelf'
  config.vm.box = 'chef/ubuntu-14.04'
  config.vm.box_url = 'https://vagrantcloud.com/chef/ubuntu-14.04/version/1/provider/virtualbox.box'
  config.vm.network :private_network, type: 'dhcp'
  config.omnibus.chef_version = :latest
  config.berkshelf.enabled = true

  config.vm.provision :chef_solo do |chef|
    chef.run_list = [
      'recipe[treslek::default]'
    ]
  end
end
