#!/bin/bash

FILENAME=$0
USER="csgoserver"
HOMEDIR="/home/$USER"
SHELL="/bin/bash"
METHOD="/usr/sbin/chpasswd"
PASSWD="dThWM1J0MmkK"
LGSM_CSGO="https://gameservermanagers.com/dl/csgoserver"
INSTANCE_NAME="csgoserver"
DOMAIN="esgi-gaming.fr"
OWNER="$(hostname)@$DOMAIN"
MAILER="admin@rkservices.fr csgo@esgi-gaming.fr samuelantunes@hotmail.fr benoit.decampenaire@gmail.com robin.minot32@gmail.com k.rue@free.fr"

logfile="$$.install_lgsm_csgo_$(date '+%Y%m%d_%H%M%S').log"
format="sed -r s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"

run_cmd() {
    echo "run $@"
    "$@"
}

# dependancies
run_cmd dpkg --add-architecture i386
run_cmd apt-get update
run_cmd apt-get install -y \
    mailutils postfix curl wget file unzip gzip bzip2 bsdmainutils \
    python util-linux tmux lib32gcc1 libstdc++6 libstdc++6:i386

for n in {1..5}; do
    # service account
    run_cmd useradd -m -d $HOMEDIR$n $USER$n -s $SHELL
    run_cmd echo $USER$n:$(echo $PASSWD | base64 -d) | $METHOD

    cmd="su - $USER$n -c"

    # downloading LGSM CSGO
    run_cmd $cmd "wget $LGSM_CSGO && chmod +x $INSTANCE_NAME"

    # install CSGO
    run_cmd $cmd "./$INSTANCE_NAME auto-install > /tmp/srv$n.$logfile"

    # send mail
    cat "/tmp/srv$n.$logfile" | $format | mailx -a "From:$OWNER" -s "$(hostname): status csgo server installation $INSTANCE_NAME -- $n" $MAILER
    $cmd "./$INSTANCE_NAME details" | $format | mailx -a "From:$OWNER" -s "$(hostname): information csgo server $INSTANCE_NAME -- $n" $MAILER
done

# auto delete file
rm $FILENAME
