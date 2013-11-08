class sudo (
  $package           = 'sudo',
  $package_source    = undef,
  $package_ensure    = 'present',
  $package_manage    = 'true',
  $config_dir        = '/etc/sudoers.d',
  $config_dir_group  = 'root',
  $config_dir_purge  = 'true',
  $sudoers           = undef,
  $sudoers_manage    = 'false',
) {

  if type($package_manage) == 'string' {
    $real_package_manage = str2bool($package_manage)
  } else {
    $real_package_manage = $package_manage
  }
  if $real_package_manage == true {
    package { 'sudo-package':
       ensure => $package_ensure,
       name   => $package,
       source => $package_source,
      }
    }

  if type($sudoers_manage) == 'string' {
    $real_sudoers_manage = str2bool($sudoers_manage)
  } else {
    $real_sudoers_manage = $sudoers_manage
  }
  if $sudoers_manage == true {
    if type($config_dir_purge) == 'string' {
      $real_config_dir_purge = str2bool($config_dir_purge)
    } else {
      $real_config_dir_purge = $config_dir_purge
    }
    file { $config_dir:
      ensure => $dir_ensure,
      owner => 'root',
      group => $config_dir_group,
      mode => '0550',
      recurse => $real_config_dir_purge,
      purge => $real_config_dir_purge,
    }

    # Only works with sudo >= 1.7.2
    if $sudoers != undef {
      create_resources('sudo::conf',$sudoers)
    }
  }
}

define sudo::conf (
  $ensure = present,
  $priority = 10,
  $content = undef,
  $source = undef,
  $config_dir = $sudo::config_dir
  $config_dir_group = $sudo::config_dir_group
) {
  file { "${priority}_${name}":
    ensure => $ensure,
    path => "${config_dir}${priority}_${name}",
    owner => 'root',
    group => $config_dir_group,
    mode => '0440',
    source => $source,
    content => $content,
  }
}


