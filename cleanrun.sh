#!/bin/bash

docker volume create --driver local -o o=bind -o type=none -o device="~/Sources/ckan-docker/ckan/sources" ckan_app_dir
docker compose down -v && docker compose build ckan && docker compose up -d
sudo chmod -R 777 ~/Sources/ckan-docker/ckan/sources
