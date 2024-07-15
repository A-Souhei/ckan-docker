#!/bin/bash

while true; do
    # Sync from container to host
    rsync -av --delete /srv/app/ /app_sync/

    # Sync from host to container
    rsync -av --delete /app_sync/ /srv/app/

    sleep 1
done
