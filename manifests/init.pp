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

}

define selinux::module () {

    file { "/etc/selinux/local/$name":
        ensure => directory,
        owner  => "root",
        group  => "root",
        mode   => "0750",
    }
    file { "/etc/selinux/local/$name/Makefile":
        ensure  => present,
        owner   => "root",
        group   => "root",
        mode    => "0750",
	source => "puppet://$servername/selinux/Makefile",
    }

    file { "/etc/selinux/local/$name/$name.te": 
	ensure => file, 
	owner => root, 
	group => root, 
	mode => 640,
        source => "puppet://$servername/local/selinux/$name.te",
    }

    file { "/etc/selinux/local/$name/$name.fc": 
	ensure => file, 
	owner => root, 
	group => root, 
	mode => 640,
        source => "puppet://$servername/local/selinux/$name.fc",
    }

    file { "/etc/selinux/local/$name/$name.if": 
	ensure => file, 
	owner => root, 
	group => root, 
	mode => 640,
        source => "puppet://$servername/local/selinux/$name.if",
    }

    exec { "SELinux-$name-Update":
                command         => "/usr/bin/make -C /etc/selinux/local/$name -f /etc/selinux/local/$name/Makefile load",
                refreshonly => true,
                require     => File["/etc/selinux/local/$name/Makefile"],
                subscribe       => File["/etc/selinux/local/$name/$name.te"],
    }

}

