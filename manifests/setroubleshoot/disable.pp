class selinux::setroubleshoot::disable {
  case $::operatingsystem {
    centos: { include selinux::setroubleshoot::disable::centos }
  }
}
