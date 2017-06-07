# @summary manages a launcher script for a borgbackup job
#
# @param path the path(s) to backup
# @param exclude the path(s) to exclude
# @param repository where to backup to
# @param 
# @author Bernhard Frauendienst <puppet@nospam.obeliks.de>
#
define borgbackup::job (
  String $archive_name                              = "${title}-{fqdn}-{now}",
  Variant[String, Array[String]] $path,
  Optional[Variant[String, Array[String]]] $exclude = undef,
  Struct[{
    url                  => String,
    Optional[passphrase] => String,
    Optional[encryption] => Enum['none', 'repokey', 'keyfile'],
  }] $repository,
  Optional[String] $ssh_identity                    = undef,
  Optional[Struct[{
    Optional[within] => String,
    Optional[hourly] => Integer,
    Optional[daily] => Integer,
    Optional[weekly] => Integer,
    Optional[monthly] => Integer,
    Optional[yearly] => Integer,
  }]] $retention_policy                             = undef,
  String $prune_prefix                              = "${title}-",
  $ensure           = 'present',
  $user             = undef,
  String $launcher_dir       = lookup('borgbackup::job::launcher_dir'),
  String $borgbackup_command = lookup('borgbackup::job::borgbackup_command'),
) {
  if $repository[encryption] != 'none' and !$repository[passphrase] {
    fail("Encryption mode ${repository[encryption]} requires a passphrase.")
  }

  $launcher_file = "${launcher_dir}/${name}.sh"

  file { $launcher_file:
    owner   => 'root',
    group   => 'root',
    mode    => '0550',
    ensure  => $ensure,
    content => epp('borgbackup/borgbackup_launcher.epp', {
      paths        => any2array($path),
      archive_name => $archive_name,
      excludes     => any2array($exclude),
      repository   => $repository,
      ssh_identity => $ssh_identity,
      prune_prefix => $prune_prefix,
      retention_policy    => $retention_policy,
      borg_init_options   => {},
      borg_create_options => {},
      borg_prune_options  => {},
    })
  }
}
