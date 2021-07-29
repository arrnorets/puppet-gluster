class gluster::install ( Hash $gluster_pkg_hash ) {
    
    $gluster_pkg_names_array = keys( $gluster_pkg_hash )
    $gluster_pkg_names_array.each | String $pkg_name | {
        package { "${pkg_name}":
	    ensure => $gluster_pkg_hash[ "${pkg_name}" ],
        }
    }
}

