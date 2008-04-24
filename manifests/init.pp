# modules/selinux/manifests/init.pp - manage selinux
# Copyright (C) 2007 admin@immerda.ch
# 

class selinux {

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

    include munin::plugins::selinux
}

define selinux::module () {
    include selinux

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
	    source => "puppet://$server/selinux/Makefile",
        require => File["/etc/selinux/local/$name"],
    }

    file { "/etc/selinux/local/$name/${name}.te": 
    	ensure => file, 
	    owner => root, 
    	group => root, 
	    mode => 640,
        source => [ "puppet://$server/files/selinux/${fqdn}/${name}.te",
                    "puppet://$server/files/selinux/${name}.te",
                    "puppet://$server/selinux/module/${name}.te" ],
        notify => Exec["SELinux-${name}-Update"],
        require => File["/etc/selinux/local/$name"],
    }

    file { "/etc/selinux/local/${name}/${name}.fc": 
    	ensure => file, 
	    owner => root, 
    	group => root, 
	    mode => 640,
        source => [ "puppet://$server/files/selinux/${fqdn}/${name}.fc",
                    "puppet://$server/files/selinux/${name}.fc",
                    "puppet://$server/selinux/module/${name}.fc" ],
        notify => [ Exec["SELinux-${name}-Update"], Exec["SELInux-${name}-Relabel"] ],
        require => File["/etc/selinux/local/$name"],
    }

    file { "/etc/selinux/local/${name}/${name}.if": 
    	ensure => file, 
	    owner => root, 
    	group => root, 
	    mode => 640,
        source => [ "puppet://$server/files/selinux/${fqdn}/${name}.if",
                    "puppet://$server/files/selinux/${name}.if",
                    "puppet://$server/selinux/module/${name}.if" ],
        notify => Exec["SELinux-${name}-Update"],
        require => File["/etc/selinux/local/$name"],
    }

    exec { "SELinux-${name}-Update":
       command         => "/usr/bin/make -C /etc/selinux/local/${name} -f /etc/selinux/local/${name}/Makefile load",
       refreshonly => true,
       require     => File["/etc/selinux/local/${name}/Makefile"],
    }
    exec{"SELInux-${name}-Relabel":
       command  => "rlpkg -a",
       refreshonly => true,
       require => Exec["SELinux-${name}-Update"],
    }
}

# location = location of the pp (eg. /usr/share/selinux/strict/logrotate.pp)
define selinux::loadmodule ($location) {
    # installs the module, if it is no already installed
    exec { "SELinux-${name}-Install":
        command     => "/usr/sbin/semodule -i ${location}",
		creates	    => "/etc/selinux/${selinux_mode}/modules/active/modules/${name}.pp",
        #require     => File["$location"],
        #onlyif => "test ! -e /etc/selinux/strict/modules/active/modules/$name.pp"
    }
    
    # updates, if $location is refreshed and module already active
    file { "${name}.te_to_check_if_its_there":
  	    path => "$location"
    }
    exec { "SELinux-${name}-Update":
        command     => "/usr/sbin/semodule -u ${location}",
        subscribe   => File["${name}.te_to_check_if_its_there"],
        refreshonly => true,
        onlyif => "/usr/bin/test -e /etc/selinux/${selinux_mode}/modules/active/modules/${name}.pp"
    }
}

