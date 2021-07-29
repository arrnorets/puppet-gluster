class gluster {
    
    #Get all information about gluster settings from Hiera using "hash" merging strategy.
    $hash_from_hiera = lookup('gluster', { merge => 'deep' } ) 
    
    $ssl_enabled_value = $hash_from_hiera['ssl_enabled'] ? { undef => 'off', default => $hash_from_hiera['ssl_enabled'] } 
    $ssl_cert_hash_value = $hash_from_hiera['ssl_files'] ? { undef => {}, default => $hash_from_hiera['ssl_files'] }

    if( $ssl_enabled_value == "on" ) {
        class { "gluster::ssl" :
            ssl_cert_hash => $ssl_cert_hash_value
        }
    }
    
    $management_server = $hash_from_hiera['management_server'] ? { undef => 'localhost', default => $hash_from_hiera['management_server'] }
    
    class { "gluster::install" :
        gluster_pkg_hash => $hash_from_hiera[ 'packages' ]
    }
    
    class { "gluster::config" :
        gluster_config => $hash_from_hiera[ 'config' ],
        mgmt_server => $management_server
    }
    
    class { "gluster::service" :
        gluster_enabled => $hash_from_hiera[ 'enable' ]
    }
}
