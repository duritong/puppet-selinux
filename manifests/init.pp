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

# base class to manage a few selinux related things
#
# Parameters:
#
#  * mode: Mode of selinux: enforcing/permissive/disabled
#  * manage_munin: Munin plugins?
#  * setroubleshoot: setroubleshoot server?
#
class selinux (
  $mode           = 'enforcing',
  $manage_munin   = false,
  $setroubleshoot = false,
) {

  file_line{'manage_selinux_sysconfig':
    line  => "SELINUX=${mode}",
    match => '^SELINUX=',
    path  => '/etc/selinux/config',
  }

  if $mode != 'disabled' {
    if $manage_munin {
      include ::munin::plugins::selinux
    }

    if $setroubleshoot == 'absent' {
      include selinux::setroubleshoot::disable
    } elsif $setroubleshoot {
      include selinux::setroubleshoot
    }
  }
}
