class selinux::setroubleshoot::centos {
  package{'setroubleshoot-server':
    ensure => present,
  }

  service{'setroubleshoot':
    ensure => running,
    enable => true,
    require => Package['setroubleshoot-server'],
  }
}
