class selinux::setroublehoot::disable::centos inherits selinux::setroubleshoot::centos {
  Service['setroubleshoot']{
    ensure => stopped,
    enable => false,
  }  
}
