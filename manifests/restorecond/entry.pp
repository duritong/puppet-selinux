# manages an entry in restorecond
define selinux::restorecond::entry(
  $ensure = 'present'
){
  include selinux::restorecond
  file_line{"restorecond_${name}":
    ensure => $ensure,
    path   => '/etc/selinux/restorecond.conf',
    line   => $name,
    notify => Service['restorecond'],
  }
}
