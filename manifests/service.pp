class gluster::service( Boolean $gluster_enabled ) {
    service { "glusterd":
        ensure => $gluster_enabled,
        enable => $gluster_enabled,
        require => Class[ "gluster::install" ]
    }
}
