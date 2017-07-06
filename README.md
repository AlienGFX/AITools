# AITools

Automated Installer Tools (AITools) is a shell script which allows to automatically install the following products :
- A NFS share with nfs-common nfs-kernel-server packages
- An ISCSI lun with iscsitarget iscsitarget-dkms open-iscsi packages
- BackUPPC with backuppc package which saving nfs share from SRV-NFS into iscsi lun to SRV-ISCSI
- Update and Upgrade all Debian servers
- Install CSGO server
- Save and restore with Backup PC utilities
- Mount and umount hard disk
- Stop/start/restart service
- Monitor the server
- Check if the rootkey has been deployed of nodes


# Example action of this script
<install|uninstall|configure|reset>
It also configure every packages :

In this situation :
1) The NFS server must be saved with backupPC
2) BackUPPC must contain all backup of nfs share to own instances iscsi target
3) An instance BackupPC which save NFS data to SRV-NFS which copy to iscsi volume

This script must be executed to backuppc.

With this script, you can :
- Installing any packages to instances differently
- Configure and Mount ISCSI Lun from SRV-ISCSI to SRV-BACKUP
- Configure and Mount NFS shared to SRV-NFS

AISS.sh can backup to nfs share (srv-nfs) to lun iscsi (srv-iscsi)

Following this example :

              +-----------+        +-----------+
              |           |        |           |
              |           |        |           |
    +---------+  SRV-NFS  |        | SRV-ISCSI <--------+
    |         |           |        |           |        |
    |         |           |        |           |        |
    |         |           |        |           |        |
    |         +-----------+        +-----------+        |
    |                                                   |
    |                                                   |
    |                                                   |
    |                                                   |
    |                  +--------------+                 |
    |                  |              |                 |
    |                  |              |                 |
    |                  |              |                 |
    +------------------>  SRV-BACKUP  +-----------------+
                       |              |
                       |              |
                       |              |
                       +--------------+

### Usage of the script
The main script is located to the following directory : **/opt/AITools/aiss.sh**

You can create a new environment with the following comman :

```sh
$ sudo ./aiss.sh deploy
```

Several parameters are available with the script :

```sh
Usage: ./aiss.sh {install|install-csgo|install-pkg|uninstall|update|upgrade|configure|deploy|monitor|mount|umount|start|stop|restart|status|save|service|syncssh|reset|test-ssh|shutdown}
       install                           :  install all dependancies to the servers
       install-csgo <host>               :  install csgo and all dependancies to the servers
       install-pkg <host> <packages>     :  specify all packages to install to servers with one hostname and most packages
       uninstall                         :  uninstall all dependancies to the servers
       update  <host1|host2>             :  update all packages to the servers. Please enter the hostname
       upgrade <host1|host2>             :  upgrade all dependancies to the servers. Please enter the hostname
       service <host> <app> <action>     :  manage all services to servers with hostname appname action
       syncssh <host>                    :  synchronize comserver ssh key to the servers. Please enter the hostname
       configure                         :  deploy keys and configure dependancies
       deploy                            :  clone repo and deploy AITools into /opt/AITools
       monitor                           :  getting information for monitoring tools
       mount <host> <src> <device>       :  manage device mounting to servers with hostname source device
       umount <host> <device>            :  manage device umounting to servers with hostname device
       start                             :  start all services to servers
       stop                              :  stop all services to servers
       restart                           :  restart all services to servers
       status                            :  status all services to servers
       save                              :  save source server to destination server
       reset                             :  delete all configuration files
       test-ssh                          :  test SSH connections from core-infra
       shutdown <host1|host2>            :  shutdown mentionned servers. Please enter one or more hostname
```

To have a working environment, please follow this order while testing the script (at least at the beggining) :

```sh
$ cd /opt/AITools/
$ sudo ./aiss.sh install
$ sudo ./aiss.sh configure
```

Then, you can test all of the others parameters :)

Please, use sudo... :)

Be careful :

For more checks on these servers, you are root :
```sh
$ sudo su - root
```

Thanks to insert the good format with regex, example for configure to save SRV-NFS :

```sh
[27345] 2016/11/25 00:46:01 [SETUP]   SVC_SETUP  Do you want to add a server to backupPC ?  <y/N> y
[27345] 2016/11/25 00:46:08 [SETUP]   SVC_SETUP  === BackupPC Configuration : Add a server ===
[27345] 2016/11/25 00:46:08 [SETUP]   SVC_SETUP  Enter hostname : srv-nfs
[27345] 2016/11/25 00:46:22 [SETUP]   SVC_SETUP  Enter username : backuppc
[27345] 2016/11/25 00:46:25 [SETUP]   SVC_SETUP  Choose folders to save
[27345] 2016/11/25 00:46:25 [SETUP]   SVC_SETUP  Respect below regex
[27345] 2016/11/25 00:46:25 [SETUP]   SVC_SETUP  Example : '/etc', '/root', '/opt'
[27345] 2016/11/25 00:46:25 [SETUP]   SVC_SETUP  Folders to save : '/opt'
[27345] 2016/11/25 00:46:35 [SUCCESS] SVC_INFO   /etc/backuppc/hosts file has been parsed successfully
[27345] 2016/11/25 00:46:35 [SUCCESS] SVC_INFO   /etc/backuppc/pc/srv-nfs.pl file has been parsed successfully
[27345] 2016/11/25 00:46:35 [SUCCESS] SVC_INFO   chown backuppc:backuppc /etc/backuppc/pc/srv-nfs.pl has been executed successfully
[27345] 2016/11/25 00:46:35 [SETUP]   SVC_SETUP  Do you want to start a full backup for srv-nfs ?  <y/N> y
```

For your information, you are recorded into **/lib/functions/core.env.sh** to receive action status by email...

***Enjoy !***
--

Available command for example :

```sh
[DEV]
[1] ✗ dduck@srv-backup /opt/tools/aiss $ sudo ./aiss.sh upgrade srv-backup srv-nfs srv-iscsi
[28577] 2016/11/25 00:53:32 [SUCCESS] SVC_INFO   Calling AISS version 0.5 to run upgrader action
[28577] 2016/11/25 00:53:34 [SUCCESS] SVC_INFO   waitfor function has called during 2 secondes...
[28577] 2016/11/25 00:53:34 [SUCCESS] SVC_INFO   Upgrade on srv-backup is success, more details: /tmp/.28577_20161125_005332_srv-backup_upgrader
[28577] 2016/11/25 00:53:35 [SUCCESS] SVC_INFO   Upgrade on srv-nfs is success, more details: /tmp/.28577_20161125_005332_srv-backup_upgrader
[28577] 2016/11/25 00:53:35 [SUCCESS] SVC_INFO   Upgrade on srv-iscsi is success, more details: /tmp/.28577_20161125_005332_srv-backup_upgrader
[28577] 2016/11/25 00:53:35 [SUCCESS] SVC_INFO   upgrader action has success, see more logs/28577_20161125_005332_AISS.log
[28577] 2016/11/25 00:53:35 [SUCCESS] SVC_INFO   Mail with sub AISS version 0.5 action [upgrader] pid [28577] has success sent to k.rue@free.fr naina_valentin@hotmail.fr successfully
```

```sh
[DEV]
[0] ✓ dduck@srv-backup /opt/tools/aiss/docs $ l /tmp
total 84
-rw-r--r-- 1 root root  1231 nov.  25 00:51 .28412_20161125_005107_srv-backup_updater
-rw-r--r-- 1 root root   190 nov.  25 00:53 .28577_20161125_005332_srv-backup_upgrader
```

```sh
[DEV]
[1] ✗ dduck@srv-backup /opt/tools/aiss $ sudo ./aiss.sh status
[28848] 2016/11/25 00:54:50 [SUCCESS] SVC_INFO   Calling AISS version 0.5 to run status_svc action
[28848] 2016/11/25 00:54:51 [SUCCESS] SVC_INFO   waitfor function has called during 1 secondes...
[28848] 2016/11/25 00:54:51 [SUCCESS] SVC_INFO   SSH connection for srv-nfs has been successfully established
[28848] 2016/11/25 00:54:51 [SUCCESS] SVC_INFO   SSH connection for srv-iscsi has been successfully established
[28848] 2016/11/25 00:54:52 [SUCCESS] SVC_INFO   SSH connection for srv-backup has been successfully established
[28848] 2016/11/25 00:54:52 [SUCCESS] SVC_INFO   service nfs-common status on srv-nfs has been executed with success
[28848] 2016/11/25 00:54:52 [SUCCESS] SVC_INFO   service nfs-kernel-server status on srv-nfs has been executed with success
[28848] 2016/11/25 00:54:52 [SUCCESS] SVC_INFO   service iscsitarget status on srv-iscsi has been executed with success
[28848] 2016/11/25 00:54:52 [SUCCESS] SVC_INFO   service backuppc status on srv-backup has been executed with success
[28848] 2016/11/25 00:54:52 [SUCCESS] SVC_INFO   status_svc action has success, see more logs/28848_20161125_005450_AISS.log
[28848] 2016/11/25 00:54:52 [SUCCESS] SVC_INFO   Mail with sub AISS version 0.5 action [status_svc] pid [28848] has success sent to k.rue@free.fr naina_valentin@hotmail.fr successfully
```
