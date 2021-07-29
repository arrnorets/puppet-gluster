class gluster::ssl ( Hash $ssl_cert_hash ) {
    file { "/etc/ssl/glusterfs.key":
        ensure => file,
        owner => root,
        group => root,
        mode => '0400',
        content => inline_template( $ssl_cert_hash[ $fqdn ][ "key" ] )
    }

    file { "/etc/ssl/glusterfs.pem":
        ensure => file,
        owner => root,
        group => root,
        mode => '0644',
        content => inline_template( $ssl_cert_hash[ $fqdn ][ "cert" ] )
    }

    file { "/etc/ssl/glusterfs.ca":
        ensure => file,
        owner => root,
        group => root,
        mode => '0644',
        content => inline_template( $ssl_cert_hash[ "ca" ][ "cert" ] )
    }

}
