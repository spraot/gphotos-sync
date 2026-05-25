#!/bin/bash

. /app/log.sh

info "starting sync.sh, pid: $$"

if [ -n "$HEALTHCHECK_ID" ]; then
  curl -sS -X POST -o /dev/null "$HEALTHCHECK_HOST/$HEALTHCHECK_ID/start"
fi

PROFILE_DIR="${PROFILE_DIR:-/tmp/gphotos-cdp}"
DOWNLOAD_DIR="${DOWNLOAD_DIR:-/download}"
WORKER_COUNT=${WORKER_COUNT:-6}
LOGLEVEL=${LOGLEVEL:-info}
SYNC_MAX_RETRIES=${SYNC_MAX_RETRIES:-3}
SYNC_RETRY_BACKOFF=${SYNC_RETRY_BACKOFF:-60}
GPHOTOS_CDP_ARGS="-profile \"$PROFILE_DIR\" -headless -json -loglevel $LOGLEVEL -removed -workers $WORKER_COUNT $GPHOTOS_CDP_ARGS -run /app/postdl.sh"

# Retry gphotos-cdp on non-zero exit. gphotos-cdp has a deadman that
# panics if no enumeration progress for 20 min — typically caused by
# Chrome's DOM interaction wedging on a particular item or Google
# throttling. A fresh invocation = fresh Chrome, which clears the
# wedge. Each retry resumes from .lastdone so progress isn't lost.
# Configurable: SYNC_MAX_RETRIES (default 3), SYNC_RETRY_BACKOFF (60s).
run_cdp_with_retry() {
  local cmd="$1"
  local attempt=0
  local rc=0
  while [ $attempt -lt $SYNC_MAX_RETRIES ]; do
    attempt=$((attempt + 1))
    rm -f $PROFILE_DIR/Singleton*
    info "gphotos-cdp attempt $attempt/$SYNC_MAX_RETRIES"
    if eval "$cmd"; then
      info "gphotos-cdp completed cleanly on attempt $attempt"
      return 0
    fi
    rc=$?
    if [ $attempt -lt $SYNC_MAX_RETRIES ]; then
      info "gphotos-cdp exited with $rc; sleeping ${SYNC_RETRY_BACKOFF}s before retry"
      sleep $SYNC_RETRY_BACKOFF
    fi
  done
  info "gphotos-cdp failed after $SYNC_MAX_RETRIES attempts (last exit code $rc)"
  return $rc
}

if [ -n "$ALBUMS" ]; then
  for ALBUM in $(echo $ALBUMS | tr ',' ' '); do
    ALBUM_DL_DIR="$DOWNLOAD_DIR/$(basename "$ALBUM")"
    if [ "$ALBUM" = "ALL" ]; then
      run_cdp_with_retry "gphotos-cdp -dldir \"$ALBUM_DL_DIR\" $GPHOTOS_CDP_ARGS" || exit $?
    else
      run_cdp_with_retry "gphotos-cdp -dldir \"$ALBUM_DL_DIR\" $GPHOTOS_CDP_ARGS -album $ALBUM" || exit $?
    fi
  done
else
  run_cdp_with_retry "gphotos-cdp -dldir \"$DOWNLOAD_DIR\" $GPHOTOS_CDP_ARGS" || exit $?
fi

info "completed sync.sh, pid: $$"

if [ -n "$HEALTHCHECK_ID" ]; then
  curl -sS -X POST -o /dev/null --fail "$HEALTHCHECK_HOST/$HEALTHCHECK_ID"
fi
