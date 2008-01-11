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

    file { '/usr/local/bin/s0':
        ensure => absent,
    }
    file { '/usr/local/bin/s1':
        ensure => absent,
    }

    file { '/usr/local/sbin/s0':
        owner => "root",
        group => "0",
        mode  => 755,
        ensure => present,
	source => "puppet://$servername/selinux/s0",
    }
    file { '/usr/local/sbin/s1':
        owner => "root",
        group => "0",
        mode  => 755,
        ensure => present,
	source => "puppet://$servername/selinux/s1",
    }

    class deenforce {
	Exec { path => "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin" }
	exec { "/usr/local/sbin/s0": }
    }

}

define selinux::module () {

    file { "/etc/selinux/local/$name":
        ensure => directory,
        owner  => "root",
        group  => "root", mode   => "0750",
    }
    file { "/etc/selinux/local/$name/Makefile":
        ensure  => present,
        owner   => "root",
        group   => "root",
        mode    => "0750",
	source => "puppet://$servername/selinux/Makefile",
    }

    file { "/etc/selinux/local/$name/${name}.te": 
	ensure => file, 
	owner => root, 
	group => root, 
	mode => 640,
        source => "puppet://$servername/dist/selinux/$name.te",
    }

    file { "/etc/selinux/local/$name/${name}.fc": 
	ensure => file, 
	owner => root, 
	group => root, 
	mode => 640,
        source => "puppet://$servername/dist/selinux/${name}.fc",
    }

    file { "/etc/selinux/local/${name}/${name}.if": 
	ensure => file, 
	owner => root, 
	group => root, 
	mode => 640,
        source => "puppet://$servername/dist/selinux/${name}.if",
    }

    exec { "SELinux-$name-Update":
                command         => "/usr/bin/make -C /etc/selinux/local/${name} -f /etc/selinux/local/${name}/Makefile load",
                refreshonly => true,
                require     => File["/etc/selinux/local/${name}/Makefile"],
                subscribe       => File["/etc/selinux/local/${name}/${name}.te"],
    }

}

# location = location of the pp (eg. /usr/share/selinux/strict/logrotate.pp)
define selinux::loadmodule ($location) {
    # installs the module, if it is no already installed
    exec { "SELinux-${name}-Install":
                command     => "/usr/sbin/semodule -i ${location}",
		creates	    => "/etc/selinux/strict/modules/active/modules/${name}.pp",
                #require     => File["$location"],
                #onlyif => "test ! -e /etc/selinux/strict/modules/active/modules/$name.pp"
    }
    
    # updates, if $location is refreshed and module already active
    file { "${name}.te_to_check_if_its_there":
  	    path => "$location"
    }
    exec { "SELinux-$name-Update":
                command     => "/usr/sbin/semodule -u ${location}",
                subscribe   => File["${name}.te_to_check_if_its_there"],
                refreshonly => true,
                onlyif => "/usr/bin/test -e /etc/selinux/strict/modules/active/modules/${name}.pp"
    }
}

