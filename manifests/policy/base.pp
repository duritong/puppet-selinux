# basic things needed to deploy selinux policies
class selinux::policy::base {
  $dir = '/var/lib/puppet/selinux_modules'
  file{$dir:
    ensure => directory,
    owner  => root,
    group  => 0,
    mode   => '0600';
  }
}
