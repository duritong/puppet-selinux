# remove setroubleshoot-server on centos
class selinux::setroubleshoot::disable::centos inherits selinux::setroubleshoot::centos {
  if $::lsbmajdistrelease < 6 {
    Service['setroubleshoot']{
      ensure  => stopped,
      enable  => false,
      require => undef,
      before  => Package['setroubleshoot-server'],
    }
  }

  exec{'yum remove setroubleshoot-plugins':
    onlyif => 'rpm -qi setroubleshoot-plugins',
    before => Package['setroubleshoot-server'],
  }
  Package['setroubleshoot-server']{
    ensure => absent,
  }
}
