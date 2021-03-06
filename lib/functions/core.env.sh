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

# git config
GIT_REPOSITORY="git@github.com:AlienGFX/AITools.git"

# core infrastructure
SYS_NODE_1="ns301969.ip-94-23-0.eu"
SYS_NODE_2="ns3014083.ip-149-202-65.eu"

SYS_WAVE_PRD_0="comserver"
SYS_WAVE_PRD_1="einstein unxprddns01 unxprddns02"
SYS_WAVE_PRD_2="unxprdmail01 unxprdweb01 unxprdgit01 unxprdvpn01"
SYS_WAVE_PRD_3="unxprdts01 unxprdbot01"
SYS_WAVE_PRD_4="unxprdsrcds01 unxprdsrcds02 unxprdsrcds03 unxprdsrcds04 unxprdsrcds05 unxprdsrcds06"

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
AISS_DATE="20180131"
AISS_BUILD="13"
AISS_VERSION="0.0.13"
AISS_LAST_CONTRIBUTOR="krue"
AISS_PID="$$"

# user params
AISS_USER="aisoft"
