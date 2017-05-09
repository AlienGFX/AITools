#!/bin/bash
# Automated Installer Save Storage
# filename: aiss.sh
# Author: Kevin RUE
# Contributor: Valentin NAINA
# http://www.rkweb.fr

export USER=$SUDO_USER

directory="$(dirname $(readlink -f "${BASH_SOURCE[0]}"))"
libdir="$directory/lib"
functionsdir="$libdir/functions"

[ -r $functionsdir/core.sh ] && source $functionsdir/core.sh
[ -r $functionsdir/core.env.sh ] && source $functionsdir/core.env.sh
[ -r $functionsdir/colors.sh ] && source $functionsdir/colors.sh
[ -r $functionsdir/automount.sh ] && source $functionsdir/automount.sh
[ -r $functionsdir/services.sh ] && source $functionsdir/services.sh
[ -r $functionsdir/logs.sh ] && source $functionsdir/logs.sh
[ -r $functionsdir/install.sh ] && source $functionsdir/install.sh
[ -r $functionsdir/uninstall.sh ] && source $functionsdir/uninstall.sh
[ -r $functionsdir/configure.sh ] && source $functionsdir/configure.sh

# allowed root user only
if [ "$(whoami)" != "root" ]; then
    my_log_error "You cannot execute this script, because you are not root."
    exit 1
fi

usage() {
    echo -e "Usage: $BWhite$0 $BRed{install|install-csgo|uninstall|update|upgrade|configure|monitor|mount|unmount|start|stop|restart|status|save|service|reset|test-ssh}"
    echo -e "$Red       install                           $White: $Green install all dependancies to the servers"
    echo -e "$Red       install-csgo <host>               $White: $Green install csgo and all dependancies to the servers"
    echo -e "$Red       uninstall                         $White: $Green uninstall all dependancies to the servers"
    echo -e "$Red       update  <host1|host2>             $White: $Green update all packages to the servers. Please enter the hostname"
    echo -e "$Red       upgrade <host1|host2>             $White: $Green upgrade all dependancies to the servers. Please enter the hostname"
    echo -e "$Red       service <host> <app> <action>     $White: $Green manage all services to servers with hostname appname action"
    echo -e "$Red       configure                         $White: $Green deploy keys and configure dependancies"
    echo -e "$Red       monitor                           $White: $Green getting information for monitoring tools"
    echo -e "$Red       mount                             $White: $Green mount ISCSI for $SRVBACKUP"
    echo -e "$Red       unmount                           $White: $Green unmount ISCSI for $SRVBACKUP"
    echo -e "$Red       start                             $White: $Green start all services to servers"
    echo -e "$Red       stop                              $White: $Green stop all services to servers"
    echo -e "$Red       restart                           $White: $Green restart all services to servers"
    echo -e "$Red       status                            $White: $Green status all services to servers"
    echo -e "$Red       save                              $White: $Green save source server to destination server"
    echo -e "$Red       reset                             $White: $Green delete all configuration files"
    echo -e "$Red       test-ssh                          $White: $Green test SSH connections from core-infra"
}

_install() {
    install_package
}

_uninstall() {
    uninstall_package
}

_configure() {
    configure_package
}

_monitor() {
    monitor
}

_mount() {
    mount_iscsi
}

_unmount() {
    unmount_iscsi
}

_start() {
    start_svc
}

_stop() {
    stop_svc
}

_restart() {
    restart_svc
}

_status() {
    status_svc
}

_save() {
    save
}

_reset() {
    reset_conf
}

_test_ssh() {
    check_connection_ssh
}

case "$1" in
    install)
        _install
        ;;
    install-csgo)
        shift 1
        install_package_csgo $*
        ;;
    uninstall)
        _uninstall
        ;;
    update)
        shift 1
        updater $*
        ;;
    upgrade)
        shift 1
        upgrader $*
        ;;
    service)
        shift 1
        action_svc $*
        ;;
    configure)
        _configure
        ;;
    monitor)
        _monitor
        ;;
    mount)
        _mount
        ;;
    unmount)
        _unmount
        ;;
    start)
        _start
        ;;
    stop)
        _stop
        ;;
    restart)
        _restart
        ;;
    status)
        _status
        ;;
    save)
        _save
        ;;
    reset)
        _reset
        ;;
    test-ssh)
        _test_ssh
        ;;
    *)
        usage
        exit 1
esac
