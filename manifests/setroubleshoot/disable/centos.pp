class selinux::setroubleshoot::disable::centos inherits selinux::setroubleshoot::centos {
  Service['setroubleshoot']{
    ensure => stopped,
    enable => false,
  }  
}
