# remove setroubleshoot-server on centos
class selinux::setroubleshoot::disable::centos {
  if $::lsbmajdistrelease < 6 {
    service{'setroubleshoot':
      ensure  => stopped,
      enable  => false,
      require => undef,
      before  => Exec['remove-setroubleshoot-server'];
    }
  }

  exec{'remove-setroubleshoot-server':
    command => 'yum -y remove setroubleshoot-plugins',
    onlyif  => 'rpm -qi setroubleshoot-plugins',
  }
}
