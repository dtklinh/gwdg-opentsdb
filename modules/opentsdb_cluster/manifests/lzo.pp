class opentsdb_cluster::lzo {
  include opentsdb_cluster::hadoop
  include opentsdb_cluster::hbase

  package { ["liblzo2-dev", "ant", "git"]: ensure => installed, }

  # #download
  exec { "download_lzo":
    command => "git clone https://github.com/dtklinh/hadoop-lzo; mv  hadoop-lzo lzo",
    cwd     => $opentsdb_cluster::lzo_parent_dir,
    creates => $opentsdb_cluster::lzo_working_dir,
    path    => $::path,
    require => [User["gwdg"], Package["git"]],
  }

  file { "reown_lzo":
    path    => $opentsdb_cluster::lzo_working_dir,
    backup  => false,
    recurse => true,
    owner   => "${opentsdb_cluster::myuser_name}",
    group   => "${opentsdb_cluster::mygroup_name}",
    require => [Exec["download_lzo"], User["gwdg"]],
  }
  #  $my_var = "export CFLAGS=\\”-m64\\”"
  $my_var = template("opentsdb_cluster/lzo/var.erb")

  exec { "add_var":
    #    command   => "echo '${my_var}' >> /home/${opentsdb_cluster::myuser_name}/.bashrc",
    command => "echo '${my_var}' >> /etc/environment",
    user    => $opentsdb_cluster::myuser_name,
    path    => $::path,
    unless  => "grep -q 'CFLAGS' /etc/environment",
    require => File["reown_lzo"],
  }

  exec { "exec_addvar":
    command => "bash -c 'source /etc/environment'",
    user    => $opentsdb_cluster::myuser_name,
    path    => $::path,
    require => Exec["add_var"],
  }

  # #build up
  exec { "build_lzo":
    command => "ant compile-native tar",
    cwd     => $opentsdb_cluster::lzo_working_dir,
    user    => $opentsdb_cluster::myuser_name,
    creates => "${opentsdb_cluster::lzo_working_dir}/build",
    require => [File["reown_lzo"], Package["ant"], Package["liblzo2-dev"], Exec["exec_addvar"]],
    path    => $::path,
  }

  # # copy file jar and native
  file { "jar_file_hadoop":
    path    => "${opentsdb_cluster::hadoop_working_dir}/lib/hadoop-lzo-0.4.15.jar",
    source  => "${opentsdb_cluster::lzo_working_dir}/build/hadoop-lzo-0.4.15.jar",
    owner   => $opentsdb_cluster::myuser_name,
    group   => $opentsdb_cluster::mygroup_name,
    require => [Exec["build_lzo"], File["reown_hadoop"]],
  }

  file { "jar_file_hbase":
    path    => "${opentsdb_cluster::hbase_working_dir}/lib/hadoop-lzo-0.4.15.jar",
    source  => "${opentsdb_cluster::lzo_working_dir}/build/hadoop-lzo-0.4.15.jar",
    owner   => $opentsdb_cluster::myuser_name,
    group   => $opentsdb_cluster::mygroup_name,
    require => [Exec["build_lzo"], File["reown_hbase"]],
  }

  # # copy native
  file { "libgplcompression_hadoop":
    path    => "${opentsdb_cluster::hadoop_working_dir}/lib/native/${opentsdb_cluster::os_structure}",
    recurse => true,
    source  => [
      "${opentsdb_cluster::lzo_working_dir}/build/hadoop-lzo-0.4.15/lib/native/${opentsdb_cluster::os_structure}",
      "${opentsdb_cluster::hadoop_working_dir}/lib/native/${opentsdb_cluster::os_structure}"],
    owner   => $opentsdb_cluster::myuser_name,
    group   => $opentsdb_cluster::mygroup_name,
    require => [File["reown_hadoop"], Exec["build_lzo"]],
  }
  
  file { "libgplcompression_hbase":
    path    => "${opentsdb_cluster::hbase_working_dir}/lib/native/${opentsdb_cluster::os_structure}",
    recurse => true,
    source  => [
      "${opentsdb_cluster::lzo_working_dir}/build/hadoop-lzo-0.4.15/lib/native/${opentsdb_cluster::os_structure}",
      "${opentsdb_cluster::hbase_working_dir}/lib/native/${opentsdb_cluster::os_structure}"],
    owner   => $opentsdb_cluster::myuser_name,
    group   => $opentsdb_cluster::mygroup_name,
    require => [File["reown_hbase"], Exec["build_lzo"]],
  }

}

