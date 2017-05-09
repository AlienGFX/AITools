#!/bin/bash
# Automated Installer Save Storage
# filename: lib/functions/services.sh
# Author: Kevin RUE
# Contributor: Valentin NAINA
# http://www.rkweb.fr

[ -r $functionsdir/actions_svc.sh ] && source $functionsdir/actions_svc.sh || return 1

start_svc() {
    my_log_success "Calling $AISS_NAME version $AISS_VERSION to $FUNCNAME by user[$SUDO_USER]"
    waitfor 1
    check_connection_ssh || return 1
    action_svc_nfs start
    action_svc_iscsi start
    action_svc_backup start
    if [[ $? -ne 0 ]]; then
        local lastFile="$(ls -1rt $logsdir | tail -n1)"
        local subject="$AISS_NAME version $AISS_VERSION action [$FUNCNAME] pid [$AISS_PID] has failed"
        my_log_error "Action $FUNCNAME has failed, see more logs/$lastFile"
        mailer "$lastFile" "$subject"
    else
        local lastFile="$(ls -1rt $logsdir | tail -n1)"
        local subject="$AISS_NAME version $AISS_VERSION action [$FUNCNAME] pid [$AISS_PID] has success"
        my_log_success "Action $FUNCNAME has success, see more logs/$lastFile"
        mailer "$lastFile" "$subject"
    fi
}

stop_svc() {
    my_log_success "Calling $AISS_NAME version $AISS_VERSION to $FUNCNAME by user[$SUDO_USER]"
    waitfor 1
    check_connection_ssh || return 1
    action_svc_nfs stop
    action_svc_iscsi stop
    action_svc_backup stop
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

restart_svc() {
    my_log_success "Calling $AISS_NAME version $AISS_VERSION to run $FUNCNAME action by user[$SUDO_USER]"
    waitfor 1
    check_connection_ssh || return 1
    action_svc_nfs restart
    action_svc_iscsi restart
    action_svc_backup restart
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

status_svc() {
    my_log_success "Calling $AISS_NAME version $AISS_VERSION to run $FUNCNAME action by user[$SUDO_USER]"
    waitfor 1
    check_connection_ssh
    #action_svc is froozen"
    #action_svc_nfs status || my_log_warning "Probably service $PKG_NFS is stopped"
    #action_svc_iscsi status || my_log_warning "Probably service $PKG_ISCSI is stopped"
    #action_svc_backup status || my_log_warning "Probably service $PKG_BACKUP is stopped"
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
