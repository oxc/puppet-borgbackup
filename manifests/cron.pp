# @summary manages a cron job running one or multiple borgbackup jobs
#
# @param jobs the list of jobs or a single job name, defaults to the resource title
# @param 
# @author Bernhard Frauendienst <puppet@nospam.obeliks.de>
#
define borgbackup::cron (
  Variant[String, Array[String]] $jobs = $title,
  $ensure           = 'present',
  $hour             = undef,
  $minute           = undef,
  $month            = undef,
  $monthday         = undef,
  $weekday          = undef,
  $user             = undef,
  String $launcher_dir = lookup('borgbackup::job::launcher_dir'),
) {
  $command = join(any2array($jobs).map |$job| { "${launcher_dir}/${job}.sh" }, ' && ')

  cron { "borgbackup cron ${title}":
    ensure   => $ensure,
    command  => $command,
    hour     => $hour,
    minute   => $minute,
    month    => $month,
    monthday => $monthday,
    weekday  => $weekday,
    user     => $user,
  }
}
