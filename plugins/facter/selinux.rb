#facters for selinux stuff
#written by immerda admin team (admin(at)immerda.ch)
#GPLv3


Facter.add("selinux") do
    confine :kernel => :linux

    setcode do 
        result = "false"
        if FileTest.exists?("/selinux/enforce")
            result = "true"
        end
        result
    end
end

Facter.add("selinux_enforced") do
    confine :selinux => :true

    setcode do
        result = "false"
        if FileTest.exists?("/selinux/enforce") and File.read("/selinux/enforce") =~ /1/i
            result = "true"
        end
        result
    end
end

Facter.add("selinux_policyversion") do
    confine :selinux => :true
    setcode do 
	    File.read("/selinux/policyvers")
    end
end

Facter.add("selinux_mode") do
    confine :selinux => :true
    setcode do
        if FileTest.exists?("/usr/sbin/sestatus") 
            %x{/usr/sbin/sestatus | /bin/grep "Policy from config file:" | awk '{print $5}'}.chomp 
        else
            "none"
        end
    end
end
