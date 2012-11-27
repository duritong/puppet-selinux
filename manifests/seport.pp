# manage a port for selinux
#
# * setype: which selinux type the port should be labeled
# * action: add/manage - Default: add
# * port: specify the port - Default: $name
# * protocol: tcp/udp - Default: tcp
define selinux::seport(
  $setype,
  $action = 'add',
  $port = $name,
  $protocol = 'tcp'
){
  $cli_action = $action ? {
    'manage' => '-m',
    default => '-a',
  }
  exec{"semanage port ${cli_action} -t ${setype} -p ${protocol} ${port}":
    unless  => "semanage port -l | grep -i ${setype} | grep -qE '${protocol}[ ]+([0-9, ]+)? ${port}'",
  }
}
