#!/bin/bash
# Automated Installer Save Storage
# filename: lib/functions/uninstall.sh
# Author: Kevin RUE
# Contributor: Valentin NAINA
# http://www.rkweb.fr

uninstall_package_nfs() {
    local username="$(whoami)"
    local hostname=$SRVNFS
    local cmd="apt-get purge -y $PKG_NFS"
    RSH "$username" "$hostname" "$cmd"
    if [[ $? -ne 0 ]]; then
        my_log_error "Error while uninstalling $PKG_NFS packages on $hostname"
    else
        my_log_success "Packages $PKG_NFS has been uninstalled successfully on $hostname"
    fi
}

uninstall_package_iscsi() {
    local username="$(whoami)"
    local hostname=$SRVISCSI
    local cmd="apt-get purge -y $PKG_ISCSI"
    RSH "$username" "$hostname" "$cmd"
    if [[ $? -ne 0 ]]; then
        my_log_error "Error while uninstalling $PKG_ISCSI packages on $hostname"
    else
        my_log_success "Packages $PKG_ISCSI has been uninstalled successfully on $hostname"
    fi
}

uninstall_package_backup() {
    local username="$(whoami)"
    local hostname=$SRVBACKUP
    local cmd="apt-get purge -y $PKG_BACKUP"
    RSH "$username" "$hostname" "$cmd"
    if [[ $? -ne 0 ]]; then
        my_log_error "Error while uninstalling $PKG_BACKUP packages on $hostname"
    else
        my_log_success "Packages $PKG_BACKUP has been uninstalled successfully on $hostname"
    fi
}

uninstall_package() {
    my_log_success "Calling $AISS_NAME version $AISS_VERSION to run $FUNCNAME action by user[$SUDO_USER]"
    waitfor $DEFAULT_TIMER
    check_connection_ssh || return 1
    unmount_iscsi && waitfor $DEFAULT_TIMER
    action_svc_nfs stop
    action_svc_iscsi stop
    action_svc_backup stop
    waitfor $DEFAULT_TIMER
    uninstall_package_iscsi
    uninstall_package_nfs
    uninstall_package_backup
    if [[ $? -ne 0 ]]; then
        local lastFile="$(ls -1rt $logsdir | tail -n1)"
        local subject="$AISS_NAME version $AISS_VERSION action [$FUNCNAME] pid [$AISS_PID] has failed"
        my_log_error "$FUNCNAME action has failed, see more logs/$lastFile"
        mailer "$lastFile" "$subject"
    else
        local lastFile="$(ls -1rt $logsdir | tail -n1)"
        local subject="$AISS_NAME version $AISS_VERSION action [$FUNCNAME] pid [$AISS_PID] has success"
        my_log_success "$FUNCNAME action has success, see more logs/$lastFile"
        mailer "$lastFile" "$subject"
    fi
}