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
class selinux (
  $manage_munin   = false,
  $setroubleshoot = false
) {

  if $manage_munin {
    include ::munin::plugins::selinux
  }

  if $setroubleshoot {
    include selinux::setroubleshoot
  } elsif $setroubleshoot == 'absent' {
    include selinux::setroubleshoot::disable
  }
}
