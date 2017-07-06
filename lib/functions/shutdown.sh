#!/bin/bash
# Automated Shutdown
# filename: lib/functions/actions_shutdown.sh
# Author: Kevin LACHAGES
# Contributor: Kevin RUE
# http://www.rkweb.fr

action_shutdown() {
    [[ ! $# -lt "1" ]] || {
        my_log_error "Error while parsing args"
        exit 1
    }
    local cmd="init 0"
    my_log_success "Calling $AISS_NAME version $AISS_VERSION to run $FUNCNAME action by user[$SUDO_USER]"
    waitfor
    for hosts in $*; do
        RSH root $hosts "$cmd"
        if [[ $rshStatus -ne 0 ]]; then
            my_log_error "Error during shutdown on $hosts. Host is probably already down..."
        else
            my_log_success "Shutdown on $hosts has succeed"
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
