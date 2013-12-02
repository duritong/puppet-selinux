#######################################
# selinux module - disable.pp
# Puzzle ITC - haerry+puppet(at)puzzle.ch
# GPLv3
#######################################

# disable selinux stuff
class selinux::disable {
  file_line{'manage_selinux_sysconfig':
    line  => "SELINUX=disabled",
    match => '^SELINUX=',
    path  => '/etc/selinux/config',
  }
}
