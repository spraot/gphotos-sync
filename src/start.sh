#!/bin/bash

# setup proper permissions
chmod -R a+rwx /profile
chmod -R a+rwx /download

source /app/log.sh

pidof cron && (echo "cron is already running" && exit 1)

set -e

CRON_SCHEDULE=${CRON_SCHEDULE:-0 * * * *}

PUID=${PUID:-1000}
PGID=${PGID:-1000}

id abc 2>/dev/null || (
addgroup abc --gid "${PGID}" --quiet
adduser abc --uid "${PUID}" --gid "${PGID}" --disabled-password --gecos "" --quiet
)

info "running with user uid: $(id -u abc) and user gid: $(id -g abc)"

chown -R abc:abc /app

if [[ "$1" == 'no-cron' ]]; then
    sudo -E -u abc sh /app/sync.sh
else
    info "scheduling cron job for: $CRON_SCHEDULE"
    LOGFIFO='/var/log/cron.fifo'
    if [[ ! -e "$LOGFIFO" ]]; then
        mkfifo "$LOGFIFO"
    fi
    chmod a+rw $LOGFIFO

    (while true; do cat "$LOGFIFO" || sleep 0.2; done) &

    CRON="CHROMIUM_USER_FLAGS='--no-sandbox'"
    CRON="$CRON\nHEALTHCHECK_ID='$HEALTHCHECK_ID'"
    CRON="$CRON\nHEALTHCHECK_HOST='$HEALTHCHECK_HOST'"
    CRON="$CRON\nLOGLEVEL='$LOGLEVEL'"
    CRON="$CRON\nWORKER_COUNT='$WORKER_COUNT'"
    CRON="$CRON\nGPHOTOS_CDP_ARGS='$GPHOTOS_CDP_ARGS'"
    CRON="$CRON\nALBUMS='$ALBUMS'"
    CRON="$CRON\nGPHOTOS_LOCALE_FILE='$GPHOTOS_LOCALE_FILE'"
    CRON="$CRON\nDOWNLOAD_DIR='$DOWNLOAD_DIR'"
    CRON="$CRON\nPROFILE_DIR='$PROFILE_DIR'"
    CRON="$CRON\n$CRON_SCHEDULE /usr/bin/flock -n /app/sync.lock bash /app/sync.sh > $LOGFIFO 2>&1"

    if [ -n "$RESTART_SCHEDULE" ]; then
        CRON="$CRON\n$RESTART_SCHEDULE rm -f /download/.lastdone* && rm -f /download/**/.lastdone* && echo \"Deleting .lastdone to restart schedule\" > $LOGFIFO 2>&1"
    fi

    echo -e "$CRON" | crontab -u abc -
    cron -f
fi
