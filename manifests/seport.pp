define selinux::seport(
  $setype,
  $port = 'absent',
  $protocol = 'tcp'
){
  $real_port = $port ? {
    'absent' => $name,
    default => $port
  }
  exec{"semanage port -a -t ${setype} -p ${protocol} ${real_port}":
    unless => "semanage port -l | grep -i ${setype} | grep -qE '${protocol}[ ]+([0-9, ]+)? ${real_port}'"
  }
}
