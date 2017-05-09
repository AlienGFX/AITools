#!/bin/bash
# Automated Installer Save Storage
# filename: lib/functions/core.env.sh
# Author: Kevin RUE
# Contributor: Valentin NAINA
# http://www.rkweb.fr

# work directories
configdir="${directory}/configs"
templatesdir="${configdir}/templates"
logsdir="${directory}/logs"
secretsdir="${directory}/secrets"
sshdir="${secretsdir}/ssh"
deploydir="${directory}/deploy"
pubkey="${deploydir}/pubkey"

# mail config
sendmail="on"
inbox="AITools-production@rkservices.fr"
whosend="admin@rkservices.fr"

# core infrastructure
SYS_NODE_1="ns301969.ip-94-23-0.eu"
SYS_NODE_2="ns3014083.ip-149-202-65.eu"

SYS_WAVE_DEV_0="chimere unxdevtst01 unxdevtst02 unxdevtst03 unxdevtst04 unxdevtst05"
SYS_WAVE_PRD_0="comserver"
SYS_WAVE_PRD_1="einstein unxprddns01 unxprddns02"
SYS_WAVE_PRD_2="unxprdmail01 unxprddb01 unxprddb02 unxprdrvs01 unxprdweb01 unxprdvpn01"
SYS_WAVE_PRD_3="unxprdsrcds01 unxprdsrcds02 unxprdsrcds03 unxprdsrcds04 unxprdsrcds05 unxprdsrcds06 unxprdmds01 unxprdts01"

SRVNFS="srv-nfs"
SRVISCSI="srv-iscsi"
SRVBACKUP="srv-backup"
DOMAIN="rkservices.fr"
PORT_MONITORING="19999"

# dependancies
PKG_NFS="nfs-kernel-server nfs-common"
PKG_ISCSI="iscsitarget iscsitarget-dkms open-iscsi"
PKG_BACKUP="backuppc open-iscsi"

# global var
AISS_NAME="AITools"
AISS_VERSION="0.2"
AISS_BUILD="23032017"
AISS_PID="$$"
