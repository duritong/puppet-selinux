class selinux::setroubleshoot {
  case $::operatingsystem {
    centos: { include selinux::setroubleshoot::centos }
  }
}
