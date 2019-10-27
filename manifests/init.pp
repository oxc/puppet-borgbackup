# @summary this class allows you to install the BorgBackup system 
#   and configure backup cron jobs
# 
# @example
#   include borgbackup
#
# @param packages_install  whether to install the borgbackup package
# @param purge_unmanaged   whether files in $config_path not managed by this module should be purged
# @param jobs              hash of job entres, useful for creating jobs from hiera
#
# @author Bernhard Frauendienst <puppet@nospam.obeliks.de>
#
class borgbackup (
  Boolean $packages_install        = true,

  Boolean $purge_unmanaged         = true,

  Hash $jobs = {},
  Hash $crons = {},
) {

  if ($packages_install) {
    package { 'borgbackup':
      ensure => 'present',
      name   => 'borgbackup',
    }
  }

  $config_dir = lookup('borgbackup::job::config_dir')
  if ($config_dir) {
    file { $config_dir:
      ensure => 'directory',
      owner  => 'root',
      group  => '0',
      before => File[$launcher_dir],
    }
  }

  $launcher_dir = lookup('borgbackup::job::launcher_dir')
  file { $launcher_dir:
    ensure  => 'directory',
    recurse => $purge_unmanaged,
    purge   => $purge_unmanaged,
  }

  create_resources('borgbackup::job', $jobs)
  create_resources('borgbackup::cron', $crons)
}
