#!/bin/bash
# Automated Installer Save Storage
# filename: lib/functions/automount.sh
# Author: Kevin RUE
# Contributor: Valentin NAINA
# http://www.rkweb.fr

mount_iscsi(){
    local username="$(whoami)"
    local src="/dev/vda"
    local dest="/mnt/iscsi1"
    local cmd="mount $src $dest"
    RSH "$username" "$SRVISCSI" "$cmd"
    if [[ $? -eq 32 ]]; then
        my_log_warning "$src is already mounted on $dest to $SRVISCSI"
    elif [[ $? -ne 0 ]]; then
        my_log_success "$src was mounted successfully to $SRVISCSI"
    else
        my_log_error "Error during mount $src $dest to $SRVISCSI"
    fi
}

unmount_iscsi(){
    local username="$(whoami)"
    local src="/dev/vda"
    local dest="/mnt/iscsi1"
    local cmd="umount $src"
    RSH "$username" "$SRVISCSI" "$cmd"
    if [[ $? -eq 32 ]]; then
        my_log_warning "$src is already unmounted on $dest to $SRVISCSI"
    elif [[ $? -ne 0 ]]; then
        my_log_success "$src was unmounted successfully to $SRVISCSI"
    else
        my_log_error "Error during unmount $dest to $SRVISCSI"
    fi
}