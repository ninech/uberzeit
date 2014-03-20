Vagrant.configure("2") do |config|
  config.vm.define "production" do |production|
    production.vm.box           = "precise64"
    production.vm.box_url       = "http://files.vagrantup.com/precise64.box"
    production.vm.hostname      = "uberzeit-production"
    production.vm.network       "private_network", ip: "10.10.10.39"
    production.vm.synced_folder ".", "/home/uberzeit"


    production.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--memory", 768]
    end
  end
end
