# basic things needed to deploy selinux policies
class selinux::policy::base {
  $dir = '/var/lib/puppet/selinux_policies'
  if $::lsbmajdistrelease == 5 {
    package{'selinux-policy-devel':
      ensure => installed,
      before => File[$dir],
    }
  }
  
  file{$dir:
    ensure => directory,
    owner  => root,
    group  => 0,
    mode   => '0600';
  } 
}
