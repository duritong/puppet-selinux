#
# selinux module
#
# Copyright 2008, admin(at)immerda.ch
# Copyright 2008, Puzzle ITC GmbH
# Marcel Härry haerry+puppet(at)puzzle.ch
# Simon Josi josi+puppet(at)puzzle.ch
#
# This program is free software; you can redistribute 
# it and/or modify it under the terms of the GNU 
# General Public License version 3 as published by 
# the Free Software Foundation.
#

class selinux {

    case $operatingsystem {
            centos: { include selinux::centos }
    }

    file { "/etc/selinux/local":
        ensure => directory,
        owner  => "root",
        group  => "root",
        mode   => "0750",
    }

    file { '/usr/local/sbin/s0':
        owner => "root",
        group => "0",
        mode  => 700,
        ensure => present,
	    source => "puppet://$server/selinux/sbin/s0",
    }
    file { '/usr/local/sbin/s1':
        owner => "root",
        group => "0",
        mode  => 700,
        ensure => present,
	    source => "puppet://$server/selinux/sbin/s1",
    }

    exec{"SELinux-Relabel":
       command => $operatingsystem ? {
                     debian => "rlpkg -a",
                     centos => "/bin/true"
       },
       refreshonly => true,
    }

    if $use_munin {
        include munin::plugins::selinux
    }
}

class selinux::centos {
    # yum install selinux-policy-strict setools
    package { 'selinux-policy-strict':
        name => 'selinux-policy-strict',
        ensure => present,
    }
    package { 'setools':
        name => 'setools',
        ensure => present,
    }
}

define selinux::module () {
    include selinux
    include make

    file { "/etc/selinux/local/$name":
        ensure => directory,
        owner  => "root",
        group  => "root", mode   => "0750",
        require => File["/etc/selinux/local"],
    }

    file { "/etc/selinux/local/$name/Makefile":
        ensure  => present,
        owner   => "root",
        group   => "root",
        mode    => "0750",
	    source =>   [
                    "puppet://$server/files/selinux/${fqdn}/${name}/Makefile",
                    "puppet://$server/files/selinux/${name}/Makefile",
                    "puppet://$server/selinux/module/Makefile",
                    "puppet://$server/selinux/Makefile"
                    ],
        require => File["/etc/selinux/local/$name"],
    }

    file { "/etc/selinux/local/$name/${name}.te": 
    	ensure => file, 
	    owner => root, 
    	group => root, 
	    mode => 640,
        source => [ 
                    "puppet://$server/files/selinux/${fqdn}/${name}/${name}.te",
                    "puppet://$server/files/selinux/${fqdn}/${name}.te",
                    "puppet://$server/files/selinux/${name}/${name}.te",
                    "puppet://$server/files/selinux/${name}.te",
                    "puppet://$server/selinux/module/${name}/${name}.te",
                    "puppet://$server/selinux/module/${name}.te" 
                  ],
        notify => Exec["SELinux-${name}-Update"],
        require => File["/etc/selinux/local/$name"],
    }

    file { "/etc/selinux/local/${name}/${name}.fc": 
    	ensure => file, 
	    owner => root, 
    	group => root, 
	    mode => 640,
        source => [ 
                    "puppet://$server/files/selinux/${fqdn}/${name}/${name}.fc",
                    "puppet://$server/files/selinux/${fqdn}/${name}.fc",
                    "puppet://$server/files/selinux/${name}/${name}.fc",
                    "puppet://$server/files/selinux/${name}.fc",
                    "puppet://$server/selinux/module/${name}/${name}.fc",
                    "puppet://$server/selinux/module/${name}.fc" 
                  ],
        notify => [ Exec["SELinux-${name}-Update"], Exec["SELinux-Relabel"] ],
        require => File["/etc/selinux/local/$name"],
    }

    file { "/etc/selinux/local/${name}/${name}.if": 
    	ensure => file, 
	    owner => root, 
    	group => root, 
	    mode => 640,
        source => [ 
                    "puppet://$server/files/selinux/${fqdn}/${name}/${name}.if",
                    "puppet://$server/files/selinux/${fqdn}/${name}.if",
                    "puppet://$server/files/selinux/${name}/${name}.if",
                    "puppet://$server/files/selinux/${name}.if",
                    "puppet://$server/selinux/module/${name}/${name}.if",
                    "puppet://$server/selinux/module/${name}.if" 
                  ],
        notify => Exec["SELinux-${name}-Update"],
        require => File["/etc/selinux/local/$name"],
    }

    exec { "SELinux-${name}-Update":
        command         => "/usr/bin/make -C /etc/selinux/local/${name} -f /etc/selinux/local/${name}/Makefile load",
        refreshonly => true,
        require     => File["/etc/selinux/local/${name}/Makefile"],
        before => Exec["SELinux-Relabel"],
        return => 2,
    }

    # should load the module again, if "accidently" removed with semodule -r modulename
    exec { "SELinux-${name}-Update_indep":
        command         => "/usr/bin/make -C /etc/selinux/local/${name} -f /etc/selinux/local/${name}/Makefile load",
        creates     => File["/etc/selinux/${selinux_mode}/modules/active/modules/${name}.pp"],
        before => Exec["SELinux-Relabel"],
        return => 2,
    }

}

# location = location of the pp (eg. /usr/share/selinux/strict/logrotate.pp)
define selinux::loadmodule ($location = '',$ensure='present', $requireabsenceof='') {
    $real_location = $location ? {
        '' => "/usr/share/selinux/${selinux_mode}/${name}.pp",
        default => $location
    }

    case $ensure {
    present: {
        # installs the module, if it is no already installed
        exec { "SELinux-${name}-Install":
            command     => "/usr/sbin/semodule -i ${real_location}",
		    creates	    => "/etc/selinux/${selinux_mode}/modules/active/modules/${name}.pp",
        }

        if $require {
            Exec["SELinux-${name}-Install"]{
                require +> $require,
            }
        }
    
        # updates, if $real_location is refreshed and module already active
        file { "${name}.te_to_check_if_its_there":
  	        path => $real_location
        }
        exec { "SELinux-${name}-Update":
            command     => "/usr/sbin/semodule -u ${real_location}",
            subscribe   => File["${name}.te_to_check_if_its_there"],
            refreshonly => true,
            onlyif => "/usr/bin/test -e /etc/selinux/${selinux_mode}/modules/active/modules/${name}.pp"
        }
        if $require {
            Exec["SELinux-${name}-Update"]{
                require +> $require,
            }
        }
    }  # end ensure present
    absent: {
        exec { "SELinux-${name}-Remove":
            command     => "/usr/sbin/semodule -r ${name}",
            onlyif => "/usr/bin/test -e /etc/selinux/${selinux_mode}/modules/active/modules/${name}.pp"
        }
        if $requireabsenceof {
            Exec["SELinux-${name}-Remove"]{
                require +> Exec["SELinux-${requireabsenceof}-Remove"],
            }
        }
    }  # end ensure absent
    }
}

define selinux::strictpermissive () {
    include selinux

    file { "/etc/selinux/config":
        owner => "root",
        group => "0",
        mode  => 444,
        ensure => present,
	    source => "puppet://$server/selinux/config_strict_permissive",
    }
}

define selinux::strictenforcing () {
    include selinux

    file { "/etc/selinux/config":
        owner => "root",
        group => "0",
        mode  => 444,
        ensure => present,
	    source => "puppet://$server/selinux/config_strict_enforcing",
    }
}

