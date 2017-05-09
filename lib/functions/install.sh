#!/bin/bash
# Automated Installer Save Storage
# filename: lib/functions/install.sh
# Author: Kevin RUE
# Contributor: Valentin NAINA
# http://www.rkweb.fr

install_package_nfs() {
    local username="$(whoami)"
    local hostname=$SRVNFS
    local cmd="apt-get install -y $PKG_NFS"
    RSH "$username" "$hostname" "$cmd"
    if [[ $? -ne 0 ]]; then
        my_log_error "Error while installing $PKG_NFS packages on $hostname"
    else
        my_log_success "Packages $PKG_NFS has been installed successfully on $hostname"
    fi
}

install_package_iscsi() {
    local username="$(whoami)"
    local hostname=$SRVISCSI
    local cmd="apt-get install -y $PKG_ISCSI"
    RSH "$username" "$hostname" "$cmd"
    if [[ $? -ne 0 ]]; then
        my_log_error "Error while installing $PKG_ISCSI packages on $hostname"
    else
        my_log_success "Packages $PKG_ISCSI has been installed successfully on $hostname"
    fi
}

install_package_backup() {
    local hostname=$SRVBACKUP
    local backupUser="backuppc"
    local htpasswdDir="/etc/backuppc/htpasswd"
    local configFile="/etc/backuppc/config.pl"
    local oldschedule="1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23"
    local newschedule="1, 2, 3, 4, 5, 22, 23"
    local oldmaxbackup="MaxBackups} = 4"
    local newmaxbackup="MaxBackups} = 8"
    local oldmaxoldlog="MaxOldLogFiles} = 14"
    local newmaxoldlog="MaxOldLogFiles} = 7"
    DEBIAN_FRONTEND=noninteractive apt-get install -y -q --force-yes $PKG_BACKUP > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        my_log_error "Error while installing $PKG_BACKUP packages on $hostname"
    else
        my_log_success "Packages $PKG_BACKUP has been installed successfully on $hostname"
    fi
    my_log_setup "=== BackupPC Installation : Set a password ==="
    my_log_setup "Please enter your password for $backupUser"
    GEN_HTP $htpasswdDir $backupUser
    if [[ $? -ne 0 ]]; then
        my_log_error "Error while changing password of $backupUser"
    else
        my_log_success "Password for $backupUser has been changed successfully"
    fi
    sed -i.bak "s/$oldschedule/$newschedule/g" $configFile && sed -i "s/$oldmaxbackup/$newmaxbackup/g" $configFile && sed -i "s/$oldmaxoldlog/$newmaxoldlog/g" $configFile
    if [[ $? -ne 0 ]]; then
            my_log_error "Error while parsing $configFile"
        else
            my_log_success "$configFile file has been parsed successfully"
        fi
}

install_package_csgo() {
    [[ ! $# -lt "1" ]] || {
        my_log_error "Error while parsing args"
        exit 1
    }
    local username="root"
    local templateFile="${deploydir}/template_csgo.sh"
    local cmd="cd /tmp && chmod +x template_csgo.sh && ./template_csgo.sh"
    my_log_success "Calling $AISS_NAME version $AISS_VERSION to run $FUNCNAME action by user[$SUDO_USER]"
    waitfor
    my_log_setup "Counter-Strike Global Offensive"
    my_log_setup "Prepare CSGO environment"
    my_log_setup "Need 15 minutes for installation"
    for hosts in $*; do
       my_log_setup run_cmd "scp $templateFile ${username}@${hosts}:/tmp > /dev/null 2>&1"
        scp $templateFile ${username}@${hosts}:/tmp > /dev/null 2>&1
        my_log_setup run_cmd "RSH $username $hosts $cmd"
        my_log_setup "Installation in progress"
        my_log_setup "Please wait ..."
        RSH "$username" "$hosts" "$cmd"
        if [[ $? -ne 0 ]]; then
            my_log_error "Error while installing csgo packages on $hosts"
        else
            my_log_success "Packages csgo has been installed successfully on $hosts"
        fi
    done
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

install_package() {
    my_log_success "Calling $AISS_NAME version $AISS_VERSION to run $FUNCNAME action by user[$SUDO_USER]"
    waitfor $DEFAULT_TIMER
    check_connection_ssh || return 1
    install_package_nfs
    install_package_iscsi
    install_package_backup
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
