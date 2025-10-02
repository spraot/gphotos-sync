#!/bin/bash

. /app/log.sh

info "starting sync.sh, pid: $$"

if [ -n "$HEALTHCHECK_ID" ]; then
  curl -sS -X POST -o /dev/null "$HEALTHCHECK_HOST/$HEALTHCHECK_ID/start"
fi

set -e

PROFILE_DIR=/profile
DOWNLOAD_DIR=/download
WORKER_COUNT=${WORKER_COUNT:-6}
LOGLEVEL=${LOGLEVEL:-info}
GPHOTOS_CDP_ARGS="-profile \"$PROFILE_DIR\" -headless -json -loglevel $LOGLEVEL -removed -workers $WORKER_COUNT $GPHOTOS_CDP_ARGS -run /app/postdl.sh"

rm -f $PROFILE_DIR/Singleton*

if [ -n "$ALBUMS" ]; then
  for ALBUM in $(echo $ALBUMS | tr ',' ' '); do
    ALBUM_DL_DIR="$DOWNLOAD_DIR/$(basename "$ALBUM")"
    if [ "$ALBUM" = "ALL" ]; then
      eval gphotos-cdp -dldir "$ALBUM_DL_DIR" $GPHOTOS_CDP_ARGS
    else
      eval gphotos-cdp -dldir "$ALBUM_DL_DIR" $GPHOTOS_CDP_ARGS -album $ALBUM
    fi
  done
else
  eval gphotos-cdp -dldir "$DOWNLOAD_DIR" $GPHOTOS_CDP_ARGS
fi

info "completed sync.sh, pid: $$"

if [ -n "$HEALTHCHECK_ID" ]; then
  curl -sS -X POST -o /dev/null --fail "$HEALTHCHECK_HOST/$HEALTHCHECK_ID"
fi
