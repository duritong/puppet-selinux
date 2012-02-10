define selinux::fcontext($setype){
  exec{"semanage fcontext -a -t ${setype} '${name}'":
    unless => "grep -q '${name} ' /etc/selinux/targeted/contexts/files/file_contexts || grep -q '${name} ' /etc/selinux/targeted/contexts/files/file_contexts.local"
  }
}
