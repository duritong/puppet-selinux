# centos specific setroubleshoot-server things
class selinux::setroubleshoot::centos {
  package{'setroubleshoot-server':
    ensure => present,
  }

  if $::lsbmajdistrelease < 6 {
    service{'setroubleshoot':
      ensure  => running,
      enable  => true,
      require => Package['setroubleshoot-server'],
    }
  }
}
