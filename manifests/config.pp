class gluster::config ( Hash $gluster_config, String $mgmt_server ) {

    $gluster_options = hash2ini( $gluster_config[ "options" ], " ", false )

    file { "/etc/glusterfs/glusterd.vol":
        ensure => file,
        owner => root,
        group => root,
        mode => '0644',
        content => inline_template( "volume management\n\n${gluster_options}\n\nend-volume\n" ),
        require => Class[ "gluster::install" ],
        notify => Service[ "glusterd" ]
    }

    file { "/opt/ansible4puppet-gluster":
        ensure => directory,
        owner => root,
        group => root,
        mode => '0700'
    }

    file { "/opt/ansible4puppet-gluster/conf" :
        ensure => directory,
        owner => root,
        group => root,
        mode => '0700'
    }

    file { "/opt/ansible4puppet-gluster/bin" :
        ensure => directory,
        owner => root,
        group => root,
        mode => '0700'
    }

    file { "/opt/ansible4puppet-gluster/bin/glusterVolumeOptionsUpdate.sh" :
        ensure => file,
        owner => root,
        group => root,
        mode  => '0700',
        content => template( "gluster/glusterVolumeOptionsUpdate.sh.erb" )
    }

    $per_volume_options = generate_Ansible_Config_For_Gluster_Volume( $gluster_config[ "volumes" ] )

    file { "/opt/ansible4puppet-gluster/conf/site.yml":
        ensure => file,
        owner => root,
        group => root,
        mode  => '0600',
        content => inline_template( "${per_volume_options}\n" ),
        notify => Exec[ "apply_per_volume_options_via_ansible" ]
    }

    exec { "apply_per_volume_options_via_ansible":
        command => "/opt/ansible4puppet-gluster/bin/glusterVolumeOptionsUpdate.sh"
    }

}
