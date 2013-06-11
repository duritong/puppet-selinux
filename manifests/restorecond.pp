# manages restorecond service
class selinux::restorecond {
  service{'restorecond':
    ensure => running,
    enable => true,
  }
}
