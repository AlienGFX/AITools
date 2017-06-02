#!/bin/bash
# Automated Installer Save Storage
# filename: lib/functions/core.sh
# Author: Kevin RUE
# Contributor: Valentin NAINA
# http://www.rkweb.fr

RSH() {
    local user=$1
    local host=$2
    local cmd=$3
    ssh "$user@$host" "$cmd" > /dev/null 2>&1 &
    rshStatus=$?
}

GEN_HTP() {
    local err=$?
    local directory=$1
    local user=$2
    htpasswd $directory $user
    if [[ $err -ne 0 ]]; then
        my_log_error "Problem during htpasswd cmd with $FUNCNAME function"
    else
        my_log_success "The user has been created for $user"
    fi
}

waitfor() {
    declare -i DEFAULT_TIMER="${1:-2}"
    sleep $DEFAULT_TIMER && {
        my_log_success "$FUNCNAME function has called during $DEFAULT_TIMER secondes..."
    }
}

run_cmd() {
    echo "run_cmd: $@"
}

check_connection_ssh() {
    for host in $SYS_WAVE_DEV_0 $SYS_WAVE_PRD_1 $SYS_WAVE_PRD_2 $SYS_WAVE_PRD_3; do
        RSH root $host hostname
        if [[ $rshStatus -ne 0 ]]; then
            my_log_error "SSH connection for $host has failed. Please check the ssh key"
        else
            my_log_success "SSH connection for $host has been successfully established"
        fi
    done
}

deploy() {
    OPT="/opt"
    my_log_success "Calling $AISS_NAME version $AISS_VERSION to run $FUNCNAME action by user[$SUDO_USER]"
    waitfor
    run_cmd "cd $OPT"
    cd $OPT
    [[ -d AITools ]] && {
        run_cmd "mv AITools AITools.old"
        mv AITools AITools.old
    } || {
        my_log_warning "Error during move AITools to AITools.old"
    }
    run_cmd "git clone $GIT_REPOSITORY"
    git clone $GIT_REPOSITORY
    cd $directory && git log > $logsdir/.gitbuild
    if [[ $? -ne 0 ]]; then
        local lastFile="$(ls -1rt $logsdir | tail -n1)"
        local subject="$AISS_NAME version $AISS_VERSION action [$FUNCNAME] pid [$AISS_PID] has failed"
        my_log_error "$FUNCNAME action has failed, see more logs/$lastFile"
        mailer "$lastFile" "$subject"
    else
        local lastFile="$(ls -1rt $logsdir | tail -n1)"
        local subject="$AISS_NAME version $AISS_VERSION action [$FUNCNAME] pid [$AISS_PID] has success"
        my_log_success "$FUNCNAME action has success, see more logs/$lastFile"
        my_log_success "[$AISS_NAME] New build has released $(expr $AISS_BUILD + 1) by $SUDO_USER"
        mailer "$lastFile" "$subject"
        mailer .gitbuild "[$AISS_NAME] New build has released $(expr $AISS_BUILD + 1) by $SUDO_USER"
    fi
}

monitor() {
    local bin="/usr/bin/motdstat"
    [ -x $bin ] || {
        my_log_error "Binary $bin does not exists on this server..."
        exit 1
    }
    local status="$bin --status"
    echo -e "$No_Color      exec $status"
    echo -e ""
    $status || return 1
    echo -e ""
    echo -e "$No_Color      for more details :"
    echo -e "$No_Color     $Green http://$(hostname).$DOMAIN:$PORT_MONITORING"
    echo -e ""
    echo -e ""
}

mailer() {
    local file=$1
    local subject=$2
    [ ! -x "/usr/bin/mailx" ] && my_log_error "mailx is not installed on $(hostname)"
    if [ $sendmail = "on" ]; then
        cat "logs/$file" | $Color_Off_For_Email | mailx -a "From:$inbox" -s "$subject" $whosend
        my_log_success "Mail with sub $subject sent to $whosend successfully"
    elif [ $sendmail = "off" ]; then
        my_log_warning "Variable sendmail is $sendmail. No mail has sent"
    else
        my_log_error "Problem during sent mail. Please check core.env.sh"
    fi
}

updater() {
    [[ ! $# -lt "1" ]] || {
        my_log_error "Error while parsing args"
        exit 1
    }
    local cmd="apt-get update"
    local tmpdist="/tmp/.$$_$(date '+%Y%m%d_%H%M%S')_$(hostname)_$FUNCNAME"
    my_log_success "Calling $AISS_NAME version $AISS_VERSION to run $FUNCNAME action by user[$SUDO_USER]"
    waitfor
    for hosts in $*; do
        RSH root $hosts "$cmd > $tmpdist"
        if [[ $rshStatus -ne 0 ]]; then
            my_log_error "Error during update on $hosts, more details: $tmpdist"
        else
            my_log_success "Update on $hosts is success, more details: $tmpdist"
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

upgrader() {
    [[ ! $# -lt "1" ]] || {
        my_log_error "Error while parsing args"
        exit 1
    }
    local cmd="apt-get upgrade -y"
    local tmpdist="/tmp/.$$_$(date '+%Y%m%d_%H%M%S')_$(hostname)_$FUNCNAME"
    my_log_success "Calling $AISS_NAME version $AISS_VERSION to run $FUNCNAME action by user[$SUDO_USER]"
    waitfor
    for hosts in $*; do
        RSH root $hosts "$cmd > $tmpdist"
        if [[ $rshStatus -ne 0 ]]; then
            my_log_error "Error during upgrade on $hosts, more details: $tmpdist"
        else
            my_log_success "Upgrade on $hosts is success, more details: $tmpdist"
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

save() {
    my_log_success "Calling $AISS_NAME version $AISS_VERSION to run $FUNCNAME action by user[$SUDO_USER]"
    waitfor $DEFAULT_TIMER
    local user="backuppc"
    my_log_setup "=== BackupPC Save : Launch to new backup ==="
    my_log_setup "Hostname to save : $BWhite EXAMPLE=<$SRVNFS>"
    read p_backupHost
    local srvFile="/etc/backuppc/pc/$p_backupHost.pl"
    [[ -f $srvFile ]] || {
        my_log_warning "The server does not find into configuration."
        my_log_setup "exec config_backuppc function. You must retry $FUNCNAME action"
        config_backuppc || return 1
        exit 1
    }
    my_log_setup "Could you define the type of backup ? DEFAULT=<full|incremental>"
    read p_backupType
    if [[ $p_backupType == "full" || $p_backupType == "FULL" ]]; then
        su - $user -c "/usr/share/backuppc/bin/BackupPC_dump -f $p_backupHost"
        if [[ $? -ne 0 ]]; then
            my_log_error "Error while doing the full backup of $p_backupHost"
        else
            my_log_success "Full backup of $p_backupHost has been made successfully"
        fi
    elif [[ $p_backupType == "incremental" || $p_backupType == "INCREMENTAL" ]]; then
        su - $user -c "/usr/share/backuppc/bin/BackupPC_dump -i $p_backupHost"
        if [[ $? -ne 0 ]]; then
            my_log_error "Error while doing the incremental backup of $p_backupHost"
        else
            my_log_success "Incremental backup of $p_backupHost has been made successfully"
        fi
    else
        my_log_error "Unknow answer. No save will be scheduled for $p_backupHost"
    fi
    my_log_setup "=== BackupPC Save End ==="
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

reset_conf() {
    echo "+-----------------------------------------------------------------------------------------------+"
    rm logs/* > /dev/null 2>&1 && my_log_success "Purge $logsdir successfully" || {
        my_log_warning "The folder $logsdir is probably also purged"
    }
    waitfor 1
    echo "+-----------------------------------------------------------------------------------------------+"
    my_log_success "Calling $AISS_NAME version $AISS_VERSION to run $FUNCNAME action by user[$SUDO_USER]"
    waitfor
    check_connection_ssh || return 1
    delete_keys_backuppc
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
