#!/bin/bash
# Automated Installer Save Storage
# filename: lib/functions/core.sh
# Author: Kevin RUE
# Contributor: Valentin NAINA
# http://www.rkweb.fr

RSH() {
    local SSH_ARGS="-o ServerAliveInterval 1"
    local user=$1
    local host=$2
    local cmd=$3
    ssh "$SSH_ARGS" "$user@$host" "$cmd" > /dev/null 2>&1 # fix async call to get child pid err
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
    echo "run $@"
    "$@"
}

check_connection_ssh() {
    for host in $SYS_WAVE_DEV_0 $SYS_WAVE_PRD_1 $SYS_WAVE_PRD_2 $SYS_WAVE_PRD_3 $SYS_WAVE_PRD_4 $SYS_WAVE_PRD_5; do
        RSH root $host hostname
        if [[ $rshStatus -ne 0 ]]; then
            my_log_error "SSH connection for $host has failed. Please check the ssh key"
        else
            my_log_success "SSH connection for $host has been successfully established"
        fi
    done
}

syncssh() {
    [[ ! $# -lt "1" ]] || {
        my_log_error "Error while parsing args"
        exit 1
    }
    for host in $*; do
        run_cmd ssh-copy-id -i /root/.ssh/id_rsa.pub $host > /dev/null 2>&1
        if [[ $? -ne 0 ]]; then
            my_log_error "Problem during deploy keys from $hostname to $host"
        else
            my_log_success "RSA Public Key has been deployed successfully to $host"
        fi
    done
}

increment_version() {
    local VERSION="$1"
    local INCREMENTED_VERSION=
    if [[ "$VERSION" =~ .*\..* ]]; then
        INCREMENTED_VERSION="${VERSION%.*}.$((${VERSION##*.}+1))"
    else
        INCREMENTED_VERSION="$((${VERSION##*.}+1))"
    fi
    echo "$INCREMENTED_VERSION"
}

deploy() {
    local OPT="/opt"
    local BUILD_FOLDER="$logsdir/.gitbuild"
    local BUILD_CURRENT=$AISS_BUILD
    local BUILD_NEW="$(increment_version $AISS_BUILD)"
    local BUILD_DATE="$(date +%Y%m%d)"
    local VERSION_NEW="$(increment_version $AISS_VERSION)"
    local LAST_CONTRIBUTOR="$SUDO_USER"
    sed -i "s/^AISS_BUILD=.*/AISS_BUILD=\"$BUILD_NEW\"/" lib/functions/core.env.sh
    sed -i "s/^AISS_VERSION=.*/AISS_VERSION=\"$VERSION_NEW\"/" lib/functions/core.env.sh
    sed -i "s/^AISS_DATE=.*/AISS_DATE=\"$BUILD_DATE\"/" lib/functions/core.env.sh
    sed -i "s/^AISS_LAST_CONTRIBUTOR=.*/AISS_LAST_CONTRIBUTOR=\"$LAST_CONTRIBUTOR\"/" lib/functions/core.env.sh
    source lib/functions/core.env.sh
    run_cmd git add lib/functions/core.env.sh
    run_cmd git commit -m "$AISS_NAME new build $AISS_BUILD version $AISS_VERSION new announcement"
    run_cmd git push origin master
    my_log_success "Calling $AISS_NAME version $AISS_VERSION to run $FUNCNAME action by user[$SUDO_USER]"
    waitfor
    run_cmd cd $OPT
    [[ -d AITools ]] && {
        run_cmd mv AITools AITools.old
        if [[ $? -ne 0 ]]; then
            my_log_error "error during move AITools to AITools.old"
            exit
        else
            my_log_success "mv AITools AITools.old"
        fi
    } || {
        my_log_warning "Folder AITools does not exists. Ready to launch git clone command..."
    }
    my_log_setup "Clone $AISS_NAME github repository"
    run_cmd git clone $GIT_REPOSITORY
    my_log_setup "Create logs folder"
    run_cmd cd $AISS_NAME && mkdir logs
    my_log_setup "Apply chmod permissions"
    run_cmd chmod 750 aiss.sh
    run_cmd chmod 640 lib/functions/*
    cd $directory
    echo -e "New $AISS_NAME version has been deployed\n
    -------------------------------------------
    Product : $AISS_NAME
    Build : $AISS_BUILD
    Version : $AISS_VERSION
    Date : $AISS_DATE
    Owner : $AISS_LAST_CONTRIBUTOR
    Path : $OPT/$AISS_NAME
    -------------------------------------------\n" > $BUILD_FOLDER
    echo -e "Log\n" >> $BUILD_FOLDER
    git log --oneline >> $BUILD_FOLDER
    echo -e "\nLog Details\n" >> $BUILD_FOLDER
    git log >> $BUILD_FOLDER
    if [[ $? -ne 0 ]]; then
        local lastFile="$(ls -1rt $logsdir | tail -n1)"
        local subject="$AISS_NAME version $AISS_VERSION action [$FUNCNAME] pid [$AISS_PID] has failed"
        my_log_error "$FUNCNAME action has failed, see more logs/$lastFile"
        mailer "$lastFile" "$subject"
    else
        local lastFile="$(ls -1rt $logsdir | tail -n1)"
        local subject="$AISS_NAME version $AISS_VERSION action [$FUNCNAME] pid [$AISS_PID] has success"
        local build="$AISS_NAME new build $AISS_BUILD version $AISS_VERSION new announcement"
        my_log_success "$FUNCNAME action has success, see more logs/$lastFile"
        mailer "$lastFile" "$subject"
        my_log_success "$build"
        mailer .gitbuild "$build"
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

install_packages() {
    [[ ! $# -lt "2" ]] || {
        my_log_error "Error while parsing args"
        exit 1
    }
    local username="$(whoami)"
    local hostname="$1"
    shift 1
    local packages="$*"
    local cmd="apt-get install -y $packages"
    local tmpdist="/tmp/.$$_$(date '+%Y%m%d_%H%M%S')_$(hostname)_$FUNCNAME"
    my_log_success "Calling $AISS_NAME version $AISS_VERSION to run $FUNCNAME action by user[$SUDO_USER]"
    waitfor
    RSH "$username" "$hostname" "$cmd > $tmpdist"
    if [[ $rshStatus -ne 0 ]]; then
        my_log_error "Error during install $packages packages on $hostname. Probably service is down..."
    else
        my_log_success "Install $packages packages on $hostname is success, more details: $tmpdist"
    fi
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
            my_log_error "Error during update on $hosts. Probably service is down..."
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
            my_log_error "Error during upgrade on $hosts. Probably service is down..."
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
