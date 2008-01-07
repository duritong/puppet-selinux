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
}

define selinux::module () {

    file { "/etc/selinux/local/Makefile":
        ensure  => present,
        owner   => "root",
        group   => "root",
        mode    => "0750",
	source => "puppet://$servername/selinux/Makefile",
    }

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
    

#    exec { "SELinux-$name-Update":
#                command         => "/etc/selinux/local/$name/Makefile",
#                refreshonly => true,
#                require     => File["/etc/selinux/local/$name/Makefile"],
#                subscribe       => File["/etc/selinux/local/$name/$name.te"],
#    }
}

#	file {
#                "/var/lib/puppet/modules/selinux":
#                        ensure => directory,
#                        force => true,
#                        mode => 0755, owner => root, group => root;
#        }
#
#	file {
#		"/var/lib/puppet/modules/selinux/Makefile":
#			ensure => file,
#			source => "puppet://$servername/selinux/Makefile",
#                        mode => 0755, owner => root, group => root;
#	}
#
#	exec { "make": 
#		alias => "make",
#    		cwd => "/var/lib/puppet/modules/selinux";
#	}
#
#	define the_three_selinux_policy_files () {
#		$dir = "/var/lib/puppet/modules/selinux"
#		file {
#                        "${dir}/${name}.te":
#				source => "puppet://$servername/selinux/${name}.te",
#                                mode => 0600, owner => root, group => root,
#                                notify => Exec["make"];
#		}
#		file {
#                        "${dir}/${name}.fc":
#				source => "puppet://$servername/selinux/${name}.fc",
#                                mode => 0600, owner => root, group => root,
#                                notify => Exec["make"];
#		}
#		file {
#                        "${dir}/${name}.if":
#				source => "puppet://$servername/selinux/${name}.if",
#                                mode => 0600, owner => root, group => root,
#                                notify => Exec["make"];
#		}
#	}
#}
#
#class selinux_module_unconfined inherits selinux_module {
#	the_three_selinux_policy_files{ unconfined: }
#}

