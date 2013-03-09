# deploys and installs and selinux policy file
#
# Parameters:
#
#  * ensure: *present*/absent
#  * fc_file: true/*false* - Does this policy have a fc file?
define selinux::policy(
  $ensure     = 'present',
  $fc_file    = false,
  $te_source  =  [
    "puppet:///modules/site_selinux/policies/${name}/${::fqdn}/${name}.te",
    "puppet:///modules/site_selinux/policies/${name}/${name}.te",
  ],
  $fc_source  = [
    "puppet:///modules/site_selinux/policies/${name}/${::fqdn}/${name}.fc",
    "puppet:///modules/site_selinux/policies/${name}/${name}.fc",
  ]
) {

  require selinux::policy::base
  file{"${selinux::policy::base::dir}/${name}": }
  if ($ensure == 'present') {
    File["${selinux::policy::base::dir}/${name}"]{
      ensure => directory,
      owner  => root,
      group  => 0,
      mode   => '0600',
    }

    File{
      owner  => root,
      group  => 0,
      mode   => '0600',
      notify => Exec["make_${name}_policy"],
    }
    file{
      "${selinux::policy::base::dir}/${name}/${name}.te":
        source => $te_source;
      "${selinux::policy::base::dir}/${name}/${name}.fc":;
      "${selinux::policy::base::dir}/${name}/Makefile":
        ensure => link,
        target => '/usr/share/selinux/devel/Makefile';
    }
    if $fc_file {
      File["${selinux::policy::base::dir}/${name}/${name}.fc"]{
        source => $fc_source,
      }
    } else {
      File["${selinux::policy::base::dir}/${name}/${name}.fc"]{
        ensure => present,
      }
    }

    exec{
      "make_${name}_policy":
        command     => 'make',
        refreshonly => true,
        cwd         => "${selinux::policy::base::dir}/${name}",
        notify      => Exec["load_${name}_policy"];
      "load_${name}_policy":
        command     => "semodule -i ${selinux::policy::base::dir}/${name}/${name}.pp",
        refreshonly => true;
    }
  } else {
    exec{"remove_${name}_policy":
      command => "semodule -r ${name}",
      onlyif  => "semodule -l | grep -qE '^${name}'";
    }
    File["${selinux::policy::base::dir}/${name}"]{
      ensure  => absent,
      recurse => true,
      purge   => true,
      force   => true,
    }
  }
}
