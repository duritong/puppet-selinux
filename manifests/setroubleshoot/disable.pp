class selinux::setroublehoot::disable {
  case $operatingsystem {
    centos: { include selinux::setroublehoot::disable::centos }
  }  
}
