#!/bin/bash

mkdir -p /app_sync

while true; do
    # Sync from container to host
    rsync -a --delete --chown=ckan:ckan /srv/app/ /app_sync/
    sleep 1
done
