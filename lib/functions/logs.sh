#!/bin/bash
# Automated Installer Save Storage
# filename: lib/functions/logs.sh
# Author: Kevin RUE
# Contributor: Valentin NAINA
# http://www.rkweb.fr

logfileName="${AISS_PID}_$(date '+%Y%m%d_%H%M%S')_${AISS_NAME}.log"
logfile="${logsdir}/${logfileName}"

my_log_success() {
    local status="SUCCESS"
    local logfileSuccess="${logfile}.success"
    printf "[$AISS_PID] $(date '+%Y/%m/%d %H:%M:%S') ${Green}[${status}] ${Color_Off}SVC_INFO "%1s" $*\n" | tee -a $logfile $logfileSuccess
    return 0
}

my_log_error() {
    local status="ERROR"
    local logfileErr="${logfile}.error"
    printf "[$AISS_PID] $(date '+%Y/%m/%d %H:%M:%S') ${Red}[${status}] "%1s" ${Color_Off}SVC_ERR "%2s" $*\n" | tee -a $logfile $logfileErr
    return 1
}

my_log_warning() {
    local status="WARNING"
    local logfileWarn="${logfile}.warn"
    printf "[$AISS_PID] $(date '+%Y/%m/%d %H:%M:%S') ${Yellow}[${status}] ${Color_Off}SVC_WARN "%1s" $*\n" | tee -a $logfile $logfileWarn
    return 2
}

my_log_setup() {
    local status="SETUP"
    local logfileErr="${logfile}.setup"
    printf "[$AISS_PID] $(date '+%Y/%m/%d %H:%M:%S') ${Cyan}[${status}] "%1s" ${Color_Off}SVC_SETUP"%1s" $*\n" | tee -a $logfile $logfileErr
    return $?
}