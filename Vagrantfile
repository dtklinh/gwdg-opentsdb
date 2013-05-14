# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  
   
   config.vm.define :masterdb do |master_config|
   		master_config.vm.box = "masterdb"
   		master_config.vm.box_url = "https://github.com/downloads/roderik/VagrantQuantal64Box/quantal64.box"
   		master_config.vm.network :hostonly, "192.168.33.60"
   		master_config.vm.customize ["modifyvm", :id, "--memory", 2048]
   		master_config.vm.host_name = "masterdb"
#   		master_config.hosts.aliases = ["masterdb.top.gwdg.de", "puppet"]
   		master_config.vm.share_folder  "module", "/etc/puppet/modules", "~/workspace/mypuppetdb/modules"
   		master_config.vm.forward_port 8080, 8080
  # 		master_config.vm.forward_port 8081, 8081
   		master_config.vm.forward_port 8082, 8082
 #  		master_config.vm.share_folder = 
 #  		master_config.vm.provision :shell, :inline => "dpkg -l | grep puppetlabs-release 1>/dev/null ; if [ $? == 1 ];then wget https://apt.puppetlabs.com/puppetlabs-release-quantal.deb && dpkg -i puppetlabs-release-quantal.deb && apt-get update && apt-get install -y puppetmaster puppet facter -t puppetlabs;fi"
 #  		master_config.vm.provision :shell, :inline => "apt-get update -y ; apt-get upgrade"
 #  		master_config.vm.provision :shell, :inline => "if [ ! -d /etc/puppet ];then mkdir /etc/puppet;fi; cp /etc/puppet/files/fileserver.conf /etc/puppet/files/hiera.yaml /etc/puppet"
   		master_config.vm.provision :puppet, :options => ["--debug", "--verbose", "--summarize"] do |puppet|
   			puppet.manifests_path = "manifests"
        	puppet.manifest_file  = "site.pp"
        	puppet.module_path    = "modules"
        	puppet.pp_path        = "/etc/puppet"
  #      	puppet.facter         = { "domain" => "puppet.test" }
   		end
   end
   
   config.vm.define :slavedb do |slave_config|
   		slave_config.vm.box = "slavedb"
   		slave_config.vm.box_url = "https://github.com/downloads/roderik/VagrantQuantal64Box/quantal64.box"
   		slave_config.vm.network :hostonly, "192.168.33.65"
   		slave_config.vm.host_name = "slavedb"
#   		slave_config.hosts.aliases = ["slavedb.top.gwdg.de", "agent"]
#   		slave_config.vm.provision :shell, :inline => "dpkg -l | grep puppetlabs-release 1>/dev/null ; if [ $? == 1 ];then wget https://apt.puppetlabs.com/puppetlabs-release-quantal.deb && dpkg -i puppetlabs-release-quantal.deb && apt-get update && apt-get install -y puppet facter -t puppetlabs;fi"
#		config.vm.provision :shell, :inline => "puppet resource host masterdb ip='192.168.33.60'"
#   		slave_config.vm.provision :puppet_server, :options => ["--debug", "--verbose", "--summarize", "--no-daemonize", "--onetime"] do |puppet|
		slave_config.vm.provision :puppet_server, :options => ["--debug", "--verbose", "--summarize"] do |puppet|
      		puppet.puppet_server = "masterdb"
      		puppet.puppet_node	 = "slavedb"
    	end
   end

  
end
