define selinux::fcontext($setype){
  exec{"semanage fcontext -a -t ${setype} '${name}'":
    unless => "grep -Fq '${name} ' /etc/selinux/targeted/contexts/files/file_contexts || grep -Fq '${name} ' /etc/selinux/targeted/contexts/files/file_contexts.local"
  }
}
