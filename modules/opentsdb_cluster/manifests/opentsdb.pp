class opentsdb_cluster::opentsdb{
  include opentsdb_cluster::hbase
  ## download package
  package{["dh-autoreconf","git","gnuplot"]:
    ensure  => installed,
  }
  exec{"download_opentsdb":
    command => "git clone git://github.com/stumbleupon/opentsdb.git",
    cwd     => $opentsdb_cluster::opentsdb_parent_dir,
    creates => "${opentsdb_cluster::opentsdb_parent_dir}/opentsdb",
    user    => $opentsdb_cluster::myuser_name,
    require => [Package["dh-autoreconf"],Package["git"],Package["gnuplot"], User["gwdg"]],
    path      => $::path,
  }
  ## reown
  file{"reown_opentsdb":
    path  => "${opentsdb_cluster::opentsdb_working_dir}",
    backup => false,
    recurse => true,
    owner   => "${opentsdb_cluster::myuser_name}",
    group   => "${opentsdb_cluster::mygroup_name}",
    require => Exec["download_opentsdb"],
  }
  ## build opentsdb
  exec{"build_opentsdb":
    command   => "build.sh",
    cwd       => "${opentsdb_cluster::opentsdb_working_dir}",
    creates   => "${opentsdb_cluster::opentsdb_working_dir}/build",
    user      => $opentsdb_cluster::myuser_name,
    require   => [File["reown_opentsdb"],Service["hbase"]],
    path      => "${path}:${opentsdb_cluster::opentsdb_working_dir}",
  }
  ## create table
  exec{"create_table":
    command   => "env COMPRESSION=${opentsdb_cluster::compression} HBASE_HOME=${opentsdb_cluster::hbase_working_dir} ./src/create_table.sh",
    cwd       => $opentsdb_cluster::opentsdb_working_dir,
    user      => $opentsdb_cluster::myuser_name,
    creates   => "${opentsdb_cluster::opentsdb_working_dir}/create_table.txt",
    require   => Exec["build_opentsdb"],
    path      => $::path,
  }
  file{"${opentsdb_cluster::opentsdb_working_dir}/create_table.txt":
    ensure    => file,
    require    => Exec["create_table"],
  }
  ## run opentsdb service
  file{"opentsdb_service":
    path    => "${opentsdb_cluster::service_path}/opentsdb",
    content => template("opentsdb_cluster/opentsdb/service/opentsdb.erb"),
    ensure  => present,
    require => File["reown_opentsdb"],
  }
  
#  service{"opentsdb":
#    ensure  => running,
#    require => [File["opentsdb_service"], Service["hbase"]],
#    subscribe => File["opentsdb_service"],
#  }
}


