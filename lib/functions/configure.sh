#!/bin/bash
# Automated Installer Save Storage
# filename: lib/functions/configure.sh
# Author: Kevin RUE
# Contributor: Valentin NAINA
# http://www.rkweb.fr

generate_keys_backuppc() {
    local user="backuppc"
    local userpath="~/.ssh"
    local keyname="id_rsa"
    local extraopts='-f '"$userpath/$keyname"' -C "SSH Key for Backup PC" -N ""'
    su - $user -c "ssh-keygen -t rsa -b 2048 $extraopts" > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        my_log_error "Problem during ssh-keygen creation"
    else
        my_log_success "RSA $keyname key has been created successfully for $user"
    fi
}

deploy_keys_backuppc() {
    for host in $SRVNFS $SRVISCSI $SRVBACKUP; do
        ssh-copy-id -i /var/lib/backuppc/.ssh/id_rsa.pub $host > /dev/null 2>&1
        if [[ $? -ne 0 ]]; then
            my_log_error "Problem during deploy keys from backuppc to $host"
        else
            my_log_success "RSA Public Key has been deployed successfully to $host"
        fi
    done
}

delete_keys_backuppc() {
    local user="backuppc"
    local userpath=".ssh"
    local privkey="id_rsa"
    local pubkey="id_rsa.pub"
    su - $user -c "rm $userpath/$privkey $userpath/$pubkey" > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        my_log_error "Problem during delete $userpath/$privkey and $userpath/$pubkey for $user. Probably the keys are already deleted"
    else
        my_log_success "File $userpath/$privkey and $userpath/$pubkey has been deleted successfully for $user"
    fi
}

config_backuppc() {
    local user="backuppc"
    my_log_setup "Do you want to add a server to backupPC ? $BWhite <y/N>"
    read prompt
        if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]; then
        local hostsFile="/etc/backuppc/hosts"
            my_log_setup "=== BackupPC Configuration : Add a server ==="
            my_log_setup "Enter hostname :"
            read p_backupHost
            my_log_setup "Enter username :"
            read p_backupUser
            my_log_setup "Choose folders to save"
            my_log_setup "Respect below regex "
            my_log_setup "Example : '/etc', '/root', '/opt'"
            my_log_setup "Folders to save :"
            read p_backupDirs
            local srvFile="/etc/backuppc/pc/$p_backupHost.pl"
            if [[ ! -f $srvFile ]]; then
                echo "$p_backupHost 0       $p_backupUser" >> $hostsFile
                if [[ $? -ne 0 ]]; then
                    my_log_error "Error while parsing $hostsFile"
                else
                    my_log_success "$hostsFile file has been parsed successfully"
                fi
                touch $srvFile && echo -e "\$Conf{XferMethod} = 'rsync';\n\$Conf{RsyncShareName} = [$p_backupDirs];" >> $srvFile
                if [[ $? -ne 0 ]]; then
                    my_log_error "Error while parsing $srvFile"
                else
                    my_log_success "$srvFile file has been parsed successfully"
                fi
            else
                my_log_error "The file $srvFile already exists"
            fi
            chown $p_backupUser:$p_backupUser $srvFile > /dev/null 2>&1 || {
                my_log_error "Problem during chown $p_backupUser:$p_backupUser $srvFile execution..."
            }
            my_log_success "chown $p_backupUser:$p_backupUser $srvFile has been executed successfully"
            my_log_setup "Do you want to start a full backup for $p_backupHost ? $BWhite <y/N>"
            read p_fullbackup
            if [[ $p_fullbackup == "y" || $p_fullbackup == "Y" || $p_fullbackup == "yes" || $p_fullbackup == "Yes" ]]; then
                su - $user -c "/usr/share/backuppc/bin/BackupPC_dump -f $p_backupHost"
                if [[ $? -ne 0 ]]; then
                    my_log_error "Error while doing the full backup of $p_backupHost"
                else
                    my_log_success "Full backup of $p_backupHost has been made successfully"
                fi
            else
                my_log_setup "No full backup will be made for $p_backupHost"
            fi
            my_log_setup "=== BackupPC Configuration End ==="
        else
            my_log_setup "No servers will be added on $user"
        fi
}

config_iscsi_for_srvbackup() {
    AWK="awk '{ print $1 }'"
    local iscsiSrv="$(getent hosts $SRVISCSI | awk '{ print $1 }')"
    local iscsiPort="3260"
    local iscsiFile="/etc/iscsi/iscsid.conf"
    local iscsiPassword="toto123"
    local iscsiTarget="iqn.2016.11.srv.groupe1:iscsi.test"
    local iscsiDiscodir="/dev/disk/by-path/"
    local iscsiFolder="/mnt/iscsi1"
    cat >> $iscsiFile << EOF
    node.session.auth.username = $iscsiPassword
    node.session.auth.password = $iscsiPassword
EOF
    if [[ $? -ne 0 ]]; then
        my_log_error "Error while parsing $iscsiFile"
    else
        my_log_success "$iscsiFile file has been parsed successfully"
    fi
    iscsiadm -m discovery -t st -p $iscsiSrv
    if [[ $? -ne 0 ]]; then
        my_log_error "Error while discovering an ISCSI Target"
    else
        if [[ $(ls $iscsiDiscodir) == *"$iscsiTarget"*  ]]; then
            my_log_success "ISCSI Target '$iscsiTarget' has been discovered successfully"
        else
            my_log_error "Error while trying to discover '$iscsiTarget'"
        fi
    fi
    iscsiadm -m node --targetname "$iscsiTarget" --portal "$iscsiSrv:$iscsiPort" --login
    if [[ $? -ne 0 ]]; then
        my_log_error "Error while connecting to '$iscsiTarget'"
    else
        my_log_success "Connection to '$iscsiTarget' has been established successfully"
    fi
    if mkdir $iscsiFolder ; then
        my_log_success "Folder $iscsiFolder has been created successfully"
    else
        my_log_error "Error while creating the folder $iscsiFolder"
    fi
    for i in $(ls -l $iscsiDiscodir)
    do
        if [[ $i == *"$iscsiTarget"*  ]]; then
            mount $iscsiDiscodir$i $iscsiFolder > /dev/null 2>&1 || {
                my_log_error "Error while mounting the ISCSI Target"
            }
            my_log_success "The ISCSI Target has been mounted successfully"
        fi
    done
}

config_iscsi_for_srviscsi(){
    action_svc_iscsi restart || return 1
    local username="$(whoami)"
    local hostname=$SRVISCSI
    local dest="/mnt/iscsi1"
    local cmdCheck="ls $dest"
    local cmdCreate="mkdir $dest"
    local cmdISCSI="echo ISCSITARGET_ENABLE=true > /etc/default/iscsitarget"
    RSH "$username" "$hostname" "$cmdISCSI" || {
        my_log_error "Error while executing cmd: $cmdISCSI"
    }
    RSH "$username" "$hostname" "$cmdCheck"
    if [[ $? -eq 2 ]]; then
        my_log_warning "Folder $dest on $hostname is not found"
        RSH "$username" "$hostname" "$cmdCreate"
        if [[ $? -ne 0 ]]; then
            my_log_error "Creation $dest folder on $hostname has failed"
        else
            my_log_success "Creation $dest folder on $hostname has success"
        fi
    else
        my_log_success "$dest folder also exists on $hostname"
    fi
}

configure_package() {
    my_log_success "Calling $AISS_NAME version $AISS_VERSION to run $FUNCNAME action by user[$SUDO_USER]"
    waitfor $DEFAULT_TIMER
    check_connection_ssh || return 1
    local homeDir="/var/lib/backuppc"
    local sshDir="$homeDir/.ssh"
    local privateKey="id_rsa"
    if [[ ! -f $sshDir/$privateKey ]]; then
        my_log_warning "$homeDir/$privateKey does not exists"
        my_log_warning "call generate_keys_backuppc to generate keys in $sshDir/$privateKey"
        generate_keys_backuppc || return 1
    else
        my_log_success "file $sshDir/$privateKey exists. Probably keys has been also created"
    fi
    deploy_keys_backuppc || my_log_error "Error during deploy keys with backuppc"
    config_backuppc || my_log_error "Error during config backuppc "
    waitfor $DEFAULT_TIMER
    config_iscsi_for_srviscsi || my_log_error "Error during config iscsi on $SRVISCSI"
    #config_iscsi_for_srvbackup || my_log_error "Error during config iscsi on $SRVBACKUP"
    # function config_iscsi does not run because the network is not a LAN.
    mount_iscsi
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
