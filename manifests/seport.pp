define selinux::seport(
  $setype,
  $action = 'add',
  $port = 'absent',
  $protocol = 'tcp'
){
  $real_port = $port ? {
    'absent' => $name,
    default => $port
  }
  $cli_action = $action ? {
    'manage' => '-m',
    default => '-a',
  }
  exec{"semanage port ${cli_action} -t ${setype} -p ${protocol} ${real_port}":
    unless => "semanage port -l | grep -i ${setype} | grep -qE '${protocol}[ ]+([0-9, ]+)? ${real_port}'"
  }
}
