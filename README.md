# Table of contents
1. [Common purpose](#1-common-purpose)
2. [Compatibility](#2-compatibility)
3. [Installation](#3-installation)
4. [Config example in Hiera and result files](#4-config-example-in-hiera-and-result-files)


# 1. Common purpose
Gluster is a module for [GlusterFS](https://www.gluster.org/) config and package version manasging.

# 2. Compatibility
This module was tested on CentOS 7. However, it should work on newer versions of CentOS, Fedora and RHEL as well where Ansible 2.9 or newer is available. 

# 3. Installation
```yaml
mod 'gluster',
    :git => 'https://github.com/arrnorets/puppet-gluster.git',
    :ref => 'main'
```

# 4. Config example in Hiera and result files
This module follows the concept of so called "XaaH in Puppet". The principles are described [here](https://asgardahost.ru/library/syseng-guide/00-rules-and-conventions-while-working-with-software-and-tools/puppet-modules-organization/) and [here](https://asgardahost.ru/library/syseng-guide/00-rules-and-conventions-while-working-with-software-and-tools/3-hashes-in-hiera/).

Here is the example of config in Hiera:
```yaml
---
gluster:
  packages:
    ansible: '2.9.10-1.el7'
    glusterfs: '7.6-1.el7'
    glusterfs-server: '7.6-1.el7'
    glusterfs-libs: '7.6-1.el7'
  enable: true

  # /* Obligatory setting. Choosin the host from which per Gluster volume options are applied. */
  management_server: 'gfs-node2'

  # /* This options describes whether files for SSL encryption must be installed 
  # See https://docs.gluster.org/en/v3/Administrator%20Guide/SSL */
  ssl_enabled: "off"
  # /* END BLOCK */

  config:
    # /* Global options for /etc/glusterfs/glusterd.vol */
    options:
      glusterd:
        "type" : mgmt/glusterd
        "option working-directory" : /var/lib/glusterd
        "option transport-type" : socket,rdma
        "option transport.socket.keepalive-time" : 10
        "option transport.socket.keepalive-interval" : 2
        "option transport.socket.read-fail-log" : off
        "option transport.socket.listen-port" : 24007
        "option transport.rdma.listen-port" : 24008
        "option ping-timeout" : 0
        "option event-threads" : 1
        "option rpc-auth-allow-insecure" : "on"
        "option max-port" : 60999
    # /* END BLOCK */

    # /* Per volume options which are applied via ansible */
    volumes:
      glustervol:
        options:
          performance.client-io-threads: "off"
          nfs.disable: "on"
          storage.fips-mode-rchecksum: "on"
          transport.address-family: inet
          storage.owner-uid: 36
          storage.owner-gid: 36
          # auth.allow: 127.0.0.1,10.10.10.1,10.10.10.2,10.10.10.3
          # auth.ssl-allow: 127.0.0.1,localhost,gfs-node2,gfs-node3,gfs-node1
          # client.ssl: on
          # server.ssl: on
    # /* END BLOCK */

  # // Files for SSL encryption - see  https://docs.gluster.org/en/v3/Administrator%20Guide/SSL 
  ssl_files:
    gfs-node2:
      key: <gfs-node2 key is here>
      cert: <gfs-node2 cert is here>
    gfs-node3:
      key: <gfs-node3 key is here>
      cert: <gfs-node3 cert is here>
    gfs-arbiter:
      key: <gfs-arbiter key is here>
      cert: <gfs-arbiter cert is here>
    ca:
      cert: <CA cert is here>
```
It will install ansible and gluster packages, enable service glusterd and produce the folowing files:
+ /etc/glusterfs/glusterd.vol:
    ```bash
    volume management
    
    type mgmt/glusterd
    option working-directory /var/lib/glusterd
    option transport-type socket,rdma
    option transport.socket.keepalive-time 10
    option transport.socket.keepalive-interval 2
    option transport.socket.read-fail-log false
    option transport.socket.listen-port 24007
    option transport.rdma.listen-port 24008
    option ping-timeout 0
    option event-threads 1
    option rpc-auth-allow-insecure on
    option max-port 60999
    
    end-volume
    ```
+ /opt/ansible4puppet-gluster/conf/site.yml:
    ```yaml
    - name: Configure gluster settings
      hosts: localhost
      strategy: linear

      tasks:
      - name: Set multiple options on GlusterFS volume glustervol
        gluster_volume:
          state: present
          name: glustervol
          options:
            { 
              performance.client-io-threads: "off",
              nfs.disable: "on",
              storage.fips-mode-rchecksum: "on",
              transport.address-family: "inet",
              storage.owner-uid: "36",
              storage.owner-gid: "36"
            }
        delegate_to: localhost 
    ```

The ansible part is executed with script /opt/ansible4puppet-gluster/bin/glusterVolumeOptionsUpdate.sh which is generated as an ERB template inside of the module using 
abovementoned "management_server" setting from Hiera.

