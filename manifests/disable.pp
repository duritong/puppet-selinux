#######################################
# selinux module - disable.pp
# Puzzle ITC - haerry+puppet(at)puzzle.ch
# GPLv3
#######################################

# disable selinux stuff
class selinux::disable {

    case $operatingsystem {
        centos: { include selinux::disable::centos }
    }

}

class selinux::disable::centos {
    service{restorecond:
        ensure => stopped,
        enable => false,
    }
    service{mcstrans:
        ensure => stopped,
        enable => false,
    }

    exec{disable_selinux_sysconfig:
        command => 'sed -i "s@^\(SELINUX=\).*@\1disabled@" /etc/sysconfig/selinux',
        unless => 'grep -q "SELINUX=disabled" /etc/sysconfig/selinux',
    }
}    

