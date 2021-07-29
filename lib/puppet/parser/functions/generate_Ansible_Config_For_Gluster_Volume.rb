module Puppet::Parser::Functions
  newfunction(:generate_Ansible_Config_For_Gluster_Volume, :type => :rvalue, :doc => <<-EOS
    Generates configuration for ansible task that configures gluster volumes.
    EOS
  ) do |arguments|
    glustervolumesinfo = arguments[0]
    result = "- name: Configure gluster settings\n  hosts: localhost\n  strategy: linear\n\n  tasks:"
    glustervolumesinfo.each do |volumename, volumeinfo|
        result = result + "\n" + "  - name: Set multiple options on GlusterFS volume " + volumename.to_s + "\n"
        result = result + "    gluster_volume:\n      state: present\n      name: " + volumename.to_s + "\n"
        result = result + "      options:\n        {\n"
        options_list = ""
        volumeinfo["options"].each do |key, value|
          options_list = options_list + '          ' + key.to_s + ': "' + value.to_s + '",' + "\n"
        end
        options_list = options_list[0...-2]
	result = result + options_list + "\n        }\n    delegate_to: localhost\n\n"
    end
    return result
  end
end

