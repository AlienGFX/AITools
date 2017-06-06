#!/bin/bash
# Automated Installer Save Storage
# filename: lib/functions/automount.sh
# Author: Kevin RUE
# Contributor: Valentin NAINA
# http://www.rkweb.fr

mount() {
    local username="$(whoami)"
    local hostname="$1"
    local src="$2"
    local dest="$3"
    local cmd="mount $src $dest"
    RSH "$username" "$hostname" "$cmd"
    if [[ $? -ne 0 ]]; then
        my_log_error "Error during $cmd on $hostname"
    else
        my_log_success "$cmd on $hostname has been executed with success"
    fi
}

umount() {
    local username="$(whoami)"
    local hostname="$1"
    local dest="$2"
    local cmd="umount $dest"
    RSH "$username" "$hostname" "$cmd"
    if [[ $? -ne 0 ]]; then
        my_log_error "Error during $cmd on $hostname"
    else
        my_log_success "$cmd on $hostname has been executed with success"
    fi
}

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
