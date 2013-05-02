node "masterdb" {
  file { "/etc/puppet/autosign.conf":
    ensure  => present,
    content => '*',
  }

  host { "masterdb":
    name         => "masterdb",
    host_aliases => ["masterdb.top.gwdg.de", "puppet"],
    ip           => '192.168.33.60',
    ensure       => present,
  }

  host { "slavedb":
    name         => "slavedb",
    host_aliases => ["slavedb.top.gwdg.de", "agent"],
    ip           => '192.168.33.65',
    ensure       => present,
  }

  ini_setting { "puppet.conf":
    path              => "/etc/puppet/puppet.conf",
    section           => "master",
    setting           => "dns_alt_names",
    value             => "masterdb",
    key_val_separator => "=",
  }

  ini_setting { "puppet_default":
    path              => "/etc/default/puppet",
    section           => "",
    setting           => 'START',
    value             => 'yes',
    key_val_separator => '=',
  }
  ini_setting{"stoteconfig":
    ensure  => absent,
    path    => "/etc/puppet/puppet.conf",
    section => "master",
    setting => "storeconfigs",
    value   => "true",
    key_val_separator => "=",
  }
  ini_setting{"stoteconfig_new":
    ensure  => present,
    path    => "/etc/puppet/puppet.conf",
    section => "main",
    setting => "storeconfigs",
    value   => "true",
    key_val_separator => "=",
  }

  ################

  class { 'puppetdb':
    database => 'embedded',
  }

  class { 'puppetdb::master::config':
    puppetdb_server => 'masterdb',
    puppetdb_port   => 8081,
  }

  # ################# exported resource ######################
#  @@file { "/etc/puppet/hello2.txt":
#    path    => "/etc/puppet/hello2.txt",
#    ensure  => present,
#    content => "hello ${hostname} \n",
#    tag     => 'linh',
#    require => Ini_setting["stoteconfig_new"],
    
 # }
 include mytest
#  File <<| tag == 'linh' |>>
#  Ini_setting <<| tag == "myhostname" |>>
  File_line <<| tag == "gwdg" |>>
}

node "slavedb" {
#  @@file { "/etc/puppet/hello.txt":
#    path    => "/etc/puppet/hello.txt",
#    ensure  => present,
#    content => "hello ${hostname} \n",
#    tag     => 'conny',
#  }
  include mytest
#  File <<| tag == "linh" |>>
  File_line <<| tag == "gwdg" |>>
  
  host { "masterdb":
    name         => "masterdb",
    host_aliases => ["masterdb.top.gwdg.de", "puppet"],
    ip           => '192.168.33.60',
    ensure       => present,
  }

#  file { "/etc/puppet/shit.txt":
#    ensure  => present,
#    content => "hello world \n",
#  }

  host { "slavedb":
    name         => "slavedb",
    host_aliases => ["slavedb.top.gwdg.de", "agent"],
    ip           => '192.168.33.65',
    ensure       => present,
  }

  ini_setting { "puppet.conf":
    path              => "/etc/puppet/puppet.conf",
    section           => "agent",
    setting           => "server",
    value             => "masterdb",
    key_val_separator => "=",
  }

  ini_setting { "puppet_default":
    path              => "/etc/default/puppet",
    section           => "",
    setting           => 'START',
    value             => 'yes',
    key_val_separator => '=',
  }
}
