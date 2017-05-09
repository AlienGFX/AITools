#!/bin/bash
# Automated Installer Save Storage
# filename: lib/functions/actions_svc.sh
# Author: Kevin RUE
# Contributor: Valentin NAINA
# http://www.rkweb.fr

action_svc() {
    local username="$(whoami)"
    local hostname="$1"
    local app="$2"
    local action="$3"
    local cmd="service $app $action"
    RSH "$username" "$hostname" "$cmd"
    if [[ $? -ne 0 ]]; then
        my_log_error "Error during $cmd on $hostname"
    else
        my_log_success "$cmd on $hostname has been executed with success"
    fi
}

action_svc_iscsi() {
##### action_svc_iscsi <action> #####
##### action_available for iscsitarget: {start|stop|restart|status}
    local username="$(whoami)"
    local hostname=$SRVISCSI
    local app="iscsitarget"
    local action="$1"
    local cmd="service $app $action"
    RSH "$username" "$hostname" "$cmd"
    if [[ $? -ne 0 ]]; then
        my_log_error "Error during $cmd on $hostname"
    else
        my_log_success "$cmd on $hostname has been executed with success"
    fi
}

action_svc_nfs() {
##### action_svc_nfs <action> #####
##### action_available for nfs-common: {start|stop|status|restart}
##### action_available for nfs-kernel-server: {start|stop|status|reload|force-reload|restart}
    local username="$(whoami)"
    local hostname=$SRVNFS
    local app="iscsitarget"
    local action="$1"
    for app in "nfs-common" "nfs-kernel-server"; do
        local cmd="service $app $action"
        RSH "$username" "$hostname" "$cmd"
        if [[ $? -ne 0 ]]; then
            my_log_error "Error during $cmd on $hostname"
        else
            my_log_success "$cmd on $hostname has been executed with success"
        fi
    done
}

action_svc_backup() {
##### action_svc_iscsi <action> #####
##### action_available for backuppc: {start|stop|restart|reload|status}
    local username="$(whoami)"
    local hostname=$SRVBACKUP
    local app="backuppc"
    local action="$1"
    local cmd="service $app $action"
    RSH "$username" "$hostname" "$cmd"
    if [[ $? -ne 0 ]]; then
        my_log_error "Error during $cmd on $hostname"
    else
        my_log_success "$cmd on $hostname has been executed with success"
    fi
}
