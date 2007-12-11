# modules/selinux/manifests/init.pp - manage selinux
# Copyright (C) 2007 admin@immerda.ch
# 

modules_dir { "selinux": }

class selinux {

#	package { 'selinux':
#                ensure => present,
#                category => $operatingsystem ? {
#                        gentoo => 'app-forensics',
#                        default => '',
#                },
#        }



	#service { selinux: ensure  => running, enable  => true, }

#	file {
#        	"/etc/selinux/selinux.conf":
#                	source => "puppet://$servername/selinux/selinux.conf",
#        		ensure => file,
#        		force => true,
#        		mode => 0644, owner => root, group => root;
#        }
	
}

class selinux_module {
	# vorerst nur files raufladen
	file {
                "/var/lib/puppet/modules/selinux":
                        ensure => directory,
                        force => true,
                        mode => 0755, owner => root, group => root;
        }

	file {
		"/var/lib/puppet/modules/selinux/Makefile":
			ensure => file,
			source => "puppet://$servername/selinux/Makefile",
                        mode => 0755, owner => root, group => root;
	}

	exec { "make": 
		alias => "make",
    		cwd => "/var/lib/puppet/modules/selinux";
	}

	define the_three_selinux_policy_files () {
		$dir = "/var/lib/puppet/modules/selinux"
		file {
                        "${dir}/${name}.if":
				source => "puppet://$servername/selinux/${name}.if",
                                mode => 0600, owner => root, group => root,
                                notify => Exec["make"];
		}
		file {
                        "${dir}/${name}.te":
				source => "puppet://$servername/selinux/${name}.te",
                                mode => 0600, owner => root, group => root,
                                notify => Exec["make"];
		}
		file {
                        "${dir}/${name}.if":
				source => "puppet://$servername/selinux/${name}.if",
                                mode => 0600, owner => root, group => root,
                                notify => Exec["make"];
		}
	}
}

class selinux_module_unconfined inherits selinux_module {
	the_three_selinux_policy_files{ unconfined: }
}

