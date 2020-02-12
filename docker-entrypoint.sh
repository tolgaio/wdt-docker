#!/usr/bin/env bash
set -e

if [ "$1" = 'wdt' ]; then
  shift
  exec wdt \
    -directory $WDTDATA \
    -logtostderr=false \
    -overwrite=true \
    -enable_download_resumption=true \
    "$@"
fi

exec "$@"
